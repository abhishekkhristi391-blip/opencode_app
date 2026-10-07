part of '../home.dart';

/// Keeps the Velo mascot's mood in sync with the app's real run state.
///
/// Runs can go silent for a while, and an error is only worth showing while it
/// is still the latest thing that happened, so the mood is driven off the
/// store's signals (`busy`, `pendingPromptCount`, `sessionError`) rather than
/// guessed from message timestamps. A run that finishes cleanly gets a brief
/// `success` burst before dropping back to `idle`.
class _VeloLink extends StatefulWidget {
  const _VeloLink({required this.store, required this.child});

  final OcStore store;
  final Widget child;

  @override
  State<_VeloLink> createState() => _VeloLinkState();
}

class _VeloLinkState extends State<_VeloLink> {
  VeloMood _last = VeloMood.idle;
  bool _wasBusy = false;
  Timer? _reset;

  @override
  void initState() {
    super.initState();
    _sync();
    widget.store.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant _VeloLink old) {
    super.didUpdateWidget(old);
    if (old.store != widget.store) {
      old.store.removeListener(_sync);
      widget.store.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_sync);
    _reset?.cancel();
    super.dispose();
  }

  void _sync() {
    final s = widget.store;
    final hasError = (s.sessionError ?? '').isNotEmpty;
    final hadRun = _wasBusy;
    _wasBusy = s.busy;

    final VeloMood m;
    if (s.pendingPromptCount > 0) {
      m = VeloMood.waiting;
    } else if (s.busy) {
      m = VeloMood.running;
    } else if (hasError) {
      m = VeloMood.error;
    } else {
      m = VeloMood.idle;
    }

    // A run just ended without an error: a short happy burst, then idle.
    if (hadRun && !s.busy && !hasError) {
      _last = VeloMood.success;
      veloMood.value = VeloMood.success;
      _reset?.cancel();
      _reset = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (s.busy || (s.sessionError ?? '').isNotEmpty) return;
        _last = VeloMood.idle;
        veloMood.value = VeloMood.idle;
      });
      return;
    }

    if (m != _last) {
      _last = m;
      _reset?.cancel();
      veloMood.value = m;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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

  void _pushAndClose(
  Widget Function() page,
  String title, [
  List<Widget> actions = const [],
]) {
    Navigator.of(context).pop();
    pushScreen(context, title: title, child: page(), actions: actions);
  }

  /// The Tasks screen's own title-bar action. The stream is the fast path, but a
  /// user staring at a number they do not believe should not have to wait for
  /// the next event to be told otherwise.
  static List<Widget> _todosActions(OcStore store) => [
    IconButton(
      tooltip: S.refresh,
      icon: const Icon(Icons.refresh),
      onPressed: store.refreshTodos,
    ),
  ];

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
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                LIconButton(
                  icon: LI.menu,
                  label: S.drawerOpenTooltip,
                  onTap: _showDrawer,
                ),
                // The badge on the avatar hides behind the drawer and behind the
                // header on narrow screens, so the drawer handle carries a plain
                // dot too: one glance anywhere in the app has to be enough.
                if (store.pendingPromptCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: t.acc,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.bg, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            avatar: _AvatarButton(
              onTap: () => _showAvatarMenu(context),
              pending: store.pendingPromptCount,
            ),
            trailing: _VeloLink(
              store: store,
              child: const VeloBadge(size: 40),
            ),
            actions: _headerActions(context, store),
          ),
          // No PromptOverlay here: it is mounted above the whole Navigator in
          // main.dart's `MaterialApp.builder`. Inside this Stack it covered the
          // four tabs but not a pushed route, so opening Files or Settings hid
          // a waiting approval completely.
          Expanded(child: _body(context, store)),
        ],
      ),
    );
  }

  /// Header actions for the current tab. Each screen gets the ones that mean
  /// something there.
  List<Widget> _headerActions(BuildContext context, OcStore store) {
    switch (index) {
      case 0: // Chat
        return [
          // The badge reads the list live through `todoList` instead of the
          // store's own notifications: a todo change must repaint this one
          // number, not the transcript sitting underneath it.
          ListenableBuilder(
            listenable: store.todoList,
            builder: (ctx, _) => HeaderAction(
              icon: LI.tasks,
              label: S.headerTasksTooltip,
              badge: store.openTodos,
              onTap: () => _openSessionScreen(
                ctx,
                S.navTasks,
                const TodosPage(),
                _todosActions(store),
              ),
            ),
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
      builder: (ctx) => ListenableBuilder(
        // The todo count is read here, while the sheet is open, so it must
        // follow the list rather than freeze at whatever it was when the drawer
        // opened. Todo count only: a waiting approval is not an open task, and it
        // rides the avatar badge and the Review row instead, so the two meanings
        // can never be read off the same number.
        listenable: store.todoList,
        builder: (context, _) => _Drawer(
          version: store.serverVersion,
          host: _hostLabel(store),
          index: index,
          pending: store.openTodos,
          pendingPrompts: store.pendingPromptCount,
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
          onPushTodos: () => _pushAndClose(
            () => const TodosPage(),
            S.drawerNavTodos,
            _todosActions(store),
          ),
          onPushCommands: () =>
              _pushAndClose(() => const CommandsPage(), S.navCommands),
          onOpenSession: (s) {
            Navigator.pop(ctx);
            store.openSession(s.id);
          },
          // Close the drawer, then open the sheet. The request stays pending on
          // the server either way, so nothing is lost by leaving the drawer.
          onReviewPrompt: () {
            Navigator.pop(ctx);
            showPendingPrompt(context);
          },
        ),
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
        pending: store.pendingPromptCount,
        onClose: () => Navigator.pop(ctx),
        onOpen: (page, title) => _pushAndClose(page, title),
        onServer: () => _pushAndClose(() => const SettingsPage(), S.menuSwitchServer),
        // Dismissing the menu only closes the menu. The prompt is still
        // pending, so it is still on the server and the badge is still up —
        // that is the whole point of rebuilding from GET /permission.
        onReview: () {
          Navigator.pop(ctx);
          showPendingPrompt(context);
        },
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
  void _openSessionScreen(
    BuildContext context,
    String title,
    Widget page, [
    List<Widget> actions = const [],
  ]) {
    final store = AppScope.read(context);
    pushScreen(
      context,
      title: title,
      // No session means no screen of its own below, so its actions would be
      // left pointing at nothing.
      actions: store.current == null ? const [] : actions,
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
