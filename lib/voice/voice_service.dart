import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../state/store.dart';

/// A language the recogniser on this device can hear.
///
/// Deliberately not the plugin's `LocaleName`: that type must not reach a widget
/// file, or every screen showing a language list imports a speech package.
class VoiceLocale {
  /// BCP-47-ish id such as `en_US`, which is also what gets stored.
  final String id;

  /// The name the platform reports, e.g. "English (United States)".
  final String name;

  const VoiceLocale({required this.id, required this.name});
}

/// Where the voice stack is right now.
///
/// One enum instead of a pile of booleans, so every asynchronous callback - a
/// recognition result, a synthesiser completion, a store change that lands three
/// seconds late - can be answered with a single question (was that still
/// wanted?) and so the answer is checkable. A transition that is not in
/// [_allowed] is refused, which is what makes a stale platform callback
/// harmless: it cannot drag a finished session back into `listening`.
enum VoicePhase {
  /// Nothing holds the microphone or the speaker.
  idle,

  /// The recogniser is starting and may be showing the OS microphone prompt.
  requestingPermission,

  /// The microphone is open. [VoiceService.partial] is what has been heard.
  listening,

  /// A final result is in and is being committed: inserted, or sent.
  processing,

  /// Reading a reply aloud. [VoiceService.spokenIndex] tracks the queue.
  speaking,

  /// Hands-free: the prompt was sent and the reply has not landed yet.
  waiting,

  /// Stopped on a failure. [VoiceService.failure] says which one.
  error,

  /// No recogniser or no speech engine on this device.
  unavailable,
}

/// Why voice stopped, in terms the UI turns into one calm sentence.
enum VoiceFailure {
  /// The microphone is not granted and Android will not ask again.
  permission,

  /// No speech recognition service is installed or reachable.
  recognizer,

  /// Nothing was said before the silence timeout.
  noSpeech,

  /// The link dropped while listening, or while waiting for the server.
  network,

  /// The recogniser refused to start: something else owns the microphone.
  busy,

  /// The chosen language is not available on this device.
  language,

  /// The model that would answer has not been picked yet.
  noModel,

  /// The text-to-speech engine refused, or there is none.
  playback,

  /// Hands-free needs to send what it hears, and auto-send is off.
  autoSendOff,

  /// Unclassified. Never surfaced raw.
  unknown,
}

