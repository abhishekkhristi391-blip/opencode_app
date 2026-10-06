part of '../voice_service.dart';

// The fields, constants, constructor, dispose() and static helpers of VoiceService live
// here. Its behaviour is split by topic into VoiceService* extensions in voice_service_<topic>.dart.
/// Dictation, read-aloud and hands-free conversation for the chat screen.
///
/// Everything voice lives here: the platform plugins, the state machine, the
/// synthesiser queue and the conversation loop. Widgets read [phase]/[partial]
/// and call the verbs, so no screen ends up with its own half-copy of "am I
/// listening right now?".
///
/// The chat store is used exactly the way the composer uses it -
/// [OcStore.sendOrQueue] - and is never modified. Hands-free borrows the app's
/// send path instead of growing a second one.
class VoiceService extends ChangeNotifier {
  VoiceService(this._store) {
    _sessionId = _store.current?.id;
    // One listener for the whole app. A subscription per screen was the
    // alternative, and it is how two loops end up talking over each other when a
    // session switch lands mid-sentence.
    _store.addListener(_onStore);
  }

  final OcStore _store;

  /// speech_to_text is a singleton internally, so this is one instance for the
  /// process whichever screen reaches it first.
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  // ---------------------------------------------------------------- tuning

  /// How long a pause ends one utterance. Long enough that a comma is not a
  /// sentence, short enough that finishing a thought feels immediate.
  static const Duration _silenceTimeout = Duration(seconds: 3);

  /// Hard cap on one listen session. Without it a wedged recogniser holds the
  /// microphone forever and hands-free can never wind down.
  static const Duration _listenCap = Duration(seconds: 30);

  /// The recogniser waits this long after a reply finishes: the synthesiser's
  /// tail is still in the air and would be transcribed as the user's turn.
  static const Duration _echoGuard = Duration(milliseconds: 700);

  /// Two empty recognitions in a row end a hands-free session. Nobody is
  /// talking to it any more and an open microphone is just a battery cost.
  static const int _emptyLimit = 2;

  /// And so does this much silence with the microphone open.
  static const Duration _idleLimit = Duration(minutes: 2);

  // ------------------------------------------------------------- observable

  VoicePhase _phase = VoicePhase.idle;
  VoiceFailure? _failure;
  VoiceFailure? _notice;
  String _partial = '';
  double _level = 0;
  bool _conversation = false;

  // -------------------------------------------------------------- platform

  bool _recognizerReady = false;
  bool _recognizerMissing = false;
  bool _speechReady = false;
  bool _permissionDenied = false;

  /// Bumped whenever something takes the microphone away from a listen attempt
  /// that is still in flight.
  ///
  /// Initialising the recogniser is a platform call that can take a second and
  /// comes back with a permission dialog. Without a token, tapping stop while
  /// that call is outstanding leaves a promise that opens the microphone a
  /// moment after the user asked it to stop - which is exactly the kind of bug
  /// that makes people revoke the permission for good.
  int _listenToken = 0;

  // -------------------------------------------------------------- settings

  String _language = '';
  double _rate = 0.5;
  bool _readAloud = false;
  bool _autoSend = true;
  bool _explained = false;

  static const String _kLanguage = 'voice.language';
  static const String _kRate = 'voice.rate';
  static const String _kReadAloud = 'voice.readAloud';
  static const String _kAutoSend = 'voice.autoSend';
  static const String _kIntro = 'voice.conversationIntro';

  // ---------------------------------------------------------------- output

  /// Final utterances, for the composer to insert at the caret.
  ///
  /// Hands-free does not publish here: it sends what was said itself, so nothing
  /// lands in the field behind the user's back.
  final StreamController<String> _utterances =
      StreamController<String>.broadcast();

  int _spokenIndex = 0;
  int _spokenTotal = 0;

  // ------------------------------------------------------------- lifecycle

  bool _suspended = false;
  bool _resumeConversation = false;

  @override
  void dispose() {
    _supersedeListen();
    _store.removeListener(_onStore);
    _relistenTimer?.cancel();
    _watchdog?.cancel();
    _forget(_stopRecognizer(discard: true));
    _forget(_tts.stop());
    _utterances.close();
    super.dispose();
  }

  Future<bool>? _initializing;

  /// True while a `listen` call is outstanding. Two callers can reach
  /// [_beginListen] at once - the mic button and the hands-free loop resuming -
  /// and the second platform call would restart the first one's session.
  bool _listenInFlight = false;

  bool _heard = false;

  // ----------------------------------------------------------- conversation

