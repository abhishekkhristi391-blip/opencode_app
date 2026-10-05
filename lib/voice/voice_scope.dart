import 'package:flutter/material.dart';

import 'voice_service.dart';

/// Inherited notifier so every widget reads the same [VoiceService].
///
/// Mirrors `AppScope` exactly, including the two ways to reach it: [of] for a
/// widget that has to repaint when voice changes, [read] for a callback that
/// only wants to start something. The service is app-wide on purpose - the
/// microphone and the synthesiser are process-wide resources, and two services
/// would fight over both.
class VoiceScope extends InheritedNotifier<VoiceService> {
  const VoiceScope({
    super.key,
    required VoiceService service,
    required super.child,
  }) : super(notifier: service);

  static VoiceService of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<VoiceScope>();
    assert(s != null, 'VoiceScope is missing above this widget');
    return s!.notifier!;
  }

  /// Read without subscribing to rebuilds (for callbacks).
  static VoiceService read(BuildContext context) {
    final s = context.getInheritedWidgetOfExactType<VoiceScope>();
    assert(s != null, 'VoiceScope is missing above this widget');
    return s!.notifier!;
  }
}
