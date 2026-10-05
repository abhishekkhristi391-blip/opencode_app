import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/events.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../db/chat_db.dart';

class ChatMessage {
  Message info;
  List<Part> parts;
  String? errorText;

  /// Set once the store has concluded the run is over even though the server
  /// never sent a completion stamp for this message (abort, error, or a lost
  /// `message.updated`). Without it `streaming` stays true and the typing dots
  /// spin forever on a message the agent already abandoned.
  bool settled = false;

  // FIX: always copy into a *growable* list. Passing `const []` used to make
  // parts.add() throw, so streamed parts never showed up.
  ChatMessage(this.info, List<Part> parts, {this.errorText})
    : parts = List<Part>.of(parts);

  /// Error to show for this message: an explicit local one wins over whatever
  /// the server attached.
  String? get displayError => errorText ?? info.errorMessage;

  /// True only while the server is still producing this assistant message.
  /// `time.completed` is checked as well as the finish reason: a stopped or
  /// failed run leaves the finish reason empty, which used to keep the typing
  /// dots on forever and hide the error.
  bool get streaming =>
      !settled &&
      info.finishReason.isEmpty &&
      !info.completed &&
      info.role == 'assistant' &&
      displayError == null;
}

class PendingAttachment {
  final String path, mime, name;
  final int size;
  final String dataUrl;
  PendingAttachment({
    required this.path,
    required this.mime,
    required this.name,
    required this.size,
    required this.dataUrl,
  });
}

/// Single source of truth for the whole app. A [ChangeNotifier] wired into the
/// widget tree through [AppScope], so no external state-management dependency.
/// Transcript-local rebuild signal.
///
/// Token streaming rewrites [OcStore.messages] many times a second. Firing the
/// single app-wide [ChangeNotifier] that often rebuilt *every* mounted
/// subscriber on each token — the composer, the sessions tab kept alive in the
/// `IndexedStack`, the busy and error bars — even though only the transcript
/// displays the text. This carries that traffic instead.
class MessageListSignal extends ChangeNotifier {
  /// Announces a change to the message list.
  ///
  /// Wrapped in its own type so only the store can raise it;
  /// `ChangeNotifier.notifyListeners` is `@protected`.
  void notify() => notifyListeners();
}

class OcStore extends ChangeNotifier {
  final OcClient api = OcClient();
  EventStream? _stream;

  /// Fires when the *contents* of the message list change.
  final messageList = MessageListSignal();

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

  void setShowTokensInChat(bool v) {
    if (showTokensInChat == v) return;
    showTokensInChat = v;
    unawaited(_persist());
    notifyListeners();
  }

  // ---- prompts ----
  List<PermissionReq> permissions = [];
  List<QuestionReq> questions = [];

  /// Single source of truth for "is the agent blocked on a human". Every prompt
  /// surface — the header badge, the working strip, the overlay — reads this,
  /// so they cannot disagree about how many requests are waiting.
  ///
  /// Permissions first, then questions, both already oldest-first: a request
  /// queued behind another is only reachable after the one before it clears.
  int get pendingPromptCount => permissions.length + questions.length;

  /// The oldest unanswered permission, or null. Read by the Review chip, the
  /// avatar menu row and PromptOverlay so they all open the same request.
  PermissionReq? get oldestPendingPermission =>
      permissions.isEmpty ? null : permissions.first;

  /// The oldest unanswered question, or null.
  QuestionReq? get oldestPendingQuestion =>
      questions.isEmpty ? null : questions.first;

  /// True when the session can make no progress until the user replies.
  bool get awaitingPrompt => pendingPromptCount > 0;

  // ---- prompt sheet visibility ----
  //
  // The sheet used to be a permanent modal keyed off "is anything pending", so
  // there was no way to get it out of the way without answering. These three
  // members separate *pending* (a server fact, drives the badge) from *shown*
  // (a presentation choice, driven by the user).

  /// False once the user has dismissed the sheet. Cleared automatically the
  /// moment a new request arrives, so a prompt is never silently withheld.
  bool promptSheetDismissed = false;

  /// Show the prompt sheet for the oldest pending request. A no-op when
  /// nothing is pending, so a stale Review tap cannot open an empty card.
  void openPromptSheet() {
    if (!awaitingPrompt) return;
    if (promptSheetDismissed) {
      promptSheetDismissed = false;
      notifyListeners();
    }
  }

  /// Dismiss the sheet without answering. The request stays pending on the
  /// server, so the badge, the strip and the drawer count keep reporting it.
  void dismissPromptSheet() {
    if (promptSheetDismissed) return;
    promptSheetDismissed = true;
    notifyListeners();
  }

  /// A request arrived. The sheet re-arms unconditionally — a prompt that
  /// was dismissed while a *different* one was on screen must still be seen.
  void _onPromptAdded() {
    promptSheetDismissed = false;
  }

  /// A request was answered (here or in the TUI). Only clear the dismissal once
  /// nothing at all is left, otherwise dismissing and then answering would pop
  /// the sheet straight back open for the next request in the queue.
  void _onPromptRemoved() {
    if (!awaitingPrompt) promptSheetDismissed = false;
  }

  /// Display title for a session id, falling back to the id itself when the
  /// session is not in the list the app holds (a subagent's session, or one
  /// created while we were offline). Used to label a prompt that arrived from
  /// another chat so it is obvious whose run is blocked.
  String sessionLabel(String id) {
    if (id.isEmpty) return S.dash;
    if (current?.id == id) return current!.label;
    for (final s in sessions) {
      if (s.id == id) return s.label;
    }
    return id;
  }

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

  /// Coalesces streaming deltas into at most ~16 rebuilds/sec, but paints the
  /// *first* change of a burst straight away.
  ///
  /// The old version always waited a full window before the first rebuild, so
  /// the opening token of every reply appeared late; worse, any change that
  /// landed while a timer was pending was dropped without a trailing rebuild,
  /// so the final token of a turn could sit unrendered for good.
  void _scheduleNotify() {
    if (_disposed) return;
    _notifyPending = true;
    if (_notifyTimer != null) return;
    _notifyPending = false;
    notifyListeners();
    _notifyTimer = Timer(const Duration(milliseconds: 60), () {
      _notifyTimer = null;
      // Guarantees the last change of a burst always gets painted.
      if (_notifyPending) _scheduleNotify();
    });
  }

  /// Same throttle, but scoped to [messageList] so a token never rebuilds the
  /// rest of the app.
  void _scheduleMessageNotify() {
    if (_disposed) return;
    _msgNotifyPending = true;
    if (_msgNotifyTimer != null) return;
    _msgNotifyPending = false;
    messageList.notify();
    _msgNotifyTimer = Timer(const Duration(milliseconds: 60), () {
      _msgNotifyTimer = null;
      if (_msgNotifyPending) _scheduleMessageNotify();
    });
  }

  Timer? _todoTimer;
  void _debouncedTodos() {
    _todoTimer?.cancel();
    _todoTimer = Timer(const Duration(milliseconds: 600), () {
      if (!_disposed) unawaited(refreshTodos());
    });
  }

  // =====================================================================
  // local history cache
  // =====================================================================

  /// Row shape stored by [ChatDB]. Built from the models' raw server JSON so a
  /// reload round-trips through [Message.fromJson] without a lossy mapping.
  Map<String, dynamic> _dbRow(ChatMessage m) => {
    'info': m.info.toMap(),
    'parts': m.parts.map((p) => p.toMap()).toList(),
  };

  /// Messages that must not be written to disk: the local echo of a user
  /// message the server has not confirmed yet, and the blank placeholder
  /// synthesised when a part arrives before its header. Both get a real row
  /// moments later when the server echoes them back, so persisting them now
  /// only risks resurrecting an empty bubble.
  /// Also excludes assistant messages that are still streaming (no finishReason).
  bool _isCacheable(ChatMessage m) {
    if (m.info.id.isEmpty) return false;
    if (m.info.raw['optimistic'] == true) return false;
    if (m.info.raw.isEmpty) return false;
    // Don't cache assistant messages that haven't finished yet (no finishReason).
    if (m.info.role == 'assistant' && m.info.finishReason.isEmpty) return false;
    return true;
  }

