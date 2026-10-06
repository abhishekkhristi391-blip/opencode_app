// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Persisted voice settings, the intro flag and notices.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceSettings on VoiceService {
  /// Recognition locale id, empty for the system default. The synthesiser uses
  /// the same locale in its `xx-YY` spelling.
  String get language => _language;

  /// Synthesiser rate, 0..1, the scale flutter_tts wants.
  double get rate => _rate;

  /// Read every finished reply aloud.
  bool get readAloud => _readAloud;

  /// In hands-free mode, send what was said without a tap.
  bool get autoSend => _autoSend;

  Future<void> setLanguage(String id) async {
    _language = id;
    notifyListeners();
    await _applySpeechSettings();
    await _persist((p) => p.setString(VoiceService._kLanguage, id));
  }

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    await _applySpeechSettings();
    await _persist((p) => p.setDouble(VoiceService._kRate, _rate));
  }

  Future<void> setReadAloud(bool value) async {
    _readAloud = value;
    notifyListeners();
    await _persist((p) => p.setBool(VoiceService._kReadAloud, value));
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
    await _persist((p) => p.setBool(VoiceService._kAutoSend, value));
  }

  void ackIntro() {
    if (_explained) return;
    _explained = true;
    unawaited(_persist((p) => p.setBool(VoiceService._kIntro, true)));
  }

  /// The UI has shown the reason voice stopped; forget it.
  ///
  /// Clears [failure] as well as [notice] on purpose. A reason that stays set
  /// would be re-shown every time the strip rebuilds, and the mic button has no
  /// way to say "I read that" on its own.
  void clearNotice() {
    if (_failure == null && _notice == null) return;
    _failure = null;
    _notice = null;
    notifyListeners();
  }
}
