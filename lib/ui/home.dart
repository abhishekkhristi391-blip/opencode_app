import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/store.dart';
import 'app_scope.dart';
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

  /// Keyed so the header can command the visible page (focus its search, reload,
  /// clear the terminal) instead of the shell owning a second copy of that
  /// state. The keys are stable for the life of the shell, which matters because
  /// the pages live in an IndexedStack and are never rebuilt.
  static final _pages = <Widget>[
    const ChatPage(),
    SessionsPage(key: _historyKey),
    FilesPage(key: _filesKey),
    TerminalPage(key: _terminalKey),
  ];

  static final _historyKey = GlobalKey<SessionsPageState>();
  static final _filesKey = GlobalKey<FilesPageState>();
  static final _terminalKey = GlobalKey<TerminalPageState>();

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
            child: AppHeader(
              title: tabs[index.clamp(0, tabs.length - 1)].label,
              status: StatusPill(
                state: ocLinkState(store),
                detail: store.serverVersion,
                cachedCount: store.sessions
                    .where((s) => s.title != OcStore.utilSessionTitle)
                    .length,
                onRetry: store.online ? null : store.connect,
              ),
              // Per screen. The same three icons on every tab meant Tasks opened
              // from the terminal and "New chat" threw away terminal state.
              actions: _headerActions(context, store),
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
      // 8dp of breathing room above the bar, per the nav spec: the content used
      // to run straight into the top border with no separation.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: OCSpace.navGap),
        child: BottomNav(index: index, busy: store.busy, onSelect: goTo),
      ),
    );
  }

  /// Header actions for the current tab. Each screen gets the ones that mean
  /// something there.
  List<HeaderAction> _headerActions(BuildContext context, OcStore store) {
    switch (index) {
      case 0: // Chat
        return [
          HeaderAction(
            icon: LI.tasks,
            label: S.headerTasksTooltip,
            badge: store.todos.where((t) => !t.done).length,
            onTap: () =>
                _openSessionScreen(context, S.navTasks, const TodosPage()),
          ),
          HeaderAction(
            icon: LI.plus,
            label: S.headerNewChat,
            accent: true,
            onTap: () async {
              await store.newSession();
              if (index != 0 && mounted) goTo(0);
            },
          ),
          HeaderAction(
            icon: LI.more,
            label: S.headerMore,
            onTap: () => _showMoreSheet(context),
          ),
        ];
      case 1: // History
        return [
          HeaderAction(
            icon: LI.search,
            label: S.headerSearchTooltip,
            onTap: () => _focusHistorySearch(context),
          ),
          HeaderAction(
            icon: LI.plus,
            label: S.headerNewChat,
            accent: true,
            onTap: () async {
              await store.newSession();
              if (mounted) goTo(0);
            },
          ),
        ];
      case 2: // Files
        return [
          HeaderAction(
            icon: LI.plus,
            label: S.headerNewTooltip,
            onTap: () => _createFileOrFolder(context),
          ),
          HeaderAction(
            icon: LI.refresh,
            label: S.headerRefreshTooltip,
            onTap: () => _reloadFiles(context),
          ),
        ];
      case 3: // Terminal
        return [
          HeaderAction(
            icon: LI.trash,
            label: S.headerClearTooltip,
            onTap: () => _clearTerminal(context),
          ),
          HeaderAction(
            icon: LI.plus,
            label: S.headerNewSessionTooltip,
            accent: true,
            onTap: () => _newTerminalSession(context),
          ),
        ];
      default:
        return [
          HeaderAction(
            icon: LI.more,
            label: S.headerMore,
            onTap: () => _showMoreSheet(context),
          ),
        ];
    }
  }

  void _focusHistorySearch(BuildContext context) =>
      _historyKey.currentState?.focusSearch();

  void _reloadFiles(BuildContext context) => _filesKey.currentState?.reload();

  void _createFileOrFolder(BuildContext context) =>
      _filesKey.currentState?.promptCreate();

  void _clearTerminal(BuildContext context) =>
      _terminalKey.currentState?.clear();

  void _newTerminalSession(BuildContext context) =>
      _terminalKey.currentState?.newSession();

  Widget _body(BuildContext context, store) {
    if (!store.booted) {
      return const LoadingView(label: S.connecting);
    }
    // Only take over the whole app when there is genuinely nothing to show.
    // With sessions restored from the local cache the tabs stay usable, so a
    // dead server hides live data but not the chat history already on disk.
    if (store.fatalError != null && store.sessions.isEmpty) {
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

  /// The Chat options sheet.
  ///
  /// Grouped, 56dp rows, one label per row and no repeated label/value pair.
  /// It used to be a flat list of `_SheetOption`s with the same generic icon set
  /// and rows like "Settings and token usage / Settings and token usage".
  Future<void> _showMoreSheet(BuildContext context) async {
    final store = AppScope.read(context);
    final chat = index == 0;

    void go(Widget Function() page, String title) {
      Navigator.pop(context);
      pushScreen(context, title: title, child: page());
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Scrollable + a max height: the old Column(mainAxisSize.min) ran past the
      // bottom of a small screen and put the last rows under the nav bar.
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: OCSpace.sm),
            children: [
              if (chat) ...[
                _SheetGroup(S.sheetGroupSession),
                _SheetOption(
                  icon: LI.keyboard,
                  label: S.sheetRename,
                  value: store.current?.label ?? S.dash,
                  onTap: () {
                    Navigator.pop(ctx);
                    _renameSession();
                  },
                ),
                _SheetOption(
                  icon: LI.fork,
                  label: S.sheetDiff,
                  value: store.liveDiff.isEmpty
                      ? S.navDiff
                      : store.liveDiff.length.toString(),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openSessionScreen(context, S.navDiff, const DiffPage());
                  },
                ),
                _SheetOption(
                  icon: LI.history,
                  label: S.sheetHistory,
                  // The same list the History screen counts, not
                  // `store.sessions.length`. Those differ by the utility session
                  // and by sub-sessions, which is where the "60 vs 59" came from.
                  value: visibleSessions(context, false).length.toString(),
                  onTap: () {
                    Navigator.pop(ctx);
                    goTo(1);
                  },
                ),
              ],
              _SheetGroup(S.sheetGroupAgent),
              _SheetOption(
                icon: LI.tune,
                label: S.moreModel,
                value: store.modelId.isEmpty ? S.chipPickModel : store.modelId,
                onTap: () => go(() => const ModelsPage(), S.navModels),
              ),
              _SheetOption(
                icon: LI.spark,
                label: S.moreAgent,
                value: store.agent,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAgent(context, store);
                },
              ),
              _SheetOption(
                icon: LI.done,
                label: S.sheetTools,
                value: S.moreToolsCount(store.toolsEnabled.length),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickTools(context, store);
                },
              ),
              _SheetOption(
                icon: LI.terminal,
                label: S.sheetCommands,
                value: store.commands.length.toString(),
                onTap: () => go(() => const CommandsPage(), S.navCommands),
              ),
              _SheetGroup(S.sheetGroupApp),
              _SheetOption(
                icon: LI.settings,
                // No value column on purpose: this used to read
                // "Settings and token usage" twice, once as label and once as
                // value. What it would have shown was the page title.
                label: S.sheetSettingsUsage,
                onTap: () => go(() => const SettingsPage(), S.navSettings),
              ),
              _SheetOption(
                icon: LI.spark,
                label: S.sheetAbout,
                // Version, never "Offline": About is where you look when
                // something is wrong, so its status column must not be the thing
                // that is broken.
                value: store.serverVersion.isEmpty
                    ? S.appVersion
                    : store.serverVersion,
                onTap: () => go(() => const AboutPage(), S.navAbout),
              ),
            ],
          ),
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

