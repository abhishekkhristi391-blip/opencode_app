// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Utterance stream, phase transitions, suspend/resume and recogniser warm-up.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceLifecycle on VoiceService {
  Stream<String> get utterances => _utterances.stream;

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
      // These five return void, not a Future. Handlers, not futures.
      _tts.setStartHandler(_onSpeakStart);
      _tts.setCompletionHandler(_onSpeakDone);
      _tts.setCancelHandler(_onSpeakDone);
      _tts.setPauseHandler(_onSpeakDone);
      _tts.setErrorHandler(_onSpeakError);
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
      _language = p.getString(VoiceService._kLanguage) ?? '';
      _rate = p.getDouble(VoiceService._kRate) ?? 0.5;
      _readAloud = p.getBool(VoiceService._kReadAloud) ?? false;
      _autoSend = p.getBool(VoiceService._kAutoSend) ?? true;
      _explained = p.getBool(VoiceService._kIntro) ?? false;
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
}
