import 'package:flutter/material.dart';

import 'state/store.dart';
import 'ui/app_scope.dart';
import 'ui/home.dart';
import 'ui/prompts.dart';
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
      // resumeConnections() owns the whole resume path: it reconnects the
      // stream *and* re-verifies the server. Calling reconnectStream() here as
      // well raced two connects against each other, which could orphan a socket
      // and leave a stale generation listening.
      store.resumeConnections();
      // Do NOT re-open the session here. Re-opening reloads the message list,
      // which wiped the on-screen chat and made an in-flight reply vanish. The
      // reconnected stream re-syncs the session in place instead.
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Only a real backgrounding pauses the stream. `inactive` also fires for
      // the notification shade, the app picker and system dialogs — pausing
      // there killed the live stream while the user was still looking at it.
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
        // One palette, always. ThemeMode.system is what let a light ThemeData
        // paint white cards and sheets into an otherwise dark app.
        themeMode: ThemeMode.dark,
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(),
        // The pending-prompt sheet is mounted here, above the Navigator, not in
        // HomeShell's Stack. `builder` wraps whatever the Navigator puts on
        // screen, so a pushed route (Files, Terminal, Settings, the file
        // editor), a dialog, a bottom sheet and the drawer are all *under* the
        // approval card. Inside a screen's own Stack any of those hid it, and a
        // hidden permission is an agent that waits forever.
        builder: (context, child) => Stack(
          children: [
            if (child != null) child,
            const Positioned.fill(child: PromptOverlay()),
          ],
        ),
        home: const HomeShell(),
      ),
    );
  }
}
