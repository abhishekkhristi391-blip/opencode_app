import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import 'chat.dart';
import 'diff_page.dart';
import 'files_page.dart';
import 'more_page.dart';
import 'primitives.dart';
import 'prompts.dart';
import 'sessions_page.dart';
import 'terminal_page.dart';
import 'theme.dart';
import 'todos_page.dart';
import 'widgets.dart';

/// One bottom-navigation destination. There is no drawer and no hamburger:
/// everything that used to live in the drawer is either a tab or inside More.
class _Tab {
  final String label;
  final IconData icon;
  const _Tab(this.label, this.icon);
}

/// The single shell: one NavigationBar with five destinations, one app bar
/// whose title is always the current screen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  static const tabs = <_Tab>[
    _Tab(S.navChat, Icons.forum_outlined),
    _Tab(S.navSessions, Icons.history),
    _Tab(S.navFiles, Icons.folder_outlined),
    _Tab(S.navTerminal, Icons.terminal),
    _Tab(S.navMore, Icons.more_horiz),
  ];

  static const _pages = <Widget>[
    ChatPage(),
    SessionsPage(),
    FilesPage(),
    TerminalPage(),
    MorePage(),
  ];

  void goTo(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: _appBar(context, store),
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
          for (final t in tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }

  /// Title always names the current screen. Diff and Tasks belong to the chat
  /// session, so they live in the chat app bar; new chat is only meaningful
  /// on Chat and Sessions.
  PreferredSizeWidget _appBar(BuildContext context, store) {
    final tab = tabs[index.clamp(0, tabs.length - 1)];
    final chat = index == 0;
    final sessions = index == 1;

    return AppBar(
      title: Text(tab.label),
      actions: [
        if (chat) ...[
          if (store.current != null)
            IconButton(
              tooltip: S.chatRenameTooltip,
              icon: const Icon(Icons.drive_file_rename_outlined),
              onPressed: _renameSession,
            ),
          IconButton(
            tooltip: S.chatDiffTooltip,
            icon: const Icon(Icons.difference_outlined),
            onPressed: () =>
                _openSessionScreen(context, S.navDiff, const DiffPage()),
          ),
          IconButton(
            tooltip: S.chatTasksTooltip,
            icon: const Icon(Icons.checklist),
            onPressed: () =>
                _openSessionScreen(context, S.navTasks, const TodosPage()),
          ),
        ],
        if (chat || sessions)
          IconButton(
            tooltip: S.chatNewChatTooltip,
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () async {
              await store.newSession();
              if (chat || index == 1) goTo(0);
            },
          ),
      ],
    );
  }

  Widget _body(BuildContext context, store) {
    if (!store.booted) {
      return const LoadingView(label: S.connecting);
    }
    if (store.fatalError != null) {
      return ConnectionErrorView(
        message: store.fatalError!,
        onRetry: store.connect,
      );
    }
    return IndexedStack(
      index: index.clamp(0, _pages.length - 1),
      children: _pages,
    );
  }

  /// Session-scoped screens are pushed from the chat app bar, so they carry
  /// their own title bar and guard against "no session yet" themselves.
  void _openSessionScreen(BuildContext context, String title, Widget page) {
    final store = AppScope.read(context);
    pushScreen(
      context,
      title: title,
      child: store.current == null
          ? EmptyHint(
              icon: Icons.forum_outlined,
              title: S.chatNoSessionTitle,
              message: S.chatNoSessionBody,
              action: OCButton(
                onPressed: () async {
                  await store.newSession();
                  if (context.mounted) goTo(0);
                },
                icon: Icons.add,
                label: S.newChat,
                variant: OCButtonVariant.primaryBlack,
                expand: false,
              ),
            )
          : page,
    );
  }

  Future<void> _renameSession() async {
    final store = AppScope.read(context);
    final s = store.current;
    if (s == null) return;
    final name = await promptText(
      context,
      title: S.sessionsRename,
      initial: s.label,
      confirm: S.save,
    );
    if (name != null && name.trim().isNotEmpty) {
      await store.renameSession(s.id, name.trim());
    }
  }
}
