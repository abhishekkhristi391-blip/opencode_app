import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'state/store.dart';
import 'ui/home.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenCodeApp());
}

class OpenCodeApp extends StatefulWidget {
  const OpenCodeApp({super.key});

  @override
  State<OpenCodeApp> createState() => _OpenCodeAppState();
}

class _OpenCodeAppState extends State<OpenCodeApp> with WidgetsBindingObserver {
  final store = OcStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      store.reconnectStream();
      // Refresh the open session if any
      final id = store.current?.id;
      if (id != null) {
        unawaited(store.openSession(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'OpenCode',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: buildDarkTheme(),
        darkTheme: buildDarkTheme(),
        home: const HomeShell(),
      ),
    );
  }
}

/// Inherited notifier so every widget reads the same [OcStore].
class AppScope extends InheritedNotifier<OcStore> {
  const AppScope({super.key, required OcStore store, required super.child}) : super(notifier: store);

  static OcStore of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope nahi mila');
    return s!.notifier!;
  }

  /// Read without subscribing to rebuilds (for callbacks).
  static OcStore read(BuildContext context) {
    final s = context.getInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope nahi mila');
    return s!.notifier!;
  }
}
