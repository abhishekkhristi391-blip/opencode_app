import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
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

/// A destination the drawer can switch to.
class _Tab {
  final String label;
  final LI icon;

  const _Tab(this.label, this.icon);
}

/// The single shell: a header (drawer handle, title, connection status, actions,
/// avatar), the current page, and the navigation drawer.
///
/// There is no bottom navigation bar. It duplicated the header's own actions
/// and pushed the composer above a permanent strip on every screen; the
/// reference navigates from the drawer instead.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  /// The four pages kept alive in the shell. Todos and Commands are pushed as
  /// screens rather than held in the stack: they are not a tab you sit on.
  static const tabs = <_Tab>[
    _Tab(S.drawerNavChats, LI.chat),
    _Tab(S.drawerNavHistory, LI.history),
    _Tab(S.drawerNavFiles, LI.folder),
    _Tab(S.drawerNavTerminal, LI.terminal),
  ];

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

  /// Closes the drawer and switches pages. Every drawer destination goes
  /// through here so the overlay is never left mounted over the new page.
  void _navigate(int i) {
    Navigator.of(context).pop();
    if (index != i) setState(() => index = i);
  }

  void _pushAndClose(Widget Function() page, String title) {
    Navigator.of(context).pop();
    pushScreen(context, title: title, child: page());
  }

  /// The reference labels the Files row with the workspace it points at.
  static String? _worktree(OcStore store) {
    final dir = store.paths?.worktree ?? '';
    return dir.isEmpty ? null : dir;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final t = context.oc;

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          AppHeader(
            title: tabs[index.clamp(0, tabs.length - 1)].label,
            status: StatusPill(
              state: ocLinkState(store),
              detail: store.serverVersion,
              cachedCount: store.sessions
                  .where((s) => s.title != OcStore.utilSessionTitle)
                  .length,
              onRetry: store.online ? null : store.connect,
            ),
            leading: LIconButton(
              icon: LI.menu,
              label: S.drawerOpenTooltip,
              onTap: _showDrawer,
            ),
            avatar: _AvatarButton(onTap: () => _showAvatarMenu(context)),
            actions: _headerActions(context, store),
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

  /// The navigation drawer: identity and version, the destinations, a recent
  /// chat feed, and the footer identity plus connection line.
  Future<void> _showDrawer() async {
    final store = AppScope.read(context);
    final pendingTodos = store.todos.where((t) => !t.done).length;
    final pendingPrompts = store.permissions.length + store.questions.length;
    final pending = pendingTodos + pendingPrompts;
    // The feed is the same list the History screen shows, so the drawer never
    // offers a session the page behind it does not.
    final recents = visibleSessions(context, true)
      ..sort((a, b) => b.updated.compareTo(a.updated));
    final visible = recents.take(8).toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // The panel is the full height of the screen in the reference, not a
      // sheet that grows with its content.
      constraints: const BoxConstraints.expand(),
      backgroundColor: Colors.transparent,
      barrierColor: OCColors.surfaceLowest.withValues(alpha: 0.80),
      builder: (ctx) => _Drawer(
        version: store.serverVersion,
        host: _hostLabel(store),
        index: index,
        pending: pendingTodos > 0 ? pendingTodos : (pendingPrompts > 0 ? pendingPrompts : 0),
        recents: visible,
        currentId: store.current?.id,
        state: ocLinkState(store),
        onClose: () => Navigator.pop(ctx),
        onNewChat: () async {
          Navigator.pop(ctx);
          await store.newSession();
          if (mounted) goTo(0);
        },
        onPick: _navigate,
        onPushTodos: () =>
            _pushAndClose(() => const TodosPage(), S.drawerNavTodos),
        onPushCommands: () =>
            _pushAndClose(() => const CommandsPage(), S.navCommands),
        onOpenSession: (s) {
          Navigator.pop(ctx);
          store.openSession(s.id);
        },
      ),
    );
  }

  /// The server menu, anchored under the avatar.
  ///
  /// The reference also offers Resource Usage (CPU/RAM), a latency pill and a
  /// TLS session id. None of those exist in this client and inventing them
  /// would be showing numbers the app never measured, so they are left out.
  Future<void> _showAvatarMenu(BuildContext context) async {
    final store = AppScope.read(context);
    final host = _hostLabel(store);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints.expand(),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (ctx) => _ServerMenu(
        host: host,
        version: store.serverVersion,
        state: ocLinkState(store),
        onClose: () => Navigator.pop(ctx),
        onOpen: (page, title) => _pushAndClose(page, title),
        onServer: () => _pushAndClose(() => const SettingsPage(), S.menuSwitchServer),
      ),
    );
  }

  /// `host:port` from the address the store is actually configured with, or an
  /// em dash when it has not resolved one yet.
  static String _hostLabel(OcStore store) {
    final raw = store.baseUrl.trim();
    if (raw.isEmpty) return S.dash;
    final noScheme = raw.replaceFirst(RegExp(r'^[a-z]+://'), '');
    final host = noScheme.split('/').first;
    return host.isEmpty ? S.dash : host;
  }

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