class BottomNav extends StatelessWidget {
  final int index;
  final bool busy;
  final ValueChanged<int> onSelect;
  const BottomNav({
    required this.index,
    required this.busy,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: SafeArea(
        top: false,
        // The bar sits above the gesture bar; this keeps the labels off it.
        minimum: const EdgeInsets.only(bottom: OCSpace.sm),
        child: Row(
          children: [
            for (var i = 0; i < HomeShellState.tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: HomeShellState.tabs[i],
                  selected: i == index,
                  // A running turn only shows on the tabs that own that output.
                  showBusy:
                      busy &&
                      (HomeShellState.tabs[i].icon == LI.terminal ||
                          HomeShellState.tabs[i].icon == LI.history),
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final bool showBusy;
  final VoidCallback onTap;
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    this.showBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    // Measured: mute #8E8993 on card #212024 is 4.74:1, above the 4.5:1 floor,
    // so the inactive label already passed. Only the active state needed help.
    final color = selected ? t.accInk : t.mute;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OCRadius.xs),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 3dp accent tab on the selected item, 28dp wide. Previously the
            // only difference was a lighter fill behind the icon, which was too
            // faint to find the current tab at a glance.
            Positioned(
              top: 0,
              child: AnimatedContainer(
                duration: OCMotion.micro,
                curve: Curves.easeOut,
                width: selected ? 28 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: t.acc,
                  borderRadius: BorderRadius.circular(OCRadius.full),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: OCSpace.sm, bottom: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      LIcon(
                        tab.icon,
                        // 24px: was 22, which read smaller than the 11px label
                        // under it needed to balance.
                        size: 24,
                        color: color,
                        // Reference `nav button.on svg { stroke-width: 2.4 }`.
                        strokeWidth: selected ? 2.4 : 1.8,
                      ),
                      if (showBusy)
                        Positioned(
                          right: -4,
                          top: -2,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: t.acc,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.card, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.meta.copyWith(
                      color: color,
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
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

/// A sheet row: 56dp, leading icon, label left, muted value right, chevron.
///
/// The value column is optional. Rows that only navigate had a value that
/// repeated the label ("Settings and token usage / Settings and token usage"),
/// which reads as a rendering bug rather than information.
class _SheetOption extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
            child: Row(
              children: [
                LIcon(icon, size: 20, color: t.mute, strokeWidth: 1.9),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.body.copyWith(color: t.ink),
                  ),
                ),
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(width: OCSpace.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: OCTypography.caption.copyWith(color: t.mute),
                    ),
                  ),
                ],
                const SizedBox(width: OCSpace.sm),
                LIcon(LI.chevronRight, size: 16, color: t.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sheet section heading. `Session` / `Agent` / `App`.
class _SheetGroup extends StatelessWidget {
  final String label;
  const _SheetGroup(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      OCSpace.screenX,
      OCSpace.lg,
      OCSpace.screenX,
      OCSpace.sm,
    ),
    child: Text(
      label.toUpperCase(),
      style: OCTypography.caption.copyWith(
        color: context.oc.mute,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),
  );
}
