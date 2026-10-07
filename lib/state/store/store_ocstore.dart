part of '../store.dart';

// The fields, static helpers and dispose() of OcStore live here. Its behaviour is
// split by topic into the OcStore* extensions in store_ocstore_<topic>.dart.
class OcStore extends ChangeNotifier {
  final OcClient api = OcClient();
  EventStream? _stream;

  /// Fires when the *contents* of the message list change.
  final messageList = MessageListSignal();

  /// Fires when the todo list changes. Deliberately not the app-wide
  /// notifier: a todo update must not rebuild the transcript.
  final todoList = TodoListSignal();

  /// What the transcript listens to: [messageList] for token-level edits plus
  /// this store for the app-wide state that also changes the list's own chrome
  /// (loading state, `hasMoreMessages`, `showTokensInChat`, a session switch).
  ///
  /// Built once because `Listenable.merge` re-subscribes on every construction.
  /// Merging is what makes the split safe: any mutation that still notifies the
  /// app also refreshes the transcript, so no update path can silently leave the
  /// list stale.
  late final Listenable messageListenable = Listenable.merge([
    this,
    messageList,
  ]);

  SharedPreferences? _prefs;
  bool _disposed = false;

  // ---- connection ----
  String baseUrl = 'http://127.0.0.1:4096';
  String username = 'opencode';
  String password = '';
  bool online = false;

  /// The event stream is down and the client is retrying, but reachability has
  /// not been disproved yet. Presentation-only: the header shows a pulsing
  /// "Reconnecting" between Connected and Offline.
  bool reconnecting = false;

  /// Last time the server proved it was alive: any event off the stream, or a
  /// good health probe. A single slow probe must not outweigh this.
  DateTime _lastAlive = DateTime.fromMillisecondsSinceEpoch(0);
  String serverVersion = '';
  ServerPaths? paths;
  VcsInfo? vcs;
  String? fatalError;
  bool booted = false;

  // ---- session ----
  List<Session> sessions = [];
  bool sessionsLoading = false;
  String? sessionsError;
  Session? current;
  List<ChatMessage> messages = [];
  bool messagesLoading = false;
  bool hasMoreMessages = false;
  String? _oldestMessageId;
  int _historyLoadGen = 0; // guards against stale loads after session switch
  bool busy = false;
  String busyStatus = '';
  String? sessionError;
  List<FileDiff> liveDiff = [];
  List<Todo> todos = [];
  final Set<String> toolsEnabled = {};

  // ---- catalog ----
  List<Agent> agents = [];
  ProviderInfo? providerInfo;
  String agent = 'build';
  String providerId = '';
  String modelId = '';
  String modelQuery = '';

  // ---- display prefs ----
  /// When true each assistant reply shows its token / cost footer. Persisted.
  /// Defaults to off; the chat redesign hides tokens behind this flag.
  bool showTokensInChat = false;

  // ---- prompts ----
  List<PermissionReq> permissions = [];
  List<QuestionReq> questions = [];

  final Map<String, int> _arrival = {};
  int _promptSeq = 0;

  // ---- prompt sheet visibility ----
  //
  // The sheet used to be a permanent modal keyed off "is anything pending", so
  // there was no way to get it out of the way without answering. These three
  // members separate *pending* (a server fact, drives the badge) from *shown*
  // (a presentation choice, driven by the user).

  /// False once the user has dismissed the sheet. Cleared automatically the
  /// moment a new request arrives, so a prompt is never silently withheld.
  bool promptSheetDismissed = false;

  // ---- extras ----
  List<CommandInfo> commands = [];
  List<SkillInfo> skills = [];
  Map<String, dynamic> config = {};
  Map<String, NamedStatus> mcp = {};
  List<NamedStatus> lsp = [];
  List<NamedStatus> formatters = [];

  List<PendingAttachment> attachments = [];

  // =====================================================================
  // throttled notify (FIX: streaming used to rebuild the UI on every token)
  // =====================================================================

  Timer? _notifyTimer;
  bool _notifyPending = false;

  Timer? _msgNotifyTimer;
  bool _msgNotifyPending = false;

  Timer? _todoTimer;

  /// Slack when comparing the server's `created` stamp with the local
  /// `DateTime.now()` the optimistic bubble was drawn with — the server can
  /// stamp a turn a hair earlier than we did.
  static const int _echoSkewMs = 5000;

  /// Plain text of a message's text parts, so an optimistic bubble and the
  /// server's copy of the same turn can be compared without ids.
  static String _messageText(ChatMessage m) {
    final b = StringBuffer();
    for (final p in m.parts) {
      final t = p.text.trim();
      if (p.type != 'text' || t.isEmpty) continue;
      if (b.isNotEmpty) b.write('\n');
      b.write(t);
    }
    return b.toString();
  }