/// The avatar trigger in the header: the reference's `bg-primary` circle with
/// a person glyph in `on-primary`, at 32dp inside a 48dp target.
class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.menuOpenTooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: S.menuOpenTooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: OCSpace.tapTarget,
              height: OCSpace.tapTarget,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: OCColors.cta,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: LIcon(LI.person, size: 18, color: OCColors.onCta),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A pill badge used in the drawer: `bg-surface-container-highest` for neutral
/// values, `bg-secondary-container` for the pending-todos count.
class _DrawerBadge extends StatelessWidget {
  const _DrawerBadge(this.label, {this.accent = false, this.pill = false});
  final String label;
  final bool accent;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: EdgeInsets.symmetric(
        horizontal: accent ? OCSpace.sm : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accent ? OCColors.secondary : OCColors.surfaceHighest,
        borderRadius: BorderRadius.circular(
          pill ? OCRadius.full : OCRadius.xs,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: OCTypography.micro.copyWith(
          color: accent ? OCColors.onSecondary : OCColors.textTertiary,
        ),
      ),
    );
  }
}

/// The navigation drawer. 82% of the width, capped at 340, on
/// `surface-container-low`, with the destinations above a recent-chat feed.
class _Drawer extends StatelessWidget {
  const _Drawer({
    required this.version,
    required this.host,
    required this.index,
    required this.pending,
    required this.recents,
    required this.currentId,
    required this.state,
    required this.onClose,
    required this.onNewChat,
    required this.onPick,
    required this.onPushTodos,
    required this.onPushCommands,
    required this.onOpenSession,
  });

