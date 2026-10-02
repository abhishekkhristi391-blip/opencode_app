import 'package:flutter/material.dart';

import 'state/store.dart';
import 'ui/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenCodeApp());
}

class OpenCodeApp extends StatefulWidget {
  const OpenCodeApp({super.key});

  @override
  State<OpenCodeApp> createState() => _OpenCodeAppState();
}

class _OpenCodeAppState extends State<OpenCodeApp> {
  final store = OcStore();

  @override
  void initState() {
    super.initState();
    store.boot();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'OpenCode',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: _theme(Brightness.dark),
        darkTheme: _theme(Brightness.dark),
        home: const HomeShell(),
      ),
    );
  }

  ThemeData _theme(Brightness b) {
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: const ChipThemeData(side: BorderSide.none, padding: EdgeInsets.symmetric(horizontal: 6)),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
      listTileTheme: const ListTileThemeData(dense: false, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2)),
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
