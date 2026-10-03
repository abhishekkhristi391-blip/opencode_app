import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'state/store.dart';
import 'ui/app_scope.dart';
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
    WidgetsFlutterBinding.instance.removeObserver(this);
    store.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      store.resumeConnections();
      store.reconnectStream();
      // Refresh the open session if any
      final id = store.current?.id;
      if (id != null) {
        unawaited(store.openSession(id));
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      // Gracefully pause connections when app goes to background
      store.pauseConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'OpenCode',
        debugShowCheckedModeBanner: false,
        // Follow the OS. The dark palette lives in OCTokens, which every
        // redesigned widget reads through `context.oc`.
        themeMode: ThemeMode.system,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
