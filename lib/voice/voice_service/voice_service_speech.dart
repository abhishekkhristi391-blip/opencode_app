// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Read-aloud: the speech queue, barge-in and echo guard.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceSpeech on VoiceService {
  /// Read [text] aloud. Markdown is stripped and the prose is split into
  /// utterances small enough for the Android synthesiser, then queued.
  ///
  /// Called while a reply is already playing, this queues behind it instead of
  /// cutting it off: the older reply is still the one being followed.
  Future<void> speak(String text) async {
    final parts = VoiceService.plainSpeech(text);
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
    final said = VoiceService._normalize(_currentSpoken);
    final words = VoiceService._normalize(heard);
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
}