  bool _awaitingReply = false;
  bool _blockedByOverlay = false;
  bool _waitingForLink = false;
  bool _sawRun = false;

  /// Consecutive recognitions that heard nothing. Reset by any words.
  int _emptyResults = 0;
  String? _lastHandledId;
  String? _sessionId;
  DateTime _lastActivity = DateTime.now();
  Timer? _relistenTimer;

  void _onStore() {
    final sessionId = _store.current?.id;
    if (sessionId != _sessionId) {
      _sessionId = sessionId;
      _onSessionChanged();
      return;
    }
    if (_store.busy) _sawRun = true;

    if (_conversation) {
      // A tool approval or a question needs a tap. Holding the microphone open
      // across one would transcribe the answer to somebody else's question.
      final overlay =
          _store.permissions.isNotEmpty || _store.questions.isNotEmpty;
      if (overlay != _blockedByOverlay) {
        _blockedByOverlay = overlay;
        if (overlay) {
          _forget(_stopRecognizer(discard: true));
          if (_phase == VoicePhase.listening) _go(VoicePhase.idle);
        } else {
          _forget(_resumeLoop());
        }
      }
      if (_waitingForLink && _store.online) {
        _waitingForLink = false;
        _notice = null;
        _forget(_resumeLoop());
      }
      if (_awaitingReply && !_store.busy) {
        _awaitingReply = false;
        _handleTail();
        return;
      }
      if (_phase == VoicePhase.listening) _checkInactivity();
      return;
    }

    // Not hands-free: the read-aloud setting still wants finished replies.
    if (_readAloud && !_store.busy) _handleTail();
  }

  static String _messageText(ChatMessage message) => message.parts
      .where((p) => p.type == 'text')
      .map((p) => p.text)
      .join('\n');

  // -------------------------------------------------------------- read aloud

  final List<String> _queue = [];
  Completer<void>? _pending;
  Timer? _watchdog;
  String _currentSpoken = '';
  bool _bargeIn = false;

  static String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();

  // --------------------------------------------------------------- markdown

  /// Markdown to something worth hearing.
  ///
  /// Fenced code is dropped rather than read: a diff spoken aloud is noise, and
  /// `Nullable<T>` read character by character is worse than silence. Links keep
  /// their label, images keep their alt text, list bullets go and the words stay.
  /// A paragraph longer than the synthesiser takes comfortably is split at a
  /// sentence boundary.
  static List<String> plainSpeech(String raw) {
    var text = raw;
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
    text = text.replaceAll(RegExp(r'`[^`\n]*`'), ' ');
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^)]*\)'),
      (m) => (m.group(1) ?? '').trim(),
    );
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\([^)]*\)'),
      (m) => m.group(1) ?? '',
    );
    // `multiLine: true` is a constructor flag, not an inline `(?m)`: Dart's
    // RegExp rejects inline flags outright ("Invalid group"). Every heading,
    // quote and bullet rule below is anchored to the start of a line.
    text = text.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '');
    text = text.replaceAll(
      RegExp(r'^\s{0,3}([-*+]|\d+[.)])\s+', multiLine: true),
      '',
    );
    text = text.replaceAll(RegExp(r'^\s{0,3}([-*_]\s*){3,}$', multiLine: true), ' ');
    text = text.replaceAllMapped(
      RegExp(r'^\s*\|.*\|\s*$', multiLine: true),
      (m) => m.group(0)!.replaceAll('|', ' '),
    );
    text = text.replaceAll(RegExp(r'(\*\*|__|~~|\*|_)'), '');
    text = text.replaceAll('`', '');

    final utterances = <String>[];
    for (final block in text.split(RegExp(r'\n{2,}'))) {
      final line = block.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (line.isEmpty) continue;
      utterances.addAll(_split(line));
    }
    return utterances;
  }

  static const int _utteranceLimit = 700;

  static List<String> _split(String text) {
    if (text.length <= _utteranceLimit) return <String>[text];
    final parts = <String>[];
    var rest = text;
    while (rest.length > _utteranceLimit) {
      var cut = rest.lastIndexOf(RegExp(r'[.!?]\s'), _utteranceLimit);
      if (cut < _utteranceLimit ~/ 2) {
        cut = rest.lastIndexOf(' ', _utteranceLimit);
      }
      if (cut <= 0) cut = _utteranceLimit;
      parts.add(rest.substring(0, cut).trim());
      rest = rest.substring(cut).trim();
    }
    if (rest.isNotEmpty) parts.add(rest);
    return parts.where((p) => p.isNotEmpty).toList();
  }
}
