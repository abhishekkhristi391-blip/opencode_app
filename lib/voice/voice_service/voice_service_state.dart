// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Public state getters and microphone availability.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceState on VoiceService {
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
}
