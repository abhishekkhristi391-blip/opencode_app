import 'package:flutter/material.dart';

import '../main.dart';
import 'chat.dart';
import 'commands_page.dart';
import 'diff_page.dart';
import 'files_page.dart';
import 'models_page.dart';
import 'prompts.dart';
import 'sessions_page.dart';
import 'settings_page.dart';
import 'terminal_page.dart';
import 'todos_page.dart';
import 'widgets.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final bool needsSession;
  const NavItem(this.label, this.icon, this.page, {this.needsSession = false});
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  static final navs = <NavItem>[
    NavItem('Chat', Icons.forum_outlined, const ChatPage()),
    NavItem('Sessions', Icons.history, const SessionsPage()),
    NavItem('Files', Icons.folder_outlined, const FilesPage()),
    NavItem('Diff', Icons.difference_outlined, const DiffPage(), needsSession: true),
    NavItem('Tasks', Icons.checklist, const TodosPage(), needsSession: true),
    NavItem('Terminal', Icons.terminal, const TerminalPage()),
    NavItem('Commands', Icons.code, const CommandsPage()),
    NavItem('Models', Icons.psychology_outlined, const ModelsPage()),
    NavItem('Settings', Icons.settings_outlined, const SettingsPage()),
  ];

  void goTo(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      drawer: _Drawer(current: index, onSelect: (i) {
        Navigator.pop(context);
        goTo(i);
      }),
      appBar: AppBar(
        title: _Title(store: store, onRename: _renameSession),
        actions: [
          _ConnectionDot(online: store.online, version: store.serverVersion, onTap: () => goTo(8)),
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () async {
              await store.newSession();
              goTo(0);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _body(context, store),
            const Positioned.fill(child: PromptOverlay()),
          ],
        ),
      ),
      floatingActionButton: index == 0 && store.busy
          ? FloatingActionButton.small(
              heroTag: 'abort',
              tooltip: 'Stop (abort)',
              onPressed: store.abortSession,
              child: const Icon(Icons.stop_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: goTo,
        height: 62,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final n in navs.take(5))
            NavigationDestination(icon: Icon(n.icon), label: n.label),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, store) {
    if (!store.booted) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.fatalError != null) {
      return ConnectionErrorView(
        message: store.fatalError!,
        onRetry: store.connect,
      );
    }
    final nav = navs[index.clamp(0, navs.length - 1)];
    if (nav.needsSession && store.current == null && nav.label != 'Chat') {
      return EmptyHint(
        icon: Icons.forum_outlined,
        title: 'Koi session nahi',
        message: 'Pehle ek chat start karo.',
        action: FilledButton.icon(
          onPressed: () async {
            await store.newSession();
            goTo(0);
          },
          icon: const Icon(Icons.add),
          label: const Text('New chat'),
        ),
      );
    }
    return IndexedStack(index: index.clamp(0, navs.length - 1), children: [for (final n in navs) n.page]);
  }

  Future<void> _renameSession() async {
    final store = AppScope.read(context);
    final s = store.current;
    if (s == null) return;
    final c = TextEditingController(text: s.label);
    final name = await promptText(context, title: 'Session naam', initial: c.text);
    if (name != null && name.trim().isNotEmpty) {
      await store.renameSession(s.id, name.trim());
    }
  }
}

class _Title extends StatelessWidget {
  final store;
  final void Function() onRename;
  const _Title({required this.store, required this.onRename});

  @override
  Widget build(BuildContext context) {
    final s = store.current;
    final sub = [
      if (store.providerId.isNotEmpty) '${store.providerId}/${store.modelId}',
      if (store.agent.isNotEmpty) store.agent,
    ].join(' · ');
    return InkWell(
      onTap: onRename,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(s?.label ?? 'OpenCode', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (sub.isNotEmpty)
            Text(sub,
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  final bool online;
  final String version;
  final VoidCallback onTap;
  const _ConnectionDot({required this.online, required this.version, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? const Color(0xFF3DDC84) : const Color(0xFFFF5F57),
              ),
            ),
            const SizedBox(width: 5),
            Text(online ? (version.isEmpty ? 'live' : 'v$version') : 'offline',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  final int current;
  final void Function(int) onSelect;
  const _Drawer({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final s = store.current;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00C2A8)]),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OpenCode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(
                          store.paths?.directory ?? store.baseUrl,
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (s != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.forum, size: 20),
                    title: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${store.messages.length} messages', style: const TextStyle(fontSize: 11)),
                    trailing: store.busy
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                  ),
                ),
              ),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < HomeShellState.navs.length; i++)
                    ListTile(
                      dense: true,
                      selected: i == current,
                      leading: Icon(HomeShellState.navs[i].icon, size: 20),
                      title: Text(HomeShellState.navs[i].label, style: const TextStyle(fontSize: 14)),
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            const Divider(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Icon(store.vcs?.isRepo == true ? Icons.commit : Icons.code_off,
                      size: 14, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      store.vcs?.isRepo == true ? 'git: ${store.vcs!.branch}' : 'git: nahi',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
