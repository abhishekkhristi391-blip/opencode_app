import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import 'about_page.dart';
import 'chat.dart';
import 'commands_page.dart';
import 'diff_page.dart';
import 'files_page.dart';
import 'line_icons.dart';
import 'models_page.dart';
import 'primitives.dart';
import 'prompts.dart';
import 'sessions_page.dart';
import 'settings_page.dart';
import 'terminal_page.dart';
import 'theme.dart';
import 'todos_page.dart';
import 'widgets.dart';

/// One bottom-navigation destination. There is no drawer and no hamburger:
/// everything that used to live in the drawer is either a tab or behind the
/// More button in the header.
class _Tab {
  final String label;
  final LI icon;
  const _Tab(this.label, this.icon);
}

/// The single shell: a header (title, connection status, three actions), the
/// current page, and a four-destination bottom bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  /// Exactly four tabs. More is not a tab — it is the third header button,
  /// which opens a bottom sheet.
  static const tabs = <_Tab>[
    _Tab(S.navChat, LI.chat),
    _Tab(S.navSessions, LI.history),
    _Tab(S.navFiles, LI.folder),
    _Tab(S.navTerminal, LI.terminal),
  ];

  static const _pages = <Widget>[
    ChatPage(),
    SessionsPage(),
    FilesPage(),
    TerminalPage(),
  ];

  void goTo(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final t = context.oc;

    return Scaffold(
      backgroundColor: t.bg,
      // The reference pads for the notch inside the app itself rather than
      // letting the Scaffold do it, so the header keeps its own rhythm.
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _Header(
              title: tabs[index.clamp(0, tabs.length - 1)].label,
              online: store.online,
              onTasks: () =>
                  _openSessionScreen(context, S.navTasks, const TodosPage()),
              onNewChat: () async {
                await store.newSession();
                if (index != 0 && mounted) goTo(0);
              },
              onMore: () => _showMoreSheet(context),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _body(context, store),
                const Positioned.fill(child: PromptOverlay()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(index: index, onSelect: goTo),
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

  /// Reference `header`: a 18px/800 title with a 12px status line underneath
  /// a 7px dot, then Tasks, New chat and More.
  ///
  /// The connection dot is red whenever the server is unreachable, which is
  /// the same signal the reference uses for its error screen.
  Future<void> _showMoreSheet(BuildContext context) async {
    final store = AppScope.read(context);
    final chat = index == 0;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reuse the composer's model / agent / tools panel so the pill and
            // the sheet can never drift apart.
            _SheetOption(
              label: S.moreModel,
              value: store.modelId.isEmpty ? S.chipPickModel : store.modelId,
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModelsPage()),
                );
              },
            ),
            _SheetOption(
              label: S.moreAgent,
              value: store.agent,
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickAgent(context, store);
              },
            ),
            _SheetOption(
              label: S.moreTools,
              value: S.moreToolsCount(store.toolsEnabled.length),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickTools(context, store);
              },
            ),
            _SheetOption(
              label: S.moreChatHistory,
              value: store.sessions.length.toString(),
              onTap: () {
                Navigator.pop(sheetCtx);
                goTo(1);
              },
            ),
            _SheetOption(
              label: S.moreSettings,
              value: S.moreSettings,
              onTap: () {
                Navigator.pop(sheetCtx);
                pushScreen(
                  context,
                  title: S.navSettings,
                  child: const SettingsPage(),
                );
              },
            ),
            _SheetOption(
              label: S.moreCommands,
              value: store.commands.length.toString(),
              onTap: () {
                Navigator.pop(sheetCtx);
                pushScreen(
                  context,
                  title: S.navCommands,
                  child: const CommandsPage(),
                );
              },
            ),
            _SheetOption(
              label: S.navAbout,
              value: store.online
                  ? S.serverOnlineVersion(store.serverVersion)
                  : S.serverOffline,
              onTap: () {
                Navigator.pop(sheetCtx);
                pushScreen(
                  context,
                  title: S.navAbout,
                  child: const AboutPage(),
                );
              },
            ),
            // Rename and Diff are chat-scoped, so they only show on Chat. They
            // used to sit in the app bar; the reference's three-icon header has
            // no room for them, so More keeps them reachable.
            if (chat && store.current != null)
              _SheetOption(
                label: S.sessionsRename,
                value: store.current!.label,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _renameSession();
                },
              ),
            if (chat)
              _SheetOption(
                label: S.navDiff,
                value: store.liveDiff.length.toString(),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _openSessionScreen(context, S.navDiff, const DiffPage());
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAgent(BuildContext context, OcStore store) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => RadioGroup<String>(
        groupValue: store.agent,
        onChanged: (v) {
          if (v != null) store.setAgent(v);
          Navigator.pop(sheetCtx);
        },
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Text(
                  S.moreAgent,
                  style: OCTypography.bodyStrong.copyWith(
                    color: context.oc.mute,
                  ),
                ),
              ),
              for (final a in store.agents)
                RadioListTile<String>(
                  value: a.name,
                  dense: true,
                  title: Text(a.name, style: OCTypography.body),
                  subtitle: a.description.isEmpty
                      ? null
                      : Text(
                          a.description,
                          maxLines: 2,
                          style: OCTypography.micro,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTools(BuildContext context, OcStore store) async {
    List<String> ids;
    try {
      ids = await store.api.toolIds();
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
      return;
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (c, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(S.moreTools, style: OCTypography.bodyStrong),
                    ),
                    TextButton(
                      onPressed: () {
                        store.toolsEnabled.clear();
                        setSheet(() {});
                      },
                      child: Text(S.toolsEnableAll),
                    ),
                  ],
                ),
              ),
              Text(
                S.toolsSheetHint,
                style: OCTypography.micro.copyWith(color: context.oc.mute),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final id in ids)
                      CheckboxListTile(
                        dense: true,
                        value: store.toolsEnabled.contains(id),
                        title: Text(id, style: OCTypography.mono(size: 12.5)),
                        onChanged: (v) {
                          store.toggleTool(id, v ?? false);
                          setSheet(() {});
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Session-scoped screens guard against "no session yet" themselves.
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

class _Header extends StatelessWidget {
  final String title;
  final bool online;
  final VoidCallback onTasks;
  final VoidCallback onNewChat;
  final VoidCallback onMore;

  const _Header({
    required this.title,
    required this.online,
    required this.onTasks,
    required this.onNewChat,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Padding(
      // Reference: 10px 12px 6px 18px.
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.h1.copyWith(
                    color: t.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: online ? t.ok : t.err,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      online ? S.headerConnected : S.headerOffline,
                      style: OCTypography.micro.copyWith(color: t.mute),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Exactly three actions, 40x40 each.
          _HeaderBtn(icon: LI.tasks, label: S.headerTasks, onTap: onTasks),
          _HeaderBtn(icon: LI.plus, label: S.headerNewChat, onTap: onNewChat),
          _HeaderBtn(icon: LI.more, label: S.headerMore, onTap: onMore),
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  const _HeaderBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => LIconButton(
    icon: icon,
    label: label,
    size: 22,
    color: context.oc.ink,
    onTap: onTap,
    // 40px square with the reference's 12px corner on the pressed state.
    padding: const EdgeInsets.all(9),
  );
}

/// Reference `nav`: four equal columns, 11px/600 labels, muted until active,
/// accent-ink plus a heavier stroke when selected.
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const _BottomBar({required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (var i = 0; i < HomeShellState.tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: HomeShellState.tabs[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = selected ? t.accInk : t.mute;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LIcon(
                tab.icon,
                size: 22,
                color: color,
                // Reference `nav button.on svg { stroke-width: 2.4 }`.
                strokeWidth: selected ? 2.4 : 1.8,
              ),
              const SizedBox(height: 3),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OCTypography.micro.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.opt` line for the More sheet: label left, muted value + chevron right.
class _SheetOption extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SheetOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OCTypography.body.copyWith(color: t.ink),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: OCTypography.body.copyWith(color: t.mute),
              ),
            ),
            const SizedBox(width: 8),
            LIcon(LI.chevronRight, size: 16, color: t.mute),
          ],
        ),
      ),
    );
  }
}