  /// Removes the optimistic user bubble once [window] already holds the
  /// server's own copy of that same turn.
  ///
  /// The optimistic row carries a `local-<ms>` id the server never knows about,
  /// so the id-based merge in [_mergeHistory] could not match it: it was kept in
  /// `older` *and* the confirmed message was added from the window, rendering
  /// the user's message twice. That happens whenever the `message.updated` echo
  /// is missed (SSE dropped while backgrounded, so the next idle resync or
  /// watchdog probe is the first thing that sees the confirmed message) — the
  /// [send] hand-over only runs on that event.
  ///
  /// Matches on content plus ordering, because only one prompt is ever in
  /// flight: a genuinely older turn with identical text is left alone.
  static void _stripEchoedOptimistic(
    List<ChatMessage> list,
    List<ChatMessage> window,
  ) {
    var oi = -1;
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m.info.role == 'user' && m.info.raw['optimistic'] == true) {
        oi = i;
        break;
      }
    }
    if (oi < 0) return;
    final local = list[oi];
    final localText = _messageText(local);
    if (localText.isEmpty) return;

    ChatMessage? confirmed;
    for (var i = window.length - 1; i >= 0; i--) {
      final m = window[i];
      if (m.info.role == 'user' && m.info.raw['optimistic'] != true) {
        confirmed = m;
        break;
      }
    }
    if (confirmed == null) return;
    if (confirmed.info.created + _echoSkewMs < local.info.created) return;
    if (_messageText(confirmed) == localText) list.removeAt(oi);
  }

  /// Streaming calls this per token. Snapshotting the touched messages and
  /// letting [ChatDB] serialise the write keeps the cache current without
  /// re-encoding every row in a long session on every token. During a run
  /// only the live message is dirty, so this stays at one row.
  Timer? _flushTimer;
  String? _flushSession;
  final Map<String, Map<String, dynamic>> _dirty = {};

  /// True while a reachability probe is already in flight, so a dropped socket
  /// that fires several triggers does not stack up health checks.
  bool _reachProbeBusy = false;

  bool _connecting = false;

  bool _resyncing = false;

  bool _todosInFlight = false;
  bool _todosQueued = false;

  /// When the list was last read from the server, by either path.
  DateTime? _todosFetchedAt;

  /// Last time [ensureTodosFresh] asked for one, so a stale list is re-read at
  /// most once per stale window no matter how often a widget rebuilds.
  DateTime _todosLastFetch = DateTime.fromMillisecondsSinceEpoch(0);

  /// A list that has not been re-read for a while is not worth trusting while
  /// the agent is mid-run, so the page asks for a refetch instead of showing a
  /// number it cannot stand behind. No banner: the fix is to go and get it.
  static const _staleAfter = Duration(seconds: 20);

  /// Newest-page size used when opening a session.
  ///
  /// This is deliberately generous. The documented `before` query parameter
  /// answers `HTTP 400 {"_tag":"BadRequest"}` for *any* value on opencode
  /// 1.18.27, so server-side backwards pagination is unavailable there — a
  /// small limit would permanently hide everything but the newest page.
  static const pageLimit = 500;

  /// Current page size; widened on demand for unusually long conversations.
  int _limit = pageLimit;

  /// Send a chat message. Returns immediately; output streams in via SSE.
  /// Prompts typed while a run is in flight, flushed in order when it ends.
  ///
  /// The composer used to swallow them: the send button is a Stop button while
  /// busy, so anything typed during a long run was either discarded or sent as
  /// a second concurrent prompt, which the server then interleaved.
  final List<String> _queued = [];

  // ---- busy watchdog -------------------------------------------------
  // FIX: the old 5-minute one-shot timer was never reset, so any long agent
  // run showed a fake "timeout". Now it only fires after 5 min of *silence*.
  Timer? _busyTimer;
  bool _busyProbeActive = false;
  int _probeFailures = 0;
  DateTime _lastActivity = DateTime.now();

  // =====================================================================
  // shell / files (uses a private utility session so the chat stays clean)
  // =====================================================================

  static const utilSessionTitle = '__opencode_app_util__';
  String? _utilSessionId;

  /// Parent directory of [path], `/` when there is none.
  static String _parentDir(String path) {
    final i = path.lastIndexOf('/');
    if (i <= 0) return '/';
    return path.substring(0, i);
  }

  static String _shellQuote(String s) {
    // Escape for POSIX shell single quotes: replace ' with '\'' and wrap in single quotes.
    // Also reject newlines and null bytes which would break the quoting.
    if (s.contains('\n') || s.contains('\r') || s.contains('\u0000')) {
      throw ArgumentError('Invalid path: contains newline or null byte');
    }
    return "'${s.replaceAll("'", "'\\''")}'";
  }

  bool _promptSyncing = false;
  bool _promptResyncAgain = false;

  /// Newest optimistic user row. Only one prompt is in flight at a time, so the
  /// server's echo always belongs to the send that was made last — matching the
  /// *first* optimistic row instead used to delete the wrong bubble.
  /// Prefix of the part ids minted locally in [send] for the optimistic bubble.
  /// Must stay in sync with the `'part-$userMsgId'` ids built there.
  static const String _localPartPrefix = 'part-local-';

  /// Real message id whose `message.updated` has arrived while the local
  /// bubble is still standing in for it, plus that message's real info.
  ///
  /// `message.updated` carries no parts, so swapping the optimistic row for it
  /// straight away left the row with nothing to render — the user's own message
  /// visibly vanished and, if the part events never followed, never came back.
  /// The swap is deferred to [_upsertPart], the first event that actually has
  /// content to replace the local text with.
  String? _echoForLocal;
  Message? _echoInfo;

  // =====================================================================

  String? _lastToast;

  @override
  void dispose() {
    _disposed = true;
    _clearBusyTimer();
    _notifyTimer?.cancel();
    _msgNotifyTimer?.cancel();
    _todoTimer?.cancel();
    _flushTimer?.cancel();
    // Final, not a pause: a lifecycle callback that still arrives after this
    // must not be able to build a new stream into a disposed store.
    unawaited(_stream?.shutdown());
    unawaited(_flushHistory());
    api.close();
    super.dispose();
  }
}
