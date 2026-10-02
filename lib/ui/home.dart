import 'package:flutter/material.dart';

import '../main.dart';
import 'chat.dart';
import 'commands_page.dart';
import 'diff_page.dart';
import 'files_page.dart';
import 'models_page.dart';
import 'primitives.dart';
import 'prompts.dart';
import 'sessions_page.dart';
import 'settings_page.dart';
import 'terminal_page.dart';
import 'theme.dart';
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
    NavItem(
      'Diff',
      Icons.difference_outlined,
      const DiffPage(),
      needsSession: true,
    ),
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
      drawer: _Drawer(
        current: index,
        onSelect: (i) {
          Navigator.pop(context);
          goTo(i);
        },
      ),
      appBar: AppBar(
        title: _Title(store: store, onRename: _renameSession),
        actions: [
          _ConnectionDot(
            online: store.online,
            version: store.serverVersion,
            onTap: () => goTo(8),
          ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: goTo,
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
      return const LoadingView(
        label: 'OpenCode server se connect ho rahe hain',
      );
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
        action: OCButton(
          onPressed: () async {
            await store.newSession();
            goTo(0);
          },
          icon: Icons.add,
          label: 'New chat',
          variant: OCButtonVariant.primaryBlack,
        ),
      );
    }
    return IndexedStack(
      index: index.clamp(0, navs.length - 1),
      children: [for (final n in navs) n.page],
    );
  }

  Future<void> _renameSession() async {
    final store = AppScope.read(context);
    final s = store.current;
    if (s == null) return;
    final c = TextEditingController(text: s.label);
    final name = await promptText(
      context,
      title: 'Session naam',
      initial: c.text,
    );
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
          Text(
            s?.label ?? 'OpenCode',
            style: OCTypography.h3.copyWith(color: OCColors.textPrimary),
          ),
          if (sub.isNotEmpty)
            Text(
              sub,
              style: OCTypography.micro.copyWith(color: OCColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  final bool online;
  final String version;
  final VoidCallback onTap;
  const _ConnectionDot({
    required this.online,
    required this.version,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: online ? 'Server online, version $version' : 'Server offline',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          // 44px tap target around a small status dot.
          constraints: const BoxConstraints(minHeight: OCSpace.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: OCSpace.sm + 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: online ? OCColors.green : OCColors.red,
                  border: Border.all(color: OCColors.surface, width: 2),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Text(
                online ? (version.isEmpty ? 'live' : 'v$version') : 'offline',
                style: OCTypography.micro.copyWith(
                  color: OCColors.textSecondary,
                ),
              ),
            ],
          ),
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
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.lg,
                OCSpace.screenX,
                OCSpace.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(OCRadius.tile),
                      gradient: OCGradient.ctaOrangeSoft,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.bolt, color: OCColors.textInverse),
                  ),
                  const SizedBox(width: OCSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OpenCode',
                          style: OCTypography.h3.copyWith(
                            color: OCColors.textPrimary,
                          ),
                        ),
                        Text(
                          store.paths?.directory ?? store.baseUrl,
                          style: OCTypography.micro.copyWith(
                            color: OCColors.textSecondary,
                          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.screenX,
                ),
                child: OCInnerCell(
                  child: Row(
                    children: [
                      const OCIconTile(
                        icon: Icons.forum_outlined,
                        accent: OCAccent.purple,
                        size: 32,
                        iconSize: 17,
                      ),
                      const SizedBox(width: OCSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OCTypography.bodyStrong.copyWith(
                                color: OCColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${store.messages.length} messages',
                              style: OCTypography.micro.copyWith(
                                color: OCColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (store.busy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: OCProgressRing(
                            value: 0.6,
                            size: 16,
                            stroke: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: OCSpace.sm),
            const Divider(height: OCSpace.lg),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < HomeShellState.navs.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: OCSpace.md,
                        vertical: OCSpace.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: i == current ? OCColors.orangeTint : null,
                        borderRadius: BorderRadius.circular(OCRadius.inner),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(OCRadius.inner),
                        ),
                        selected: i == current,
                        selectedTileColor: Colors.transparent,
                        leading: OCIconTile(
                          icon: HomeShellState.navs[i].icon,
                          accent: i == current
                              ? OCAccent.orange
                              : OCAccent.neutral,
                          size: 32,
                          iconSize: 17,
                        ),
                        title: Text(
                          HomeShellState.navs[i].label,
                          style: OCTypography.body.copyWith(
                            color: OCColors.textPrimary,
                            fontWeight: i == current
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: OCSpace.md),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                0,
                OCSpace.screenX,
                OCSpace.md,
              ),
              child: Row(
                children: [
                  Icon(
                    store.vcs?.isRepo == true ? Icons.commit : Icons.code_off,
                    size: 14,
                    color: OCColors.textTertiary,
                  ),
                  const SizedBox(width: OCSpace.sm),
                  Expanded(
                    child: Text(
                      store.vcs?.isRepo == true
                          ? 'git: ${store.vcs!.branch}'
                          : 'git: nahi',
                      style: OCTypography.micro.copyWith(
                        color: OCColors.textSecondary,
                      ),
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