  final String version;
  final String host;
  final int index;
  final int pending;
  final List<Session> recents;
  final String? currentId;
  final OcLinkState state;
  final VoidCallback onClose;
  final VoidCallback onNewChat;
  final ValueChanged<int> onPick;
  final VoidCallback onPushTodos;
  final VoidCallback onPushCommands;
  final ValueChanged<Session> onOpenSession;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          width: 340,
          color: OCColors.surface,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OCSpace.screenX,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: OCSpace.md,
                          bottom: OCSpace.lg,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      S.appName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: OCTypography.headline.copyWith(
                                        color: OCColors.cta,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: OCSpace.sm),
                                  _DrawerBadge(
                                    version.isEmpty ? S.appVersion : version,
                                    pill: true,
                                  ),
                                ],
                              ),
                            ),
                            _DrawerIconButton(
                              icon: LI.close,
                              label: S.drawerCloseTooltip,
                              onTap: onClose,
                            ),
                          ],
                        ),
                      ),
                      _DrawerNavRow(
                        icon: LI.chat,
                        label: S.drawerNavChats,
                        selected: index == 0,
                        onTap: () => onPick(0),
                      ),
                      _DrawerNavRow(
                        icon: LI.history,
                        label: S.drawerNavHistory,
                        selected: index == 1,
                        onTap: () => onPick(1),
                      ),
                      _DrawerNavRow(
                        icon: LI.folder,
                        label: S.drawerNavFiles,
                        selected: index == 2,
                        value: HomeShellState._worktree(
                          AppScope.read(context),
                        ),
                        onTap: () => onPick(2),
                      ),
                      _DrawerNavRow(
                        icon: LI.terminal,
                        label: S.drawerNavTerminal,
                        selected: index == 3,
                        onTap: () => onPick(3),
                      ),
                      _DrawerNavRow(
                        icon: LI.tasks,
                        label: S.drawerNavTodos,
                        value: pending > 0 ? S.drawerPending(pending) : null,
                        valueAccent: true,
                        onTap: onPushTodos,
                      ),
                      _DrawerNavRow(
                        icon: LI.spark,
                        label: S.drawerNavCommands,
                        onTap: onPushCommands,
                      ),
                      const SizedBox(height: OCSpace.lg),
                      const Divider(height: 1, color: OCColors.surfaceVariant),
                      const SizedBox(height: OCSpace.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.drawerRecents.toUpperCase(),
                              style: OCTypography.micro.copyWith(
                                color: OCColors.textTertiary,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OCSpace.sm),
                      if (recents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: OCSpace.md,
                          ),
                          child: Text(
                            S.drawerRecentsEmpty,
                            style: OCTypography.caption.copyWith(
                              color: t.mute,
                            ),
                          ),
                        )
                      else
                        for (final s in recents)
                          _DrawerRecentRow(
                            session: s,
                            active: s.id == currentId,
                            onTap: () => onOpenSession(s),
                          ),
                    ],
                  ),
                ),
              ),
              _DrawerFooter(
                host: host,
                state: state,
                onNewChat: onNewChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 56dp drawer destination. Selected = `surface-container-high` with white
/// text and a terracotta dot on the right, never colour alone.
class _DrawerNavRow extends StatelessWidget {
  const _DrawerNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.value,
    this.valueAccent = false,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? value;
  final bool valueAccent;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Padding(
      padding: const EdgeInsets.only(bottom: OCSpace.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.sm),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
            decoration: BoxDecoration(
              color: selected ? OCColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(OCRadius.sm),
            ),
            child: Row(
              children: [
                LIcon(
                  icon,
                  size: 22,
                  color: selected ? OCColors.orange : t.mute,
                ),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.meta.copyWith(
                      color: selected ? OCColors.cta : t.mute,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(width: OCSpace.sm),
                  _DrawerBadge(value!, accent: valueAccent, pill: valueAccent),
                ] else if (selected) ...[
                  const SizedBox(width: OCSpace.sm),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: OCColors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A recent-chat row. Active session gets `surface-container-high` plus a
/// terracotta bar on the leading edge.
class _DrawerRecentRow extends StatelessWidget {
  const _DrawerRecentRow({
    required this.session,
    required this.active,
    required this.onTap,
  });

  final Session session;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final where = session.directory.trim();
    final age = fmtAge(session.updated);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.sm),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.sm + 2,
              10,
              OCSpace.sm + 2,
              10,
            ),
            decoration: BoxDecoration(
              color: active ? OCColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(OCRadius.sm),
            ),
            child: Row(
              children: [
                if (active)
                  Container(
                    width: 6,
                    height: 24,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: OCColors.orange,
                      borderRadius: BorderRadius.circular(OCRadius.full),
                    ),
                  ),
                LIcon(
                  LI.chat,
                  size: 19,
                  color: active ? OCColors.orange : OCColors.textTertiary,
                ),
                const SizedBox(width: OCSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.body.copyWith(
                          color: active ? OCColors.cta : t.mute,
                        ),
                      ),
                      if (where.isNotEmpty || age.isNotEmpty)
                        Text(
                          [baseName(where), age]
                              .where((e) => e.isNotEmpty)
                              .join(' \u2022 '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.micro.copyWith(color: t.mute),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer footer: identity, the white New chat pill, and the connection line.
class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({
    required this.host,
    required this.state,
    required this.onNewChat,
  });

  final String host;
  final OcLinkState state;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = switch (state) {
      OcLinkState.connected => t.ok,
      OcLinkState.reconnecting => t.warn,
      OcLinkState.offline || OcLinkState.offlineCached => t.err,
    };
    return Container(
      color: OCColors.surfaceElevated,
      padding: const EdgeInsets.fromLTRB(
        OCSpace.screenX,
        OCSpace.md,
        OCSpace.screenX,
        0,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OCAvatar(label: host, size: 40, accent: OCAccent.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.meta.copyWith(
                          color: OCColors.cta,
                        ),
                      ),
                      Text(
                        S.drawerIdentity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.micro.copyWith(
                          color: OCColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: OCSpace.sm),
                Semantics(
                  button: true,
                  label: S.drawerNewChat,
                  excludeSemantics: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onNewChat,
                      borderRadius: BorderRadius.circular(OCRadius.full),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: OCSpace.tapTarget,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: OCSpace.cardPad,
                        ),
                        decoration: BoxDecoration(
                          color: OCColors.cta,
                          borderRadius: BorderRadius.circular(OCRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LIcon(
                              LI.plus,
                              size: 18,
                              color: OCColors.onCta,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              S.drawerNewChat,
                              style: OCTypography.meta.copyWith(
                                color: OCColors.onCta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OCSpace.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: OCSpace.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: OCColors.surface,
                borderRadius: BorderRadius.circular(OCRadius.xs),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  const SizedBox(width: OCSpace.sm),
                  Expanded(
                    child: Text(
                      S.drawerConnectedTo(host),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.micro.copyWith(color: t.mute),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OCSpace.md),
          ],
        ),
      ),
    );
  }
}

/// A round icon button: `surface-container` fill, 48dp target.
class _DrawerIconButton extends StatelessWidget {
  const _DrawerIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: OCSpace.tapTarget,
              height: OCSpace.tapTarget,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: OCColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: LIcon(icon, size: 20, color: context.oc.mute),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The server menu, anchored under the avatar.
///
/// The reference shows a latency pill, a TLS session id and a Resource Usage
/// row. This client measures none of them, so the rows that need real numbers
/// are absent rather than showing placeholders.
class _ServerMenu extends StatelessWidget {
  const _ServerMenu({
    required this.host,
    required this.version,
    required this.state,
    required this.onClose,
    required this.onOpen,
    required this.onServer,
  });

  final String host;
  final String version;
  final OcLinkState state;
  final VoidCallback onClose;
  final void Function(Widget Function() page, String title) onOpen;
  final VoidCallback onServer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OCSpace.md,
          0,
          OCSpace.md,
          0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Material(
            color: OCColors.surfaceElevated,
            borderRadius: BorderRadius.circular(OCRadius.lg),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shadowColor: const Color(0xB3000000),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ServerMenuHeader(
                  host: host,
                  version: version,
                  state: state,
                  onClose: onClose,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: OCSpace.xs,
                  ),
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: LI.server,
                        label: S.menuSwitchServer,
                        value: host,
                        onTap: onServer,
                      ),
                      _MenuRow(
                        icon: LI.key,
                        label: S.menuProviders,
                        value: S.moreModel,
                        onTap: () => onOpen(
                          () => const SettingsPage(),
                          S.menuProviders,
                        ),
                      ),
                      _MenuRow(
                        icon: LI.settings,
                        label: S.menuSettings,
                        onTap: () => onOpen(
                          () => const SettingsPage(),
                          S.navSettings,
                        ),
                      ),
                      _MenuRow(
                        icon: LI.info,
                        label: S.menuAbout,
                        value: version.isEmpty ? S.appVersion : version,
                        onTap: () => onOpen(
                          () => const AboutPage(),
                          S.navAbout,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OCSpace.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Identity, server version and the connection state at the top of the menu.
class _ServerMenuHeader extends StatelessWidget {
  const _ServerMenuHeader({
    required this.host,
    required this.version,
    required this.state,
    required this.onClose,
  });

  final String host;
  final String version;
  final OcLinkState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = switch (state) {
      OcLinkState.connected => t.ok,
      OcLinkState.reconnecting => t.warn,
      OcLinkState.offline || OcLinkState.offlineCached => t.err,
    };
    return Container(
      width: double.infinity,
      color: OCColors.surfaceHigh.withValues(alpha: 0.60),
      padding: const EdgeInsets.all(OCSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    OCAvatar(
                      label: host,
                      size: 48,
                      accent: OCAccent.orange,
                      status: switch (state) {
                        OcLinkState.connected => OCStatus.online,
                        OcLinkState.reconnecting => OCStatus.busy,
                        OcLinkState.offline ||
                        OcLinkState.offlineCached => OCStatus.offline,
                      },
                    ),
                    const SizedBox(width: OCSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            host,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.meta.copyWith(color: t.ink),
                          ),
                          Text(
                            version.isEmpty
                                ? S.appVersion
                                : S.menuServerVersion(version),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.micro.copyWith(color: t.mute),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _DrawerIconButton(
                icon: LI.close,
                label: S.menuCloseTooltip,
                onTap: onClose,
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          // The state is spelled out, never left to the dot colour alone.
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: Text(
                  state.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.micro.copyWith(
                    color: t.mute,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A menu row: 36dp icon tile on `surface-container-highest`, label, optional
/// value, chevron.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OCRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OCSpace.md,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: OCColors.surfaceHighest,
                    borderRadius: BorderRadius.circular(OCRadius.xs),
                  ),
                  child: Center(
                    child: LIcon(icon, size: 20, color: t.mute),
                  ),
                ),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.meta.copyWith(color: t.ink),
                      ),
                      if (value != null && value!.isNotEmpty)
                        Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.micro.copyWith(color: t.mute),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: OCSpace.sm),
                LIcon(LI.chevronRight, size: 18, color: OCColors.textTertiary),
              ],
            ),
          ),
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
