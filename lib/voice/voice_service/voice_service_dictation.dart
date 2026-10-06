// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Dictation: starting and stopping the recogniser and handling its callbacks.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceDictation on VoiceService {
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
    clearNotice();
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
    // Already open: nothing to do. Reached when a tap lands twice quickly, or
    // when the hands-free timer fires while the mic button just opened it.
    if (_phase == VoicePhase.listening && _stt.isListening) return;
    if (_listenInFlight) return;
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
          pauseFor: VoiceService._silenceTimeout,
          listenFor: VoiceService._listenCap,
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
}