  /// Combines already-loaded history with the newest [window] from the server.
  ///
  /// The server only returns the most recent page, so assigning it straight
  /// over `messages` discarded everything older. Cached messages that sit
  /// before that page are kept; messages inside it are replaced by the
  /// server's copy, which is authoritative.
  List<ChatMessage> _mergeHistory(
    List<ChatMessage> existing,
    List<ChatMessage> window,
  ) {
    if (window.isEmpty) return existing;
    final ids = {for (final m in window) m.info.id};
    final newest = window.last.info.created;
    final older = <ChatMessage>[];
    if (newest > 0) {
      for (final m in existing) {
        if (ids.contains(m.info.id)) continue;
        if (m.info.created > 0 && m.info.created < newest) older.add(m);
      }
    }
    final merged = [...older, ...window];
    _stripEchoedOptimistic(merged, window);
    return merged;
  }

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

  /// Reads a session's history out of the cache. Returns an empty list rather
  /// than throwing: a broken cache must never block opening a session.
  Future<List<ChatMessage>> _cachedHistory(String id) async {
    try {
      final rows = await ChatDB.instance.loadMessages(id);
      return rows
          .map(
            (r) => ChatMessage(
              Message.fromJson(asMap(r['info'])),
              asList(r['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
            ),
          )
          .where((m) => !m.info.summary)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('history cache read failed: $e');
      return const [];
    }
  }

  /// Streaming calls this per token. Snapshotting the touched messages and
  /// letting [ChatDB] serialise the write keeps the cache current without
  /// re-encoding every row in a long session on every token. During a run
  /// only the live message is dirty, so this stays at one row.
  Timer? _flushTimer;
  String? _flushSession;
  final Map<String, Map<String, dynamic>> _dirty = {};

  void _scheduleFlush(String sessionId, ChatMessage m) {
    if (!_isCacheable(m)) return;
    // Snapshots are keyed by session, so switching chats has to push out the
    // pending rows first or they would be written under the new session id.
    if (_flushSession != null && _flushSession != sessionId) {
      unawaited(_flushHistory());
    }
    _flushSession = sessionId;
    _dirty[m.info.id] = _dbRow(m);
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 400), () {
      if (!_disposed) unawaited(_flushHistory());
    });
  }

