import 'package:flutter/material.dart';

import '../state/store.dart';

/// Inherited notifier so every widget reads the same [OcStore].
class AppScope extends InheritedNotifier<OcStore> {
  const AppScope({super.key, required OcStore store, required super.child})
    : super(notifier: store);

  static OcStore of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope is missing above this widget');
    return s!.notifier!;
  }

  /// Read without subscribing to rebuilds (for callbacks).
  static OcStore read(BuildContext context) {
    final s = context.getInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope is missing above this widget');
    return s!.notifier!;
  }
}