/// The whole state machine. Anything not listed here cannot happen.
///
/// Two entries earn their keep. `listening` cannot reach `speaking` directly, so
/// a reply cannot be read into the microphone; [VoiceService.speak] detours
/// through `idle` first. And nothing reaches [VoicePhase.listening] from
/// `error` without going past the recogniser check, so a failed attempt cannot
/// leave a half-started engine behind.
const Map<VoicePhase, Set<VoicePhase>> _allowed =
    <VoicePhase, Set<VoicePhase>>{
      VoicePhase.idle: <VoicePhase>{
        VoicePhase.requestingPermission,
        VoicePhase.listening,
        VoicePhase.speaking,
        VoicePhase.error,
        VoicePhase.unavailable,
      },
      VoicePhase.requestingPermission: <VoicePhase>{
        VoicePhase.listening,
        VoicePhase.idle,
        VoicePhase.error,
        VoicePhase.unavailable,
      },
      VoicePhase.listening: <VoicePhase>{
        VoicePhase.processing,
        VoicePhase.idle,
        VoicePhase.error,
      },
      VoicePhase.processing: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.speaking,
        VoicePhase.waiting,
        VoicePhase.listening,
        VoicePhase.error,
      },
      VoicePhase.speaking: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.listening,
        VoicePhase.error,
      },
      VoicePhase.waiting: <VoicePhase>{
        VoicePhase.speaking,
        VoicePhase.listening,
        VoicePhase.idle,
        VoicePhase.error,
      },
      VoicePhase.error: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.requestingPermission,
        VoicePhase.listening,
        VoicePhase.speaking,
        VoicePhase.unavailable,
      },
      VoicePhase.unavailable: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.requestingPermission,
      },
    };

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

  VoicePhase get phase => _phase;

  /// Why the last attempt stopped, if it stopped badly.
  VoiceFailure? get failure => _failure;

  /// Why hands-free turned itself off. The UI shows it once, then calls
  /// [clearNotice], rather than putting it in a banner that fights every rebuild.
  VoiceFailure? get notice => _notice;

  /// What the recogniser has heard so far in this utterance.
  String get partial => _partial;

  /// Microphone level, 0..1, smoothed. Drives the waveform and nothing else.
  double get level => _level;

  bool get isListening => _phase == VoicePhase.listening;

  /// True while the microphone is open or being opened. This is what the mic
  /// button reads to decide between "start" and "stop".
  bool get micActive =>
      _phase == VoicePhase.listening ||
      _phase == VoicePhase.requestingPermission;

  bool get isSpeaking => _phase == VoicePhase.speaking;

  /// True while a hands-free turn is in flight: speaking, waiting or
  /// committing. The composer dims its send button for this.
  bool get isBusy =>
      _phase == VoicePhase.speaking ||
      _phase == VoicePhase.waiting ||
      _phase == VoicePhase.processing;

  bool get conversation => _conversation;

  /// True the first time hands-free is switched on, so the UI can explain it
  /// once instead of every time.
  bool get needsIntro => _conversation && !_explained;

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

  /// Invalidates any in-flight listen attempt.
  void _supersedeListen() => _listenToken++;

  /// True when a newer action has taken the microphone over since [token] was
  /// handed out, or the app is no longer allowed to hold it at all.
  bool _superseded(int token) => token != _listenToken || _suspended;

  bool get recognizerReady => _recognizerReady;

  /// True when this device has no speech recognition service at all. Distinct
  /// from a refused microphone: there is nothing to grant.
  bool get recognizerMissing => _recognizerMissing;

  /// True when a text-to-speech engine answered.
  bool get speechAvailable => _speechReady;

  /// True after the OS refused the microphone. Android does not let an app ask
  /// again, so the only way back is the system settings screen.
  bool get permissionDenied => _permissionDenied;

  /// The locales this device can actually recognise speech in.
  ///
  /// Asking costs a recogniser start-up, so the phase has to be put back where
  /// it was found: otherwise opening the language list parks the mic button in
  /// `requestingPermission` and it looks live for as long as the sheet is open.
  ///
  /// The plugin's `LocaleName` does not leave this file. A settings row should
  /// not have to import a speech package to show a language list.
  Future<List<VoiceLocale>> locales() async {
    try {
      if (!_recognizerReady) {
        if (_phase != VoicePhase.idle &&
            _phase != VoicePhase.requestingPermission) {
          _go(VoicePhase.idle);
        }
        if (!await _ensureRecognizer()) return const <VoiceLocale>[];
      }
      final locales = await _stt.locales();
      if (_phase == VoicePhase.requestingPermission) _go(VoicePhase.idle);
      return locales
          .map((l) => VoiceLocale(id: l.localeId, name: l.name))
          .toList(growable: false);
    } catch (e) {
      debugPrint('VoiceService: could not list locales: $e');
      return const <VoiceLocale>[];
    }
  }

  /// Open the OS page for this app's permissions.
  ///
  /// The one thing speech_to_text cannot do: once Android reports a denial the
  /// prompt never appears again, and only settings can undo it. permission_handler
  /// is already a dependency of the files and terminal screens.
  Future<bool> openMicrophoneSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('VoiceService: could not open app settings: $e');
      return false;
    }
  }

  // -------------------------------------------------------------- settings

  String _language = '';
  double _rate = 0.5;
  bool _readAloud = false;
  bool _autoSend = true;
  bool _explained = false;

  /// Recognition locale id, empty for the system default. The synthesiser uses
  /// the same locale in its `xx-YY` spelling.
  String get language => _language;

  /// Synthesiser rate, 0..1, the scale flutter_tts wants.
  double get rate => _rate;

  /// Read every finished reply aloud.
  bool get readAloud => _readAloud;

  /// In hands-free mode, send what was said without a tap.
  bool get autoSend => _autoSend;

  static const String _kLanguage = 'voice.language';
  static const String _kRate = 'voice.rate';
  static const String _kReadAloud = 'voice.readAloud';
  static const String _kAutoSend = 'voice.autoSend';
  static const String _kIntro = 'voice.conversationIntro';

  Future<void> setLanguage(String id) async {
    _language = id;
    notifyListeners();
    await _applySpeechSettings();
    await _persist((p) => p.setString(_kLanguage, id));
  }

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    await _applySpeechSettings();
    await _persist((p) => p.setDouble(_kRate, _rate));
  }

  Future<void> setReadAloud(bool value) async {
    _readAloud = value;
    notifyListeners();
    await _persist((p) => p.setBool(_kReadAloud, value));
  }

  Future<void> setAutoSend(bool value) async {
    _autoSend = value;
    // Turning it off mid-turn would strand the loop: it cannot answer what it
    // hears, and it cannot type into the composer either.
    if (!value && _conversation) {
      _notice = VoiceFailure.autoSendOff;
      _conversation = false;
      unawaited(_stopRecognizer(discard: true));
      _go(VoicePhase.idle);
    }
    notifyListeners();
    await _persist((p) => p.setBool(_kAutoSend, value));
  }

  void ackIntro() {
    if (_explained) return;
    _explained = true;
    unawaited(_persist((p) => p.setBool(_kIntro, true)));
  }

  void clearNotice() {
    if (_notice == null) return;
    _notice = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- output

  /// Final utterances, for the composer to insert at the caret.
  ///
  /// Hands-free does not publish here: it sends what was said itself, so nothing
  /// lands in the field behind the user's back.
  final StreamController<String> _utterances =
      StreamController<String>.broadcast();
  Stream<String> get utterances => _utterances.stream;

  int _spokenIndex = 0;
  int _spokenTotal = 0;

  /// 1-based position in the reply being read, for "2 of 7".
  int get spokenIndex => _spokenIndex;

  /// Utterances in the reply being read.
  int get spokenTotal => _spokenTotal;

  // ---------------------------------------------------------- state machine

  void _go(VoicePhase next) {
    if (next == _phase) return;
    final allowed = _allowed[_phase] ?? const <VoicePhase>{};
    if (!allowed.contains(next)) {
      // A guard, not a crash. A late platform callback must not take the app
      // down, and it must not fake a state either, so it is logged and dropped.
      debugPrint('VoiceService: refused ${_phase.name} -> ${next.name}');
      return;
    }
    _phase = next;
    if (next != VoicePhase.error) _failure = null;
    notifyListeners();
  }

  void _fail(VoiceFailure reason, {bool endConversation = true}) {
    _failure = reason;
    _partial = '';
    _level = 0;
    if (endConversation && _conversation) {
      _conversation = false;
      _notice = reason;
    }
    _forget(_stopRecognizer(discard: true));
    _go(VoicePhase.error);
  }

  void _forget(Future<void> work) {
    unawaited(work.catchError((Object e) {
      debugPrint('VoiceService: background task failed: $e');
    }));
  }

  // ------------------------------------------------------------- lifecycle

  bool _suspended = false;
  bool _resumeConversation = false;

  /// Release the microphone and the speaker, remembering that hands-free was on.
  ///
  /// Called from the app's `paused`/`detached` hook and never from `inactive`:
  /// `inactive` also fires for the notification shade and the app picker, and
  /// tearing the microphone down there kills a live session the user is watching.
  void suspend() {
    if (_suspended) return;
    _suspended = true;
    _supersedeListen();
    _resumeConversation = _conversation;
    _conversation = false;
    _relistenTimer?.cancel();
    _forget(_stopRecognizer(discard: true));
    _forget(_stopSpeaking(silent: true));
    _partial = '';
    _level = 0;
    _go(VoicePhase.idle);
    notifyListeners();
  }

  void resume() {
    if (!_suspended) return;
    _suspended = false;
    if (_resumeConversation) {
      _conversation = true;
      _forget(_resumeLoop());
    }
    _resumeConversation = false;
    notifyListeners();
  }

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

  // --------------------------------------------------------------- start-up

  /// Bring the engines up without asking for anything.
  ///
  /// Called once at boot so the first tap on the mic is instant. Only the
  /// synthesiser is started here: asking for the microphone at launch is the
  /// fastest way to be denied it.
  Future<void> warmUp() async {
    await _loadSettings();
    await _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      // Handlers, not the returned future: flutter_tts resolves one utterance
      // at a time, and this service owns a queue on top of it.
      await _tts.awaitSpeakCompletion(false);
      unawaited(_tts.setStartHandler(_onSpeakStart));
      unawaited(_tts.setCompletionHandler(_onSpeakDone));
      unawaited(_tts.setCancelHandler(_onSpeakDone));
      unawaited(_tts.setPauseHandler(_onSpeakDone));
      unawaited(_tts.setErrorHandler(_onSpeakError));
      // Flush, never add: a reply the user cut off must not keep playing behind
      // the next one.
      await _tts.setQueueMode(0);
      _speechReady = true;
      await _applySpeechSettings();
    } catch (e) {
      _speechReady = false;
      debugPrint('VoiceService: no text-to-speech engine: $e');
    }
    notifyListeners();
  }

  Future<void> _applySpeechSettings() async {
    if (!_speechReady) return;
    try {
      final locale = _language.replaceAll('_', '-');
      if (locale.isNotEmpty) await _tts.setLanguage(locale);
      await _tts.setSpeechRate(_rate);
      await _tts.setVolume(1);
    } catch (e) {
      debugPrint('VoiceService: could not apply speech settings: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final p = await SharedPreferences.getInstance();
      _language = p.getString(_kLanguage) ?? '';
      _rate = p.getDouble(_kRate) ?? 0.5;
      _readAloud = p.getBool(_kReadAloud) ?? false;
      _autoSend = p.getBool(_kAutoSend) ?? true;
      _explained = p.getBool(_kIntro) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('VoiceService: could not read voice settings: $e');
    }
  }

  Future<void> _persist(Future<bool> Function(SharedPreferences p) write) async {
    try {
      final p = await SharedPreferences.getInstance();
      await write(p);
    } catch (e) {
      debugPrint('VoiceService: could not save voice settings: $e');
    }
  }

  // ------------------------------------------------------------ recognizer

  /// Start the recogniser, asking for the microphone if that has not happened
  /// yet. Returns false with the phase and failure already set when voice cannot
  /// start, so the caller has nothing to decide.
  ///
  /// The start itself is memoised: two callers racing here (the mic button and
  /// the language list opening at the same moment) must produce one platform
  /// call, not two permission prompts.
  Future<bool> _ensureRecognizer() {
    return _initializing ??= _startRecognizer().whenComplete(() {
      _initializing = null;
    });
  }

  Future<bool>? _initializing;

  Future<bool> _startRecognizer() async {
    if (_recognizerReady) return true;
    _go(VoicePhase.requestingPermission);

    var granted = false;
    try {
      // Reads the current grant without prompting.
      granted = await _stt.hasPermission;
    } catch (_) {
      granted = false;
    }

    try {
      // On Android this is also what raises the OS prompt.
      final ok = await _stt.initialize(
        onStatus: _onStatus,
        onError: _onRecognizerError,
        // Android can deliver partials and then go quiet without ever sending a
        // final result. This hands back the last partial as the final one
        // instead of losing the sentence.
        finalTimeout: const Duration(milliseconds: 2500),
      );
      if (ok) {
        _recognizerReady = true;
        _recognizerMissing = false;
        return true;
      }
      if (granted) {
        // Permission is fine, so the recogniser itself is missing or broken.
        // Nothing the user can do about it, so it is not an error state.
        _recognizerMissing = true;
        _go(VoicePhase.unavailable);
      } else {
        _permissionDenied = true;
        _fail(VoiceFailure.permission);
      }
      return false;
    } catch (e) {
      debugPrint('VoiceService: the recogniser did not start: $e');
      _fail(VoiceFailure.recognizer);
      return false;
    }
  }

  /// Open the microphone. This is the whole job of the mic button.
  Future<void> toggleDictation() async {
    if (_suspended) return;
    if (micActive) {
      await stopDictation();
      return;
    }
    _clearNotice();
    _failure = null;
    await _beginListen();
  }

  /// The mic button while it is active.
  Future<void> stopDictation() async {
    // Anything already on its way to opening the microphone stands down.
    _supersedeListen();
    if (!_conversation) {
      if (_phase == VoicePhase.requestingPermission) {
        // The permission dialog is up. There is nothing heard to keep, and the
        // phase has to leave `requestingPermission` or the button would sit
        // there looking live for as long as the dialog is open.
        _forget(_stopRecognizer(discard: true));
        _partial = '';
        _level = 0;
        _go(VoicePhase.idle);
        return;
      }
      final heard = _partial.trim();
      // `stop` asks the recogniser for a final result, `cancel` throws the
      // session away. Words already heard belong in the field, so they are
      // committed rather than dropped.
      final commit = _heard && heard.isNotEmpty;
      _forget(_stopRecognizer(discard: !commit));
      if (_phase != VoicePhase.listening) return;
      if (commit) {
        await _commitUtterance(heard);
        return;
      }
      _partial = '';
      _level = 0;
      _go(VoicePhase.idle);
      return;
    }
    await endConversation();
  }

  Future<void> _beginListen() async {
    if (_suspended) return;
    // Already open: nothing to do. Reached when a tap lands twice quickly.
    if (_phase == VoicePhase.listening && _stt.isListening) return;
    final token = _listenToken;
    if (!_recognizerReady) {
      if (_phase != VoicePhase.idle &&
          _phase != VoicePhase.requestingPermission) {
        _go(VoicePhase.idle);
      }
      if (!await _ensureRecognizer()) return;
      if (_superseded(token)) return;
    }
    _partial = '';
    _level = 0;
    _heard = false;
    _emptyResults = 0;
    _lastActivity = DateTime.now();
    _go(VoicePhase.listening);
    notifyListeners();

    try {
      _listenInFlight = true;
      await _stt.listen(
        onResult: _onResult,
        onSoundLevelChange: _onLevel,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          pauseFor: _silenceTimeout,
          listenFor: _listenCap,
          localeId: _language.isEmpty ? null : _language,
        ),
      );
    } catch (e) {
      debugPrint('VoiceService: could not open the microphone: $e');
      _fail(VoiceFailure.busy);
    } finally {
      _listenInFlight = false;
    }
  }

  /// True while a `listen` call is outstanding. Two callers can reach
  /// [_beginListen] at once - the mic button and the hands-free loop resuming -
  /// and the second platform call would restart the first one's session.
  bool _listenInFlight = false;

  Future<void> _stopRecognizer({bool discard = false}) async {
    try {
      if (discard) {
        await _stt.cancel();
      } else {
        await _stt.stop();
      }
    } catch (e) {
      debugPrint('VoiceService: stopping the recogniser failed: $e');
    }
  }

  void _onLevel(double level) {
    // Android reports roughly 0..10. Smoothed because the raw stream jumps
    // around enough to make a waveform look like noise.
    final next = (level / 10).clamp(0.0, 1.0).toDouble();
    _level = _level * 0.6 + next * 0.4;
    notifyListeners();
  }

  bool _heard = false;

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    if (_phase == VoicePhase.speaking) {
      // Recognition during playback is the microphone hearing the synthesiser.
      // It is used for exactly one thing - noticing that the user cut in - and
      // never as text.
      if (_bargeIn && !_isEcho(text)) _forget(_interruptToListen());
      return;
    }
    if (_phase != VoicePhase.listening) return;

    _heard = true;
    _lastActivity = DateTime.now();
    _level = 0;

    if (!result.finalResult) {
      _partial = text;
      notifyListeners();
      return;
    }
    _forget(_finishUtterance(text));
  }

  void _onStatus(String status) {
    if (status == 'listening') return;
    _level = 0;
    // `done` arrives after every result of a session. If the phase is still
    // `listening`, no final result was delivered, which on Android means the
    // silence timeout fired. The partial is better than nothing.
    if (status != 'done' || _phase != VoicePhase.listening) return;
    final heard = _partial.trim();
    if (heard.isNotEmpty) {
      _forget(_finishUtterance(heard));
      return;
    }
    _onEmptyUtterance();
  }

  void _onRecognizerError(SpeechRecognitionError error) {
    final code = error.errorMsg;
    _level = 0;
    if (code.contains('permission') || code.contains('client')) {
      _permissionDenied = true;
      _fail(VoiceFailure.permission);
      return;
    }
    if (code.contains('no_match') || code.contains('speech_timeout')) {
      // Nothing was said. Not worth an error banner.
      _onEmptyUtterance();
      return;
    }
    if (code.contains('busy')) {
      _fail(VoiceFailure.busy);
      return;
    }
    if (code.contains('network')) {
      _fail(VoiceFailure.network);
      return;
    }
    if (code.contains('language')) {
      _fail(VoiceFailure.language);
      return;
    }
    // Anything else is the engine refusing the session rather than anything the
    // user did, so it is reported as "speech is not working" and not as a raw
    // code.
    _fail(VoiceFailure.recognizer);
  }

  Future<void> _finishUtterance(String text) async {
    if (_phase != VoicePhase.listening) return;
    _partial = text;
    _go(VoicePhase.processing);
    await _stopRecognizer();
    final spoken = text.trim();
    _partial = '';
    _level = 0;
    if (spoken.isEmpty) {
      _onEmptyUtterance();
      return;
    }
    await _commitUtterance(spoken);
  }

  /// Hand one finished utterance to whoever is waiting for it: the composer in
  /// plain dictation, the store in hands-free mode.
  Future<void> _commitUtterance(String text) async {
    if (_conversation && _autoSend) {
      await _sendAndWait(text);
      return;
    }
    if (!_utterances.isClosed) _utterances.add(text);
    if (_conversation) {
      // Hands-free without auto-send: the words are in the field and the loop
      // cannot continue, because the send is now the user's to make.
      _fail(VoiceFailure.autoSendOff);
      return;
    }
    _go(VoicePhase.idle);
  }

  Future<void> _sendAndWait(String text) async {
    if (!_store.online) {
      _fail(VoiceFailure.network);
      return;
    }
    if (_store.providerId.isEmpty || _store.modelId.isEmpty) {
      // The store would raise its own "pick a model first" toast from inside a
      // hands-free loop nobody is watching, so it is said here instead.
      _fail(VoiceFailure.noModel);
      return;
    }
    try {
      // The composer's own path, unchanged: one prompt in flight, mid-run
      // prompts queued in order, optimistic echo handled by the store.
      await _store.sendOrQueue(text);
    } catch (e) {
      debugPrint('VoiceService: send failed: $e');
      _fail(VoiceFailure.unknown);
      return;
    }
    _awaitingReply = true;
    _emptyResults = 0;
    _lastActivity = DateTime.now();
    _go(VoicePhase.waiting);
    // If the run already ended - a rejected prompt, a server that answered
    // instantly - the reply is picked up here instead of on the next change.
    _onStore();
  }

  void _onEmptyUtterance() {
    _partial = '';
    _level = 0;
    _emptyResults++;
    if (_conversation) {
      if (_emptyResults >= _emptyLimit) {
        _notice = VoiceFailure.noSpeech;
        _forget(endConversation());
        return;
      }
      _forget(_relisten());
      return;
    }
    _go(VoicePhase.idle);
  }

  // ----------------------------------------------------------- conversation

  bool _awaitingReply = false;
  bool _blockedByOverlay = false;
  bool _waitingForLink = false;
  bool _sawRun = false;
  String? _lastHandledId;
  String? _sessionId;
  DateTime _lastActivity = DateTime.now();
  Timer? _relistenTimer;

  /// Hands-free, on or off.
  Future<void> toggleConversation() async {
    if (_conversation) {
      await endConversation();
      return;
    }
    await startConversation();
  }

  Future<void> startConversation() async {
    if (_suspended) return;
    if (!_autoSend) {
      // Refused rather than half-started: a hands-free loop that cannot send is
      // just an open microphone.
      _notice = VoiceFailure.autoSendOff;
      notifyListeners();
      return;
    }
    _clearNotice();
    _failure = null;
    _conversation = true;
    _emptyResults = 0;
    _blockedByOverlay =
        _store.permissions.isNotEmpty || _store.questions.isNotEmpty;
    notifyListeners();
    if (_blockedByOverlay) return;
    await _resumeLoop();
  }

  /// End hands-free. Whatever was in the microphone is committed first, so a
  /// tap never loses a sentence.
  Future<void> endConversation() async {
    _conversation = false;
    _awaitingReply = false;
    _waitingForLink = false;
    _relistenTimer?.cancel();
    final heard = _partial.trim();
    final commitHeard = _heard && heard.isNotEmpty;
    _forget(_stopRecognizer(discard: !commitHeard));
    _forget(_stopSpeaking(silent: true));
    if (commitHeard) {
      // Hands-free with words half-heard puts them in the field. Dropping them
      // is the one thing a stop button must never do.
      await _finishUtterance(heard);
      return;
    }
    _partial = '';
    _level = 0;
    _go(VoicePhase.idle);
    notifyListeners();
  }

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

  void _onSessionChanged() {
    // A different session is a different conversation: whatever was pending
    // belonged to the old one and is dropped rather than spoken into the new.
    _awaitingReply = false;
    _lastHandledId = null;
    _emptyResults = 0;
    _waitingForLink = false;
    _forget(_stopRecognizer(discard: true));
    _forget(_stopSpeaking(silent: true));
    if (_conversation) {
      _forget(_resumeLoop());
      return;
    }
    if (_phase == VoicePhase.listening) _go(VoicePhase.idle);
  }

  /// Speak the newest finished assistant reply, once.
  void _handleTail() {
    // A run has to have been seen going before its reply counts as new. Opening
    // the app onto a restored session with read-aloud on would otherwise start
    // talking about the last thing that was said, unasked, at launch.
    if (!_sawRun) return;
    final tail = _lastAssistantMessage();
    if (tail == null) return;
    final id = tail.info.id;
    if (id == _lastHandledId) return;
    if (tail.streaming) {
      // The run ended but the message has not settled. Nothing to do; the next
      // change will say so.
      return;
    }
    _lastHandledId = id;
    _awaitingReply = false;
    _partial = '';
    _level = 0;
    final text = _messageText(tail);
    if (text.trim().isEmpty) {
      if (_conversation) _forget(_relisten());
      return;
    }
    // Read it whether or not hands-free asked for it: `_readAloud` is the
    // user's standing instruction, and a hands-free turn needs to hear this
    // reply in order to answer it.
    _forget(speak(text));
  }

  /// The tail message, if it is an assistant one.
  ChatMessage? _lastAssistantMessage() {
    final messages = _store.messages;
    if (messages.isEmpty) return null;
    final last = messages.last;
    if (last.info.isUser) return null;
    return last;
  }

  static String _messageText(ChatMessage message) => message.parts
      .where((p) => p.type == 'text')
      .map((p) => p.text)
      .join('\n');

  void _checkInactivity() {
    if (DateTime.now().difference(_lastActivity) < _idleLimit) return;
    _notice = VoiceFailure.noSpeech;
    _forget(endConversation());
  }

  Future<void> _resumeLoop() async {
    if (!_conversation || _suspended) return;
    if (_blockedByOverlay) return;
    if (!_store.online) {
      // Nothing to send a prompt to. The store listener wakes the loop when the
      // link comes back.
      _waitingForLink = true;
      return;
    }
    _waitingForLink = false;
    await _relisten();
  }

  /// Back to the microphone, once the synthesiser has fallen quiet.
  Future<void> _relisten() async {
    if (!_conversation || _suspended) return;
    if (_blockedByOverlay || _waitingForLink) return;
    // Not while a reply is still coming: the microphone would transcribe the
    // agent's own tools asking questions.
    if (_phase == VoicePhase.waiting) return;

    _relistenTimer?.cancel();
    final gate = Completer<void>();
    _relistenTimer = Timer(_echoGuard, gate.complete);
    await gate.future;
    _relistenTimer = null;

    if (!_conversation || _suspended) return;
    if (_store.permissions.isNotEmpty || _store.questions.isNotEmpty) {
      _blockedByOverlay = true;
      return;
    }
    if (!_store.online) {
      _waitingForLink = true;
      return;
    }
    await _beginListen();
  }

  // -------------------------------------------------------------- read aloud

  final List<String> _queue = [];
  Completer<void>? _pending;
  Timer? _watchdog;
  String _currentSpoken = '';
  bool _bargeIn = false;

  /// Read [text] aloud. Markdown is stripped and the prose is split into
  /// utterances small enough for the Android synthesiser, then queued.
  ///
  /// Called while a reply is already playing, this queues behind it instead of
  /// cutting it off: the older reply is still the one being followed.
  Future<void> speak(String text) async {
    final parts = plainSpeech(text);
    if (parts.isEmpty) return;
    if (!_speechReady) {
      _fail(VoiceFailure.playback, endConversation: false);
      return;
    }
    if (_phase == VoicePhase.speaking) {
      _queue.addAll(parts);
      return;
    }
    if (_phase == VoicePhase.listening ||
        _phase == VoicePhase.requestingPermission) {
      // Listening and synthesising at once is how a reply gets transcribed as
      // the user's own turn, so the microphone gives way to the voice.
      _supersedeListen();
      _forget(_stopRecognizer(discard: true));
      _partial = '';
      _level = 0;
      _go(VoicePhase.idle);
    }
    await _stopSpeaking(silent: true);
    _queue
      ..clear()
      ..addAll(parts);
    _spokenIndex = 0;
    _spokenTotal = _queue.length;
    // Cutting in is only offered hands-free: when somebody is typing, a passing
    // truck should not stop the reply.
    _bargeIn = _conversation;
    _go(VoicePhase.speaking);
    await _runQueue();
  }

  /// Stops reading and leaves the phase idle.
  Future<void> stopSpeaking() async {
    await _stopSpeaking();
    if (_phase == VoicePhase.speaking) _go(VoicePhase.idle);
  }

  /// Stops reading. [silent] skips the phase change, because every caller here
  /// is either handing the phase to the microphone or tearing everything down.
  Future<void> _stopSpeaking({bool silent = false}) async {
    _queue.clear();
    if (_phase == VoicePhase.speaking) {
      _watchdog?.cancel();
      _watchdog = null;
      try {
        await _tts.stop();
      } catch (e) {
        debugPrint('VoiceService: stop failed: $e');
      }
    }
    // Depending on the engine, `stop` may or may not deliver speak.onCancel, so
    // the pending utterance is completed here either way. Otherwise a queue
    // waiting on that handler never resumes.
    _completePending();
    if (!silent && _phase == VoicePhase.speaking) _go(VoicePhase.idle);
  }

  /// The "test voice" button in settings.
  Future<void> testVoice(String sample) async {
    if (!_speechReady) {
      _fail(VoiceFailure.playback, endConversation: false);
      return;
    }
    await speak(sample);
  }

  Future<void> _runQueue() async {
    while (_queue.isNotEmpty && _phase == VoicePhase.speaking) {
      final part = _queue.removeAt(0);
      _spokenIndex++;
      _currentSpoken = part;
      final done = Completer<void>();
      _pending = done;
      _armWatchdog(part);
      try {
        // flutter_tts mixes rather than ducks: it cannot ask Android for
        // transient audio focus, so a reply plays over whatever else is on.
        await _tts.speak(part);
      } catch (e) {
        debugPrint('VoiceService: speak failed: $e');
        _completePending();
        _fail(VoiceFailure.playback, endConversation: false);
        return;
      }
      await done.future;
    }
    if (_phase == VoicePhase.speaking) await _finishSpeaking();
  }

  void _onSpeakStart() {
    // The queue is driven by the completion handler. This exists because the
    // platform sends speak.onStart and an unhandled platform message is a
    // warning in the log on every reply.
  }

  void _onSpeakDone() => _completePending();

  void _onSpeakError(dynamic message) {
    debugPrint('VoiceService: speech engine error: $message');
    _completePending();
  }

  void _completePending() {
    _watchdog?.cancel();
    _watchdog = null;
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) pending.complete();
  }

  /// An engine that never reports completion would strand the queue with the
  /// phase stuck on `speaking`, which is also what stop and cut-in key off. So
  /// every utterance gets a ceiling.
  void _armWatchdog(String part) {
    _watchdog?.cancel();
    // Roughly `rate * 14` characters a second, plus room for a slow engine.
    final speed = _rate <= 0 ? 7.0 : _rate * 14;
    final estimate = (part.length / speed).ceil() + 8;
    final seconds = estimate < 10 ? 10 : (estimate > 300 ? 300 : estimate);
    _watchdog = Timer(Duration(seconds: seconds), _completePending);
  }

  Future<void> _finishSpeaking() async {
    _currentSpoken = '';
    _bargeIn = false;
    _spokenIndex = 0;
    _spokenTotal = 0;
    if (_conversation) {
      // Hands-free: back to the microphone, not to a cold idle screen.
      await _relisten();
      return;
    }
    _go(VoicePhase.idle);
  }

  /// The user cut in while the reply was being read.
  Future<void> _interruptToListen() async {
    await _stopSpeaking(silent: true);
    await _beginListen();
  }

  /// True when a phrase is our own synthesised voice coming back through the
  /// microphone. Anything else during playback counts as the user.
  bool _isEcho(String heard) {
    final said = _normalize(_currentSpoken);
    final words = _normalize(heard);
    if (words.isEmpty) return true;
    if (said.contains(words) || words.contains(said)) return true;
    // During playback a recogniser result is usually a fragment of the sentence
    // being spoken, so a shared opening word is treated as echo.
    final mine = said.split(' ');
    final theirs = words.split(' ');
    if (theirs.length > 1 && mine.isNotEmpty && mine.first == theirs.first) {
      return true;
    }
    return false;
  }

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
    text = text.replaceAll(RegExp(r'(?m)^\s{0,3}#{1,6}\s+'), '');
    text = text.replaceAll(RegExp(r'(?m)^\s{0,3}>\s?'), '');
    text = text.replaceAll(RegExp(r'(?m)^\s{0,3}([-*+]|\d+[.)])\s+'), '');
    text = text.replaceAll(RegExp(r'(?m)^\s{0,3}([-*_]\s*){3,}$'), ' ');
    text = text.replaceAllMapped(
      RegExp(r'(?m)^\s*\|.*\|\s*$'),
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