  /// Writes the pending snapshots now. Called before switching sessions and
  /// when a run goes idle, so the tail of a conversation is never left
  /// unwritten. Rows are read synchronously, before [ChatDB]'s queue turn.
  Future<void> _flushHistory() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    final sid = _flushSession;
    final rows = _dirty.values.toList();
    _flushSession = null;
    _dirty.clear();
    if (sid == null || rows.isEmpty) return;
    try {
      await ChatDB.instance.upsertMessages(sid, rows);
    } catch (e) {
      if (kDebugMode) debugPrint('history cache write failed: $e');
    }
  }

  /// Persists a full page of server messages (open / paginate / resync).
  void _persistHistory(String sessionId, List<ChatMessage> list) {
    final rows = list.where(_isCacheable).map(_dbRow).toList();
    if (rows.isEmpty) return;
    unawaited(ChatDB.instance.upsertMessages(sessionId, rows));
  }

  // ---- permissions ----
  // NOTE: there is deliberately no storage-permission gate here. File writes go
  // through the server's shell, so this app's MANAGE_EXTERNAL_STORAGE state is
  // irrelevant to them; prompting for it only added friction.

  // =====================================================================
  // boot
  // =====================================================================

  Future<void> boot() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    baseUrl = prefs.getString('url') ?? baseUrl;
    username = prefs.getString('user') ?? username;
    password = prefs.getString('pass') ?? '';
    agent = prefs.getString('agent') ?? agent;
    providerId = prefs.getString('provider') ?? '';
    modelId = prefs.getString('model') ?? '';
    toolsEnabled.addAll(prefs.getStringList('tools') ?? const []);
    showTokensInChat = prefs.getBool('showTokens') ?? false;
    booted = true;
    notifyListeners();
    await connect();
  }

  Future<void> _persist() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString('url', baseUrl);
    await p.setString('user', username);
    await p.setString('pass', password);
    await p.setString('agent', agent);
    await p.setString('provider', providerId);
    await p.setString('model', modelId);
    await p.setStringList('tools', toolsEnabled.toList());
    await p.setBool('showTokens', showTokensInChat);
  }

  // =====================================================================
  // connection
  // =====================================================================

  Future<void> setServer(String url, {String? user, String? pass}) async {
    baseUrl = url.trim();
    if (user != null) username = user.trim();
    if (pass != null) password = pass;
    await _persist();
    await connect();
  }

  Future<void> connect() async {
    // A second tap on Retry must not race the first: two health checks, two
    // streams and two session refreshes would interleave into a duplicate.
    if (_connecting || _disposed) return;
    _connecting = true;
    try {
      fatalError = null;
      online = false;
      api.baseUrl = baseUrl;
      api.username = username;
      api.password = password;
      notifyListeners();

      try {
        final h = await api.health().timeout(const Duration(seconds: 8));
        serverVersion = h.version;
        online = true;
        fatalError = null;
        notifyListeners();

        _startStream();
        await Future.wait([
          refreshCatalog(),
          refreshSessions(),
          refreshServerInfo(),
          refreshCommands(),
          resyncPrompts(),
        ]);
      } on ApiException catch (e) {
        fatalError = e.message;
        // Health check failed, so refreshSessions() above never ran. Populate
        // the session list from disk anyway, otherwise the cached chat history
        // has no entry point while the server is unreachable.
        await _restoreSessionsFromCache();
      } catch (e) {
        // Anything the client did not already translate (a raw socket error
        // from a half-open handshake, a format error from an HTTP 200 that was
        // not JSON) becomes one actionable line instead of a stack trace.
        if (kDebugMode) debugPrint('connect failed: $e');
        fatalError = _offlineMessage();
        await _restoreSessionsFromCache();
      }
      notifyListeners();
    } finally {
      _connecting = false;
    }
  }

  /// The single user-facing offline string. Kept identical everywhere so the
  /// error screen and any toast agree on what to do about it.
  String _offlineMessage() => S.netUnreachable(baseUrl);

  /// True while a reachability probe is already in flight, so a dropped socket
  /// that fires several triggers does not stack up health checks.
  bool _reachProbeBusy = false;

  /// Asks the server whether it is really gone.
  ///
  /// A dropped event stream is ambiguous: the socket can die while the server
  /// is perfectly healthy (battery freeze, OS-reaped socket, wifi handover),
  /// and the server can die while the socket still looks open. Only the server
  /// can tell them apart, and the UI must not show "Offline" for the first one
  /// or a green dot for the second.
  Future<void> _verifyReachability({bool full = false}) async {
    if (_reachProbeBusy || _disposed) return;
    _reachProbeBusy = true;
    var up = false;
    String? err;
    try {
      final h = await api.health().timeout(const Duration(seconds: 6));
      serverVersion = h.version;
      up = true;
    } on ApiException catch (e) {
      err = e.message;
    } catch (e) {
      if (kDebugMode) debugPrint('reachability probe failed: $e');
      err = _offlineMessage();
    } finally {
      _reachProbeBusy = false;
    }
    if (_disposed) return;

    if (up) {
      online = true;
      // Still reconnecting if the SSE stream itself has not come back yet.
      reconnecting = !(_stream?.live ?? false);
      fatalError = null;
      notifyListeners();
      // The server is up, so the app stays usable and the dot stays green. The
      // stream is simply retrying: if nothing is already connecting, kick it
      // now to collapse its backoff, so a Termux that came back mid-backoff is
      // picked up on the first try instead of up to 15s later.
      final stream = _stream;
      final live = stream?.live ?? false;
      if (stream != null && !live) stream.reconnect();
      // If the stream cannot come up at all (SSE refused while HTTP works),
      // nothing else will ever re-sync, so do it here instead.
      if (!live) {
        unawaited(resyncPrompts());
        final id = current?.id;
        if (id != null && !messagesLoading) unawaited(_resyncMessages(id));
        if (busy) unawaited(_probeBusyState());
      }
      if (full) {
        // Coming back from the background: sessions may have been created,
        // renamed or deleted elsewhere while we were frozen.
        unawaited(refreshSessions());
        unawaited(refreshServerInfo());
      }
      return;
    }

    online = false;
    reconnecting = false;
    fatalError = err ?? _offlineMessage();
    notifyListeners();
  }

  void _startStream() {
    // The old stream is being replaced, not paused: make sure no late callback
    // from it can reconnect into this store.
    unawaited(_stream?.shutdown());
    _stream = EventStream(
      baseUrl: baseUrl,
      username: username,
      password: password,
      onEvent: handleEvent,
      onStatus: _onStreamStatus,
      // The watchdog uses this to tell "the agent is quiet" from "the socket
      // is gone" — without it every long tool call looks like a dead stream.
      isBusy: () => busy,
    );
    // `online` is not forced true here: the stream owns that signal from now
    // on. Claiming it before the SSE handshake is what let the UI sit on a
    // green dot over a stream that had never connected.
    unawaited(_stream!.start());
  }

  /// Stream up/down edges. See [_verifyReachability] for why a down edge is
  /// never applied to `online` directly.
  void _onStreamStatus(bool up) {
    if (_disposed) return;
    if (!up) {
      // Stream dropped but the server may still be reachable. [online] keeps
      // telling the last known truth until the probe decides, so the header has
      // to say "reconnecting" rather than flip straight to "offline" and then
      // back, which reads as two unrelated states.
      reconnecting = true;
      unawaited(_verifyReachability());
      return;
    }
    online = true;
    reconnecting = false;
    fatalError = null;
    notifyListeners();

    // A permission or question asked while we were away has no event left to
    // deliver it, so the prompt card would simply never appear.
    unawaited(resyncPrompts());
    // Events missed while disconnected are gone and cannot be replayed, so the
    // server's own page is the only authority on what really happened.
    final id = current?.id;
    if (id != null && !messagesLoading) unawaited(_resyncMessages(id));
    // A run that finished while we were away never sent its idle event, so the
    // dots would spin for a full 45s silence window before the probe noticed.
    if (busy) unawaited(_probeBusyState());
  }

  bool _connecting = false;

  Future<void> _resyncMessages(String id) async {
    // Resume, a socket re-established by the watchdog and a manual reconnect
    // can all land here within the same second. One in-flight fetch covers
    // them all, and a second would only fight it over `messages`.
    if (_resyncing) return;
    _resyncing = true;
    try {
      // Same page size as openSession — the 60 default silently truncated the
      // history of any long conversation on every resync.
      final fresh = (await api.messages(id, limit: _limit))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      if (current?.id != id || _disposed) return;
      // Merge rather than replace: this fires once a run finishes, and
      // assigning the fresh page over the list used to drop every message the
      // server did not include — and nothing was cached afterwards, so the
      // next open lost them for good.
      messages = _mergeHistory(messages, fresh);
      // The merge can push older messages back to the front, so the pagination
      // cursor has to move with it or "load older" would skip a page.
      _oldestMessageId = messages.isEmpty ? null : messages.first.info.id;
      hasMoreMessages =
          messages.length > fresh.length || fresh.length >= _limit;
      _persistHistory(id, fresh);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to resync messages: $e');
    } finally {
      _resyncing = false;
    }
  }

  bool _resyncing = false;

  Future<void> refreshServerInfo() async {
    try {
      paths = await api.paths();
      vcs = await api.vcs();
    } catch (e) {
      debugPrint('Failed to refresh server info: $e');
    }
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    try {
      agents = await api.agents();
      providerInfo = await api.providers();
    } catch (e) {
      debugPrint('Failed to refresh catalog: $e');
    }

    if (providerId.isEmpty || modelId.isEmpty) {
      final p = providerInfo;
      if (p != null) {
        final conn = p.connected.isNotEmpty
            ? p.connected
            : p.ordered.map((e) => e.id).toList();
        for (final pid in conn) {
          final prov = p.all.where((e) => e.id == pid).firstOrNull;
          if (prov == null || prov.models.isEmpty) continue;
          final def = p.defaults[pid];
          final pick = prov.models.firstWhere(
            (m) => m.id == def,
            orElse: () => prov.models.first,
          );
          providerId = prov.id;
          modelId = pick.id;
          break;
        }
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setModel(String provider, String model) async {
    providerId = provider;
    modelId = model;
    await _persist();
    notifyListeners();
  }

  Future<void> setAgent(String a) async {
    agent = a;
    await _persist();
    notifyListeners();
  }

  void toggleTool(String id, bool on) {
    if (on) {
      toolsEnabled.add(id);
    } else {
      toolsEnabled.remove(id);
    }
    unawaited(_persist());
    notifyListeners();
  }

  Map<String, bool>? get toolMap =>
      toolsEnabled.isEmpty ? null : {for (final t in toolsEnabled) t: true};

  // =====================================================================
  // sessions
  // =====================================================================

  Future<void> refreshSessions() async {
    sessionsLoading = true;
    sessionsError = null;
    notifyListeners();
    try {
      final list = await api.sessions();
      sessions = list..sort((a, b) => b.updated.compareTo(a.updated));
      if (current != null) {
        final i = sessions.indexWhere((s) => s.id == current!.id);
        if (i >= 0) current = sessions[i];
      }
      _persistSessions(sessions);
    } on ApiException catch (e) {
      sessionsError = e.message;
      fatalError = e.message;
      // The server is unreachable. Without the cached session list the whole
      // history cache is unreachable too — there is nothing to tap open.
      await _restoreSessionsFromCache();
    } catch (e) {
      sessionsError = e.toString();
      await _restoreSessionsFromCache();
    } finally {
      sessionsLoading = false;
      notifyListeners();
    }
  }

  void _persistSessions(List<Session> list) {
    final rows = list
        .where((s) => s.id.isNotEmpty)
        .map((s) => {'id': s.id, 'raw': s.toMap(), 'updated': s.updated})
        .toList();
    if (rows.isEmpty) return;
    unawaited(ChatDB.instance.saveSessions(rows));
  }

  /// Falls back to the on-disk session list so cached chats stay reachable
  /// offline. Leaves an existing online list alone.
  Future<void> _restoreSessionsFromCache() async {
    if (sessions.isNotEmpty) return;
    try {
      final rows = await ChatDB.instance.loadSessions();
      if (rows.isEmpty) return;
      final list =
          rows
              .map((r) => Session.fromJson(r))
              .where((s) => s.id.isNotEmpty)
              .toList()
            ..sort((a, b) => b.updated.compareTo(a.updated));
      if (list.isEmpty) return;
      sessions = list;
      if (kDebugMode) debugPrint('restored ${list.length} sessions from cache');
    } catch (e) {
      if (kDebugMode) debugPrint('session cache read failed: $e');
    }
  }

  Future<Session?> newSession({String? title}) async {
    try {
      final s = await api.createSession(
        title: title,
        agent: agent,
        model: providerId.isEmpty
            ? null
            : {'providerID': providerId, 'id': modelId},
      );
      await refreshSessions();
      await openSession(s.id);
      return s;
    } on ApiException catch (e) {
      _toast(e.message);
      return null;
    }
  }

  Future<void> openSession(String id) async {
    // Land the previous session's last streamed chunk before moving on.
    await _flushHistory();
    // Invalidate any in-flight history loads for the old session.
    _historyLoadGen++;
    current =
        sessions.where((s) => s.id == id).firstOrNull ?? await _safeSession(id);
    messages = [];
    _clearLocalEcho();
    sessionError = null;
    liveDiff = [];
    todos = [];
    _oldestMessageId = null;
    hasMoreMessages = false;
    _limit = pageLimit;
    messagesLoading = true;
    notifyListeners();
    try {
      // Paint cached history first so the chat is readable immediately, and
      // stays readable if the server never answers.
      final cached = await _cachedHistory(id);
      if (cached.isNotEmpty) {
        messages = cached;
        _oldestMessageId = cached.first.info.id;
        hasMoreMessages = true;
        notifyListeners();
      }
      final fetched = (await api.messages(id, limit: _limit))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      // Merge, don't replace: the server page is capped at [_limit], and
      // assigning it over `messages` used to drop all older history.
      messages = _mergeHistory(cached, fetched);
      _oldestMessageId = messages.isEmpty ? null : messages.first.info.id;
      // More to show if the merge kept older cached pages, or if the server
      // page came back full (so there is likely another page behind it).
      hasMoreMessages =
          messages.length > fetched.length || fetched.length >= _limit;
      _persistHistory(id, fetched);
      final st = asMap(await api.sessionStatus())[id];
      busy = st != null && asStr(asMap(st)['type']) == 'busy';
      busyStatus = busy ? asStr(asMap(st)['message'], 'busy') : '';
      if (busy) _startBusyTimer();
      unawaited(refreshTodos());
      unawaited(refreshDiff());
    } on ApiException catch (e) {
      sessionError = e.message;
    } catch (e) {
      // Anything else must not escape: the caller awaits this before pushing
      // the chat route, so a throw here left the user tapping a dead row, and
      // skipping the reset below left the list spinning forever.
      sessionError = e.toString();
      if (kDebugMode) debugPrint('openSession($id) failed: $e');
    }
    messagesLoading = false;
    notifyListeners();
  }

  Future<Session?> _safeSession(String id) async {
    try {
      return await api.session(id);
    } catch (e) {
      debugPrint('Failed to fetch session $id: $e');
      return null;
    }
  }

  Future<void> renameSession(String id, String title) async {
    try {
      await api.renameSession(id, title);
      await refreshSessions();
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<bool> deleteSession(String id) async {
    try {
      await api.deleteSession(id);
      if (current?.id == id) {
        _historyLoadGen++;
        current = null;
        messages = [];
      }
      unawaited(ChatDB.instance.clearSession(id));
      unawaited(ChatDB.instance.deleteSessionRow(id));
      await refreshSessions();
      return true;
    } on ApiException catch (e) {
      _toast(e.message);
      return false;
    }
  }

  Future<Session?> forkSession(String id, {String? messageId}) async {
    try {
      final s = await api.fork(id, messageId: messageId);
      await refreshSessions();
      return s;
    } on ApiException catch (e) {
      _toast(e.message);
      return null;
    }
  }

  Future<void> shareSession(String id) async {
    try {
      await api.share(id);
      await refreshSessions();
      _toast(S.shareLinkCreated);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> unshareSession(String id) async {
    try {
      await api.unshare(id);
      await refreshSessions();
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> abortSession() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.abort(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
    _clearBusyTimer();
    busy = false;
    busyStatus = '';
    // Stop pressed: the aborted message never gets a completion stamp, so its
    // dots would keep spinning for the rest of the session.
    _settleStuckStreaming();
    notifyListeners();
  }

  // =====================================================================
  // todos / diff
  // =====================================================================

  Future<void> refreshTodos() async {
    final id = current?.id;
    if (id == null) return;
    try {
      todos = await api.todos(id);
    } catch (e) {
      debugPrint('Failed to refresh todos: $e');
    }
    notifyListeners();
  }

  Future<void> refreshDiff() async {
    final id = current?.id;
    if (id == null) return;
    try {
      liveDiff = await api.diff(id);
    } catch (e) {
      debugPrint('Failed to refresh diff: $e');
    }
    notifyListeners();
  }

  /// Newest-page size used when opening a session.
  ///
  /// This is deliberately generous. The documented `before` query parameter
  /// answers `HTTP 400 {"_tag":"BadRequest"}` for *any* value on opencode
  /// 1.18.27, so server-side backwards pagination is unavailable there — a
  /// small limit would permanently hide everything but the newest page.
  static const pageLimit = 500;

  /// Current page size; widened on demand for unusually long conversations.
  int _limit = pageLimit;

  /// Adds older messages in front of the loaded history, skipping any the
  /// server already gave us, and caches them.
  void _prependHistory(String id, List<ChatMessage> older) {
    if (older.isEmpty) return;
    final known = {for (final m in messages) m.info.id};
    final fresh = older.where((m) => !known.contains(m.info.id)).toList();
    if (fresh.isEmpty) return;
    messages = [...fresh, ...messages];
    // The page is all older turns, so an optimistic bubble still sitting in the
    // list can only have been superseded by a confirmed message already in it.
    _stripEchoedOptimistic(messages, messages);
    _oldestMessageId = messages.first.info.id;
    _persistHistory(id, fresh);
  }

  /// Fallback for servers that reject `before`: refetch a wider prefix and
  /// splice in the older messages that reveals. Uses only `limit`, which every
  /// build supports, so history stays reachable instead of stopping dead at
  /// the first page.
  Future<void> _widenHistory(String id, [int? gen]) async {
    final wider = (_limit * 4).clamp(
      0,
      5000,
    ); // Cap at 5000 to prevent unbounded growth
    final all = (await api.messages(id, limit: wider))
        .map((e) => ChatMessage(e.info, e.parts))
        .where((m) => !m.info.summary)
        .toList();
    // Guard against session switch during the await.
    if (gen != null && gen != _historyLoadGen) return;
    if (current?.id != id || _disposed) return;
    if (all.length <= messages.length) {
      hasMoreMessages = false;
      return;
    }
    final known = {for (final m in messages) m.info.id};
    final extra = all.where((m) => !known.contains(m.info.id)).toList();
    if (extra.isEmpty) {
      hasMoreMessages = false;
      return;
    }
    _limit = wider;
    _prependHistory(id, extra);
    // A short page means the server had nothing more to give.
    hasMoreMessages = all.length >= wider;
  }

  Future<void> loadOlderMessages() async {
    final id = current?.id;
    final gen = _historyLoadGen;
    if (id == null || _oldestMessageId == null || messagesLoading) return;
    messagesLoading = true;
    notifyListeners();
    try {
      // Preferred path: ask for the page before the oldest message we hold.
      final fetched =
          (await api.messages(id, limit: 60, before: _oldestMessageId))
              .map((e) => ChatMessage(e.info, e.parts))
              .where((m) => !m.info.summary)
              .toList();
      // Guard against session switch during the await.
      if (gen != _historyLoadGen || current?.id != id || _disposed) return;
      if (fetched.isNotEmpty) {
        _prependHistory(id, fetched);
        hasMoreMessages = fetched.length >= 60;
      } else {
        hasMoreMessages = false;
      }
    } on ApiException {
      // `before` is unimplemented on some builds. Widening `limit` recovers the
      // history instead of giving up and hiding it permanently.
      await _widenHistory(id, gen);
    } catch (e) {
      debugPrint('Failed to load older messages: $e');
      // Guard against session switch during the await.
      if (gen != _historyLoadGen || current?.id != id || _disposed) return;
      hasMoreMessages = false;
    }
    if (gen == _historyLoadGen && current?.id == id) {
      messagesLoading = false;
      notifyListeners();
    }
  }

  // =====================================================================
  // prompting
  // =====================================================================

  void addAttachment(PendingAttachment a) {
    attachments.add(a);
    notifyListeners();
  }

  void removeAttachment(int i) {
    if (i >= 0 && i < attachments.length) attachments.removeAt(i);
    notifyListeners();
  }

  void clearAttachments() {
    attachments.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> _partPayload() {
    final parts = <Map<String, dynamic>>[];
    for (final a in attachments) {
      parts.add({
        'type': 'file',
        'mime': a.mime,
        'filename': a.name,
        'url': a.dataUrl,
      });
    }
    return parts;
  }

  /// Send a chat message. Returns immediately; output streams in via SSE.
  /// Prompts typed while a run is in flight, flushed in order when it ends.
  ///
  /// The composer used to swallow them: the send button is a Stop button while
  /// busy, so anything typed during a long run was either discarded or sent as
  /// a second concurrent prompt, which the server then interleaved.
  final List<String> _queued = [];

  List<String> get queued => List.unmodifiable(_queued);
  bool get hasQueued => _queued.isNotEmpty;

  /// Send now, or queue if a run is already in flight.
  Future<void> sendOrQueue(
    String text, {
    List<Map<String, dynamic>> extraParts = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && extraParts.isEmpty) return;
    if (busy) {
      _queued.add(text);
      notifyListeners();
      return;
    }
    await send(text, extraParts: extraParts);
  }

  /// Sends the next queued prompt. Called when a run ends.
  Future<void> _flushQueue() async {
    if (_queued.isEmpty || busy || _disposed) return;
    final next = _queued.removeAt(0);
    notifyListeners();
    try {
      await send(next);
    } catch (_) {
      // The failure path already surfaced an error bar; keep the rest queued.
      return;
    }
  }

  Future<void> send(
    String text, {
    List<Map<String, dynamic>> extraParts = const [],
  }) async {
    var sid = current?.id;
    if (sid == null) {
      final s = await newSession();
      if (s == null) return;
      sid = s.id;
    }

    final parts = [..._partPayload(), ...extraParts];
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) parts.insert(0, {'type': 'text', 'text': text});
    if (parts.isEmpty) return;
    clearAttachments();

    // Only one prompt is in flight, so the echo hand-over is 1:1. Clearing both
    // here keeps a send the server never echoed from stealing the next echo.
    _clearLocalEcho();
    messages.removeWhere(
      (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
    );

    // Optimistically add user message for instant feedback
    final userMsgId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = Message(
      id: userMsgId,
      sessionId: sid,
      role: 'user',
      parentId: '',
      agent: agent,
      providerId: providerId,
      modelId: modelId,
      created: DateTime.now().millisecondsSinceEpoch,
      cost: 0,
      tokens: Tokens(0, 0, 0, 0, 0),
      finishReason: '',
      summaryText: '',
      summary: false,
      raw: {'optimistic': true},
    );
    final userParts = parts
        .where((p) => p['type'] == 'text' || p['type'] == 'file')
        .map((p) {
          if (p['type'] == 'text') {
            return Part.fromJson({
              'id': 'part-$userMsgId',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'text',
              'text': p['text'],
            });
          } else {
            return Part.fromJson({
              'id': 'part-$userMsgId-${p['filename']}',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'file',
              'filename': p['filename'],
              'mime': p['mime'],
              'url': p['url'],
            });
          }
        })
        .toList();
    messages.add(ChatMessage(userMsg, userParts));
    notifyListeners();

    sessionError = null;
    await _sendParts(sid, parts);
  }

  // ---- busy watchdog -------------------------------------------------
  // FIX: the old 5-minute one-shot timer was never reset, so any long agent
  // run showed a fake "timeout". Now it only fires after 5 min of *silence*.
  Timer? _busyTimer;
  bool _busyProbeActive = false;
  int _probeFailures = 0;
  DateTime _lastActivity = DateTime.now();

  void _touchActivity() {
    _probeFailures = 0;
    _lastActivity = DateTime.now();
  }

  void _startBusyTimer() {
    _touchActivity();
    if (_busyTimer?.isActive ?? false) return;
    _busyTimer = Timer.periodic(const Duration(seconds: 15), (t) {
      if (_disposed || !busy) {
        t.cancel();
        _busyTimer = null;
        return;
      }
      final silent = DateTime.now().difference(_lastActivity);
      // 45s of silence used to mean "hang" and the UI spun until the 5 min
      // bail-out. The stream can simply have dropped an event, so ask the
      // server instead of guessing: it is the only authority on run state.
      if (silent > const Duration(seconds: 45)) {
        unawaited(_probeBusyState());
        return;
      }
      if (silent > const Duration(minutes: 5)) {
        t.cancel();
        _busyTimer = null;
        busy = false;
        busyStatus = '';
        _settleStuckStreaming();
        sessionError = S.errNoActivity;
        notifyListeners();
      }
    });
  }

  /// Asks the server whether the current session is still running. Only a
  /// definite "not busy" clears the spinner; a failed probe keeps waiting so a
  /// flaky network can't unlock the composer mid-run.
  Future<void> _probeBusyState() async {
    final id = current?.id;
    if (id == null || _disposed || !busy) return;
    // Don't stack probes on a slow link.
    if (_busyProbeActive) return;
    _busyProbeActive = true;
    try {
      final st = asMap(await api.sessionStatus())[id];
      _probeFailures = 0;
      // Session unknown to the server => nothing is running for it.
      if (st == null) {
        _clearBusyTimer();
        busy = false;
        busyStatus = '';
        _settleStuckStreaming();
        notifyListeners();
        return;
      }
      if (asStr(asMap(st)['type']) != 'busy') {
        _clearBusyTimer();
        busy = false;
        busyStatus = '';
        // The run is over server-side; if its closing `message.updated` was lost
        // the dots would spin forever, so retire them before re-syncing.
        _settleStuckStreaming();
        // The idle event was lost: re-sync so the answer is not left cut off.
        unawaited(_resyncMessages(id));
        notifyListeners();
      } else {
        // Still genuinely running: restart the silence window.
        _touchActivity();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('busy probe failed: $e');
      // A flaky link must not unlock the composer mid-run, so the window is
      // still restarted — but after a few failures we stop doing that, which is
      // what lets the 5-minute bail-out above actually fire instead of the probe
      // resetting the clock forever.
      _probeFailures++;
      if (_probeFailures < 3) _touchActivity();
    } finally {
      _busyProbeActive = false;
    }
  }

  void _clearBusyTimer() {
    _busyTimer?.cancel();
    _busyTimer = null;
  }

  /// Kills the typing dots on trailing assistant messages the server never
  /// closed out. Only called on paths where the store has already decided the
  /// run is over (abort, error, lost-`message.updated` probe), so it can never
  /// cut a genuinely live message short — a normal `message.updated` with a
  /// completion stamp is what ends the dots in the happy path.
  ///
  /// Returns true when something changed, so callers can skip a pointless
  /// rebuild.
  bool _settleStuckStreaming() {
    var changed = false;
    for (final m in messages) {
      if (m.streaming) {
        m.settled = true;
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _sendParts(String sid, List<Map<String, dynamic>> parts) async {
    if (providerId.isEmpty || modelId.isEmpty) {
      _toast(S.pickModelFirst);
      return;
    }
    // Was: a system prompt instructing the model to treat Roman-script Hinglish
    // as Hindi and reply in the same script. That is what produced the Hinglish
    // UI strings in the first place - the app was asking the agent to be
    // bilingual while its own chrome was supposed to be one language.
    // One language, English, everywhere.
    // Instant feedback: show "working" right away, don't wait for the server.
    busy = true;
    busyStatus = '';
    _startBusyTimer();
    notifyListeners();
    try {
      await api.promptAsync(
        sid,
        providerId: providerId,
        modelId: modelId,
        agent: agent,
        parts: parts,
        tools: toolMap,
      );
    } on ApiException catch (e) {
      _clearBusyTimer();
      busy = false;
      messagesLoading = false;
      sessionError = e.message;
      // Remove the optimistic user message on error
      messages.removeWhere(
        (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
      );
      notifyListeners();
    } catch (e) {
      _clearBusyTimer();
      busy = false;
      messagesLoading = false;
      sessionError = e.toString();
      // Remove the optimistic user message on error
      messages.removeWhere(
        (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
      );
      notifyListeners();
    }
  }

  /// Runs a slash command by name.
  Future<void> runCommand(String name, String args) async {
    var sid = current?.id;
    if (sid == null) {
      final s = await newSession();
      if (s == null) return;
      sid = s.id;
    }
    // Same instant-feedback contract as send(): a slash command runs a full
    // agent turn but produced no indicator at all until the server's first
    // status event, so the UI looked inert for seconds.
    busy = true;
    busyStatus = '';
    _startBusyTimer();
    notifyListeners();
    try {
      await api.post(
        '/session/$sid/command',
        body: {
          'command': name,
          'arguments': args,
          if (agent.isNotEmpty) 'agent': agent,
          if (providerId.isNotEmpty)
            'model': {'providerID': providerId, 'modelID': modelId},
          if (toolMap != null) 'tools': toolMap,
        },
        timeout: const Duration(minutes: 30),
      );
    } on ApiException catch (e) {
      _clearBusyTimer();
      busy = false;
      sessionError = e.message;
      _settleStuckStreaming();
      notifyListeners();
    }
  }

  /// Built-in session actions that need a message id.
  Future<void> summarize() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.summarize(id, providerId: providerId, modelId: modelId);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> revert(String messageId, {String? partId}) async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.revert(id, messageId: messageId, partId: partId);
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> unrevert() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.unrevert(id);
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> initAgents() async {
    final id = current?.id;
    if (id == null || messages.isEmpty) {
      _toast(S.sendMessageFirst);
      return;
    }
    final lastUser = messages.lastWhere(
      (m) => m.info.isUser,
      orElse: () => messages.firstWhere(
        (m) => m.info.isUser,
        orElse: () => messages.first,
      ),
    );
    try {
      await api.init(
        id,
        messageId: lastUser.info.id,
        providerId: providerId,
        modelId: modelId,
      );
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  // =====================================================================
  // shell / files (uses a private utility session so the chat stays clean)
  // =====================================================================

  static const utilSessionTitle = '__opencode_app_util__';
  String? _utilSessionId;

  Future<String> _utilSession() async {
    if (_utilSessionId != null) {
      try {
        await api.session(_utilSessionId!);
        return _utilSessionId!;
      } catch (e) {
        debugPrint('Util session validation failed: $e');
        _utilSessionId = null;
      }
    }
    final existing = sessions
        .where((s) => s.title == utilSessionTitle)
        .firstOrNull;
    if (existing != null) {
      _utilSessionId = existing.id;
      return existing.id;
    }
    final s = await api.createSession(title: utilSessionTitle);
    _utilSessionId = s.id;
    if (!_disposed) unawaited(refreshSessions());
    return s.id;
  }

  Future<({int exit, String output})> runShell(String command) async {
    final sid = await _utilSession();
    final r = await api.shell(sid, command: command, agent: agent);
    var out = '';
    var code = 0;
    var ran = false;
    for (final p in r.parts) {
      if (p.type != 'tool') continue;
      ran = true;
      // A later part succeeding must never mask an earlier failure, otherwise
      // `writeFile` reports success for a half-applied command.
      final e = p.exitCode ?? 0;
      if (e != 0) code = e;
      // Tool-level failure with no `exit` in metadata still has to fail.
      if (e == 0 && p.status == ToolStatus.error) code = 1;
      final stdout = p.output;
      final stderr = p.errorText;
      if (stdout.isNotEmpty) {
        out += (out.isEmpty ? '' : '\n') + stdout;
      }
      if (stderr.isNotEmpty) {
        out += (out.isEmpty ? '' : '\n') + stderr;
      }
    }
    if (!ran) {
      // No tool part at all: the server never executed anything. Returning 0
      // here is exactly what made writes/deletes fail *silently*.
      return (exit: 127, output: out.isEmpty ? S.shellNoOutput : out);
    }
    return (exit: code, output: out);
  }

  Future<void> writeFile(String path, String content) async {
    // No app-side storage permission gate: the file is written by the SERVER
    // (its own shell), not by this app's process. Asking for
    // MANAGE_EXTERNAL_STORAGE here blocked saves for no reason — the failure
    // that matters is the server's, and it surfaces as a shell error below.
    final b64 = base64Encode(utf8.encode(content));
    // Chunked so very large files stay inside ARG_MAX.
    const chunk = 24000;
    final chunks = <String>[];
    for (var i = 0; i < b64.length; i += chunk) {
      chunks.add(b64.substring(i, min(i + chunk, b64.length)));
    }
    final q = _shellQuote(path);
    final dir = _shellQuote(_parentDir(path));
    // Decode into a sibling temp file, then `mv` it into place:
    //  - `mkdir -p` so a not-yet-existing folder is not a silent failure
    //  - `: > $tmp` truncates any leftover temp from an earlier failed write
    //    (appending to it used to prepend garbage to the new content)
    //  - the temp is always created, so an empty file also succeeds
    //  - `mv` is atomic: the original is only replaced once the new content is
    //    fully decoded, so a failed save can never destroy what was there
    final tmp = '$q.oc-tmp';
    var cmd = 'mkdir -p $dir && : > $tmp';
    for (final c in chunks) {
      cmd += " && printf '%s' '$c' >> $tmp";
    }
    cmd += ' && base64 -d $tmp > $tmp.oc-out && mv $tmp.oc-out $q';
    cmd += ' && rm -f $tmp && test -f $q';
    final r = await runShell(cmd);
    if (r.exit != 0) {
      // Best-effort cleanup so a failed save leaves no temp litter behind.
      unawaited(runShell('rm -f $tmp $tmp.oc-out'));
      throw ApiException(
        1,
        'WriteFailed',
        r.output.isEmpty ? 'Write fail: $path' : r.output,
      );
    }
  }

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

  Future<void> deleteEntry(String path) async {
    final r = await runShell('rm -rf ${_shellQuote(path)}');
    if (r.exit != 0) {
      throw ApiException(
        1,
        'DeleteFailed',
        r.output.isEmpty ? S.filesDeleteFailed(path) : r.output,
      );
    }
  }

  Future<void> mkdirEntry(String path) async {
    final r = await runShell('mkdir -p ${_shellQuote(path)}');
    if (r.exit != 0) {
      throw ApiException(
        1,
        'MkdirFailed',
        r.output.isEmpty ? S.filesFolderFailed(path) : r.output,
      );
    }
  }

  // =====================================================================
  // commands / config / mcp
  // =====================================================================

  Future<void> refreshCommands() async {
    try {
      commands = await api.commands();
      skills = await api.skills();
    } catch (e) {
      debugPrint('Failed to refresh commands: $e');
    }
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    try {
      config = await api.config();
      mcp = await api.mcp();
      lsp = await api.lsp();
      formatters = await api.formatters();
    } catch (e) {
      debugPrint('Failed to refresh config: $e');
    }
    notifyListeners();
  }

  Future<void> saveConfig(Map<String, dynamic> patch) async {
    try {
      config = await api.patchConfig(patch);
      _toast(S.configSaved);
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }

  /// Enables server config to allow tools to access directories outside the workspace.
  Future<void> enableExternalDirectoryAccess() async {
    try {
      await api.patchConfig({
        'permission': {
          'edit': 'allow',
          'bash': 'allow',
          'external_directory': 'allow',
        },
      });
      await refreshConfig();
      _toast(S.externalPermEnabled);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> addMcp(
    String name,
    String type,
    String value,
    List<String> args,
  ) async {
    try {
      final cfg = type == 'remote'
          ? {'type': 'remote', 'url': value, 'enabled': true}
          : {
              'type': 'local',
              'command': [value, ...args],
              'enabled': true,
            };
      await api.mcpAdd(name, cfg);
      mcp = await api.mcp();
      _toast(S.added(name));
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }

  // =====================================================================
  // permissions / questions
  // =====================================================================

  Future<void> loadPending() async {
    if (!online) return;
    try {
      final qlist = await api.pendingQuestions();
      questions = qlist
          .where((e) => asStr(e['id']).isNotEmpty)
          .map(QuestionReq.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Failed to load pending questions: $e');
    }
    try {
      final plist = await api.pendingPermissions();
      permissions = plist
          .where((e) => asStr(e['id']).isNotEmpty)
          .map((e) => PermissionReq.fromJson(asMap(e)))
          .where((p) => p.id.isNotEmpty)
          .toList();
      // A fetch failure must NOT empty the list: the requests we already hold
      // are still pending, and clearing them on a flaky link is exactly how a
      // prompt goes missing. The catch below leaves the old list in place.
    } catch (e) {
      debugPrint('Failed to load pending permissions: $e');
    }
    notifyListeners();
  }

  /// Re-fetch both pending lists. Called on connect, on every stream-up edge
  /// and on resume, because an event asked while the socket was down is gone
  /// for good and the server's own list is the only authority left.
  Future<void> resyncPrompts() async {
    // Snapshot the ids we already knew: a request that is merely still pending
    // must not undo a dismissal, but a genuinely new one has to be shown.
    final known = <String>{
      for (final p in permissions) p.id,
      for (final q in questions) q.id,
    };
    await loadPending();
    if (_disposed) return;
    if (!awaitingPrompt) {
      promptSheetDismissed = false;
    } else {
      // A request we had never seen before has to be shown, however the sheet
      // was left. One that was already on screen when it was dismissed stays
      // dismissed, or every reconnect would reopen a card the user closed.
      final fresh = [
        ...permissions.where((e) => !known.contains(e.id)),
        ...questions.where((e) => !known.contains(e.id)),
      ];
      if (fresh.isNotEmpty) promptSheetDismissed = false;
    }
    notifyListeners();
  }

  Future<void> answerPermission(PermissionReq p, String response) async {
    permissions.removeWhere((e) => e.id == p.id);
    _onPromptRemoved();
    notifyListeners();
    try {
      if (p.sessionId.isNotEmpty) {
        await api.replyPermission(p.sessionId, p.id, response);
      } else {
        await api.replyPermissionV1(p.id, response);
      }
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> answerQuestion(QuestionReq q, List<List<String>> answers) async {
    questions.removeWhere((e) => e.id == q.id);
    _onPromptRemoved();
    notifyListeners();
    try {
      await api.answerQuestion(q.id, answers);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> rejectQuestion(QuestionReq q) async {
    questions.removeWhere((e) => e.id == q.id);
    _onPromptRemoved();
    notifyListeners();
    try {
      await api.rejectQuestion(q.id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  // =====================================================================
  // event handling
  // =====================================================================

  void handleEvent(OcEvent e) {
    if (_disposed) return;
    // FIX: one malformed event must never kill the handler / stream.
    try {
      _handleEvent(e);
    } catch (err, st) {
      if (kDebugMode) debugPrint('handleEvent(${e.type}) failed: $err\n$st');
    }
  }

  void _handleEvent(OcEvent e) {
    final p = e.properties;

    switch (e.type) {
      case 'message.updated':
        _touchActivity();
        _upsertMessage(Message.fromJson(asMap(p['info'])));
        break;
      case 'message.part.updated':
        _touchActivity();
        _upsertPart(Part.fromJson(asMap(p['part'])));
        break;
      case 'message.part.delta':
        _touchActivity();
        _applyDelta(asStr(p['partID']), asStr(p['field']), asStr(p['delta']));
        break;
      case 'message.part.removed':
        _removePart(asStr(p['sessionID']), asStr(p['partID']));
        break;
      case 'message.removed':
        _removeMessage(asStr(p['sessionID']), asStr(p['messageID']));
        break;
      case 'session.status':
        if (_isCurrent(asStr(p['sessionID']))) {
          final st = asMap(p['status']);
          final t = asStr(st['type']);
          final wasBusy = busy;
          busy = t == 'busy';
          busyStatus = busy ? asStr(st['message'], 'busy') : '';
          if (wasBusy && !busy) {
            _clearBusyTimer();
            // The server declared the session idle, so a prompt typed during
            // the run is safe to release.
            unawaited(_flushQueue());
          }
          if (busy) _startBusyTimer();
          notifyListeners();
        }
        break;
      case 'session.idle':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          busy = false;
          busyStatus = '';
          messagesLoading = false;
          notifyListeners();
          // The run is over: commit the tail now instead of waiting out the
          // flush debounce, so killing the app here still keeps the answer.
          unawaited(_flushHistory());
          unawaited(_flushQueue());
          if (!_disposed) {
            unawaited(refreshTodos());
            unawaited(refreshDiff());
            unawaited(refreshSessions());
          }
        }
        break;
      case 'session.error':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          sessionError = _errorText(asMap(p['error']));
          busy = false;
          messagesLoading = false;
          // A failed run's message never gets a completion stamp either.
          _settleStuckStreaming();
          notifyListeners();
          unawaited(_flushQueue());
        }
        break;
      case 'session.updated':
      case 'session.created':
        _upsertSession(Session.fromJson(asMap(p['info'])));
        break;
      case 'session.deleted':
        final info = p['info'];
        final delId = asStr(
          p['sessionID'],
          info != null ? asStr(asMap(info)['id']) : '',
        );
        sessions.removeWhere((s) => s.id == delId);
        if (current?.id == delId) {
          current = null;
          messages = [];
        }
        if (delId.isNotEmpty) {
          unawaited(ChatDB.instance.clearSession(delId));
          unawaited(ChatDB.instance.deleteSessionRow(delId));
        }
        notifyListeners();
        break;
      case 'session.diff':
        if (_isCurrent(asStr(p['sessionID']))) {
          liveDiff = asList(p['diff'])
              .map((e) => FileDiff.fromJson(asMap(e)))
              .toList();
          notifyListeners();
        }
        break;
      case 'permission.asked':
      case 'permission.updated':
      case 'permission.v2.asked':
        final req = e.type == 'permission.v2.asked'
            ? PermissionReq.fromV2(asMap(p))
            : PermissionReq.fromJson(asMap(p));
        if (req.id.isNotEmpty && !permissions.any((x) => x.id == req.id)) {
          permissions.add(req);
          _onPromptAdded();
          notifyListeners();
        }
        break;
      case 'permission.replied':
      case 'permission.v2.replied':
        final id = asStr(p['permissionID'], asStr(p['id']));
        // Answered anywhere — here or in the TUI — drops it on the spot.
        permissions.removeWhere((x) => x.id == id);
        _onPromptRemoved();
        notifyListeners();
        break;
      case 'question.asked':
      case 'question.v2.asked':
        final q = QuestionReq.fromJson(asMap(p));
        if (q.id.isNotEmpty && !questions.any((x) => x.id == q.id)) {
          questions.add(q);
          _onPromptAdded();
          // Question tool pauses the agent — treat as idle for UI so prompt is usable.
          if (_isCurrent(q.sessionId)) {
            _clearBusyTimer();
            busy = false;
            busyStatus = '';
          }
          notifyListeners();
        }
        break;
      case 'question.replied':
      case 'question.rejected':
      case 'question.v2.replied':
        questions.removeWhere(
          (x) => x.id == asStr(p['questionID'], asStr(p['id'])),
        );
        _onPromptRemoved();
        notifyListeners();
        break;
      case 'todo.updated':
        // FIX: debounced. Used to fire an HTTP call + rebuild on every event.
        _debouncedTodos();
        break;
      case 'server.connected':
        online = true;
        notifyListeners();
        break;
      // file.edited / lsp.updated / mcp.tools.changed / installation.updated:
      // no need to refetch todos for these any more.
    }
  }

  String _errorText(Map<String, dynamic> err) {
    final name = asStr(err['name']);
    final data = asMap(err['data']);
    final msg = asStr(data['message'], asStr(err['message']));
    return msg.isEmpty ? (name.isEmpty ? 'Unknown error' : name) : msg;
  }

  // FIX: with no open session, events from other sessions no longer leak into
  // the current message list.
  bool _isCurrent(String sid) =>
      current != null && (sid.isEmpty || current!.id == sid);

  ChatMessage? _messageById(String id) {
    // Newest messages are at the end, and streaming targets them: search backwards.
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].info.id == id) return messages[i];
    }
    return null;
  }

  /// Newest optimistic user row. Only one prompt is in flight at a time, so the
  /// server's echo always belongs to the send that was made last — matching the
  /// *first* optimistic row instead used to delete the wrong bubble.
  /// Prefix of the part ids minted locally in [send] for the optimistic bubble.
  /// Must stay in sync with the `'part-$userMsgId'` ids built there.
  static const String _localPartPrefix = 'part-local-';

  int _optimisticIndex() {
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.info.raw['optimistic'] == true && m.info.role == 'user') return i;
    }
    return -1;
  }

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

  void _clearLocalEcho() {
    _echoForLocal = null;
    _echoInfo = null;
  }

  void _upsertMessage(Message info) {
    if (!_isCurrent(info.sessionId)) return;
    final existing = _messageById(info.id);
    final isRealUser = info.role == 'user' && info.raw['optimistic'] != true;

    if (existing != null) {
      existing.info = info;
      // Part events can arrive before the header; drop the stale local bubble.
      if (isRealUser) {
        final oi = _optimisticIndex();
        if (oi >= 0) messages.removeAt(oi);
      }
    } else if (isRealUser && _optimisticIndex() >= 0) {
      // Server echo of the optimistic user message. Replace it immediately
      // (user messages don't stream parts, so _upsertPart swap never fires).
      final oi = _optimisticIndex();
      if (oi >= 0) messages[oi] = ChatMessage(info, messages[oi].parts);
      _clearLocalEcho();
    } else {
      messages.add(ChatMessage(info, <Part>[]));
    }
    final m = _messageById(info.id);
    if (m != null && current != null) _scheduleFlush(current!.id, m);
    // Transcript-only: nothing outside the message list reads this.
    _scheduleMessageNotify();
  }

  void _upsertPart(Part part) {
    if (!_isCurrent(part.sessionId)) return;
    // The server has real content for the row we drew locally: adopt the real
    // id in place. Swapping here rather than on `message.updated` is what keeps
    // the sent text on screen for the whole hand-over.
    if (_echoForLocal != null && part.messageId == _echoForLocal) {
      final i = _optimisticIndex();
      final info = _echoInfo;
      _clearLocalEcho();
      if (i >= 0 && info != null) {
        final oldParts = messages[i].parts;
        messages[i] = ChatMessage(info, oldParts);
      }
    }
    var msg = _messageById(part.messageId);
    if (msg == null) {
      // The part arrived before its message header; synthesise a placeholder.
      // message.updated will fill in the real info (role etc.) right after.
      final info = Message(
        id: part.messageId,
        sessionId: part.sessionId,
        role: 'assistant',
        parentId: '',
        agent: agent,
        providerId: providerId,
        modelId: modelId,
        created: DateTime.now().millisecondsSinceEpoch,
        cost: 0,
        tokens: Tokens(0, 0, 0, 0, 0),
        finishReason: '',
        summaryText: '',
        summary: false,
        raw: const {},
      );
      msg = ChatMessage(info, <Part>[]);
      messages.add(msg);
    }
    final i = msg.parts.indexWhere((p) => p.id == part.id);
    if (i >= 0) {
      msg.parts[i] = part;
    } else {
      // A row adopted from the optimistic hand-over still carries the local
      // stand-in parts minted in [send]. Dedupe above is by id, so the server's
      // echo was *appended* rather than replacing them, and the bubble rendered
      // the user's text (and every attachment chip) twice. Retire the stand-in
      // this part supersedes — matched on content, not type alone, so sibling
      // attachments are left alone.
      if (!part.id.startsWith(_localPartPrefix)) {
        msg.parts.removeWhere(
          (p) =>
              p.id.startsWith(_localPartPrefix) &&
              p.type == part.type &&
              (part.type == 'file'
                  ? p.filename == part.filename
                  : p.text.trim() == part.text.trim()),
        );
      }
      msg.parts.add(part);
    }
    if (current != null) _scheduleFlush(current!.id, msg);
    _scheduleMessageNotify();
  }

  void _applyDelta(String partId, String field, String delta) {
    if (delta.isEmpty || partId.isEmpty) return;
    // Search newest message first: deltas always belong to the live message.
    for (var mi = messages.length - 1; mi >= 0; mi--) {
      final m = messages[mi];
      for (var i = m.parts.length - 1; i >= 0; i--) {
        if (m.parts[i].id != partId) continue;
        final raw = Map<String, dynamic>.from(m.parts[i].raw);
        raw[field] = '${asStr(raw[field])}$delta';
        m.parts[i] = Part.fromJson(raw);
        if (current != null) _scheduleFlush(current!.id, m);
        _scheduleMessageNotify(); // was notifyListeners() on every single token
        return;
      }
    }
  }

  void _removePart(String sid, String partId) {
    if (!_isCurrent(sid)) return;
    final affected = <ChatMessage>[];
    for (final m in messages) {
      final before = m.parts.length;
      m.parts.removeWhere((p) => p.id == partId);
      if (m.parts.length != before) affected.add(m);
    }
    // Re-mark only the affected messages so the dropped part is not
    // resurrected from the cache on the next open.
    if (current != null) {
      for (final m in affected) {
        _scheduleFlush(current!.id, m);
      }
    }
    _scheduleMessageNotify();
  }

  void _removeMessage(String sid, String messageId) {
    if (!_isCurrent(sid)) return;
    // The row still carries the local id, so a plain `removeWhere` missed it and
    // left a ghost bubble behind.
    if (messageId == _echoForLocal) {
      _clearLocalEcho();
      final i = _optimisticIndex();
      if (i >= 0) messages.removeAt(i);
    }
    messages.removeWhere((m) => m.info.id == messageId);
    if (current != null) {
      unawaited(ChatDB.instance.deleteMessage(current!.id, messageId));
    }
    _scheduleMessageNotify();
  }

  void _upsertSession(Session s) {
    final i = sessions.indexWhere((x) => x.id == s.id);
    if (i >= 0) {
      sessions[i] = s;
    } else {
      sessions.insert(0, s);
    }
    sessions.sort((a, b) => b.updated.compareTo(a.updated));
    if (current?.id == s.id) current = s;
    // Keep the on-disk session list current so the chat survives a cold start
    // with the server down.
    unawaited(ChatDB.instance.saveSession(s.id, s.toMap(), s.updated));
    // Stays global: the sessions list is a different view and must repaint.
    _scheduleNotify();
  }

  // =====================================================================

  String? _lastToast;
  void _toast(String m) => _lastToast = m;
  String? takeToast() {
    final t = _lastToast;
    _lastToast = null;
    return t;
  }

  /// Call this on app resume to reconnect the SSE stream if needed.
  void reconnectStream() {
    if (_disposed) return;
    // `reconnect` now really does revive a paused stream. It used to bail out
    // on the `_stopped` flag that `pauseConnections` had set, so the very first
    // background/foreground cycle left the app permanently deaf: no events, no
    // streaming, red dot, and no retry loop because the timers were gone too.
    _stream?.reconnect();
  }

  void pauseConnections() {
    if (_disposed) return;
    try {
      // Reversible: the socket is released now, `reconnect` brings it back.
      unawaited(_stream?.stop());
    } catch (e) {
      debugPrint('Failed to pause connections: $e');
    }
    _clearBusyTimer();
    // Android can kill a backgrounded process without further notice; commit the
    // streamed tail now rather than relying on the debounce timer.
    unawaited(_flushHistory());
  }

  /// Foreground again. Android may have frozen the process for minutes, so the
  /// socket is assumed dead rather than trusted: reconnect at once (which also
  /// collapses the retry backoff) and re-verify the server, because a Termux
  /// restart means a new process, possibly a new version and a fresh session
  /// list.
  void resumeConnections() {
    if (_disposed) return;
    reconnectStream();
    unawaited(_verifyReachability(full: true));
  }

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
