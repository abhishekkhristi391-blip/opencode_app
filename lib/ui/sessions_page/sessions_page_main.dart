part of '../sessions_page.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => SessionsPageState();
}

class SessionsPageState extends State<SessionsPage> {
  /// Single source of truth for the Main/All filter so the header count and
  /// the list can never disagree.
  final filter = ValueNotifier<bool>(true);

  /// Search state lives here, not in the list, because the header's action
  /// button focuses the field from outside the subtree.
  final query = ValueNotifier<String>('');
  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();

  /// Called by the shell's header action.
  void focusSearch() => searchFocus.requestFocus();

  void clearSearch() {
    searchCtrl.clear();
    query.value = '';
    searchFocus.unfocus();
  }

  @override
  void dispose() {
    filter.dispose();
    query.dispose();
    searchCtrl.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SessionsHeader(
          filter: filter,
          query: query,
          searchCtrl: searchCtrl,
          searchFocus: searchFocus,
        ),
        // Expanded is load-bearing, not cosmetic. Without it [_SessionsList] is
        // a non-flex child of this Column, and a Column hands non-flex children
        // unbounded main-axis constraints. The Column inside [_SessionsList]
        // then has an `Expanded` ListView under an unbounded height, which
        // throws during layout — so the header painted its count while the
        // list painted nothing at all.
        Expanded(
          child: _SessionsList(filter: filter, query: query),
        ),
      ],
    );
  }
}

class _SessionsHeader extends StatelessWidget {
  final ValueListenable<bool> filter;
  final ValueNotifier<String> query;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;

  const _SessionsHeader({
    required this.filter,
    required this.query,
    required this.searchCtrl,
    required this.searchFocus,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OCSpace.screenX,
        OCSpace.xs,
        OCSpace.screenX,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search. There was none, so a long history was only browsable by
          // scrolling.
          SizedBox(
            height: 40,
            child: TextField(
              controller: searchCtrl,
              focusNode: searchFocus,
              style: OCTypography.body.copyWith(color: t.ink),
              cursorColor: t.acc,
              textInputAction: TextInputAction.search,
              onChanged: (v) => query.value = v.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: S.historySearchHint,
                hintStyle: OCTypography.body.copyWith(color: t.mute),
                prefixIcon: Icon(Icons.search, size: 18, color: t.mute),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close, size: 16, color: t.mute),
                        tooltip: S.clear,
                        onPressed: () {
                          searchCtrl.clear();
                          query.value = '';
                          searchFocus.unfocus();
                        },
                      ),
                filled: true,
                fillColor: t.surfaceElevated,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.md,
                  vertical: OCSpace.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.pill),
                  borderSide: BorderSide(color: t.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.pill),
                  borderSide: BorderSide(color: t.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.pill),
                  borderSide: BorderSide(color: t.acc),
                ),
              ),
            ),
          ),
          const SizedBox(height: OCSpace.sm),
          ListenableBuilder(
            listenable: Listenable.merge([AppScope.of(context), filter, query]),
            builder: (context, _) {
              // Counts exactly what the list below is about to show, search
              // included. It used to ignore the query, so "3 results" could sit
              // above an empty list.
              final list = visibleSessions(
                context,
                filter.value,
                query: query.value,
              );
              return SectionTitle(
                list.length == 1
                    ? S.sessionsCountOne(list.length)
                    : S.sessionsCount(list.length),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The one filter used by both the header count and the list.
List<Session> visibleSessions(
  BuildContext context,
  bool parentsOnly, {
  String query = '',
}) {
  final store = AppScope.of(context);
  final all = store.sessions
      .where((s) => s.title != OcStore.utilSessionTitle)
      .toList();
  final base = parentsOnly ? all.where((s) => !s.isChild).toList() : all;
  if (query.isEmpty) return base;
  return base
      .where(
        (s) =>
            s.label.toLowerCase().contains(query) ||
            (s.agent.toLowerCase().contains(query)) ||
            (s.modelId.toLowerCase().contains(query)),
      )
      .toList();
}

class _SessionsList extends StatefulWidget {
  final ValueListenable<bool> filter;
  final ValueNotifier<String> query;
  const _SessionsList({required this.filter, required this.query});

  @override
  State<_SessionsList> createState() => _SessionsListState();
}

class _SessionsListState extends State<_SessionsList> {
  ValueNotifier<bool> get filter => widget.filter as ValueNotifier<bool>;
  ValueNotifier<String> get query => widget.query as ValueNotifier<String>;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppScope.of(context), filter, query]),
      builder: (context, _) {
        final store = AppScope.of(context);
        final parentsOnly = filter.value;
        final list = visibleSessions(context, parentsOnly, query: query.value);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.xs,
                OCSpace.screenX,
                OCSpace.md,
              ),
              child: OCSegmentedControl<bool>(
                segments: const [
                  OCSegment(true, S.sessionsFilterMain, icon: Icons.list),
                  OCSegment(
                    false,
                    S.sessionsFilterAll,
                    icon: Icons.account_tree_outlined,
                  ),
                ],
                value: filter.value,
                onChanged: (v) => filter.value = v,
              ),
            ),
            Expanded(
              // 1. loading skeleton, 2. error, 3. filtered-empty, 4. list.
              // The error only takes over when there is nothing cached to
              // browse — otherwise a dead server would hide local history.
              // The indicator wraps the scrollable itself: sitting on the page
              // around a bare Column it could never fire, because a Column
              // emits no scroll notifications.
              child: RefreshIndicator(
                onRefresh: store.refreshSessions,
                child: store.sessionsLoading
                    ? const OCSkeletonList(semanticLabel: S.sessionsLoading)
                    : store.sessionsError != null && list.isEmpty
                    ? EmptyHint(
                        icon: Icons.error_outline,
                        title: S.sessionsErrorTitle,
                        message: store.sessionsError!,
                        action: OCButton(
                          onPressed: store.refreshSessions,
                          icon: Icons.refresh,
                          label: S.retry,
                          variant: OCButtonVariant.primaryBlack,
                          expand: false,
                        ),
                      )
                    : list.isEmpty
                    ? EmptyHint(
                        icon: Icons.history,
                        title: parentsOnly && store.sessions.isNotEmpty
                            ? S.sessionsFilteredEmptyTitle
                            : S.sessionsEmptyTitle,
                        message: parentsOnly && store.sessions.isNotEmpty
                            ? S.sessionsFilteredEmptyBody
                            : S.sessionsEmptyBody,
                        action: OCButton(
                          onPressed: () async {
                            await store.newSession();
                            if (context.mounted)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChatPage(),
                                ),
                              );
                          },
                          icon: Icons.add,
                          label: S.newChat,
                          variant: OCButtonVariant.primaryBlack,
                          expand: false,
                        ),
                      )
                    : _GroupedSessionList(list: list),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Refcount for [_pushTileErrorGuard]. Rows mount lazily and unmount while
/// scrolling, so a plain save/restore would restore a stale builder as soon as
/// one row scrolled away.
int _tileGuards = 0;

ErrorWidgetBuilder? _tileGuardPrev;

void _pushTileErrorGuard() {
  if (_tileGuards++ > 0) return;
  _tileGuardPrev = ErrorWidget.builder;
  ErrorWidget.builder = (details) {
    debugPrint(
      'session row failed to build: ${details.exception}\n'
      '${details.stack ?? '<no stack>'}',
    );
    return const _BrokenSessionRow();
  };
}

void _popTileErrorGuard() {
  if (--_tileGuards > 0) return;
  _tileGuards = 0;
  final prev = _tileGuardPrev;
  _tileGuardPrev = null;
  if (prev != null) ErrorWidget.builder = prev;
}

/// Wraps one history row so a single malformed session cannot take the list
/// with it.
///
/// Flutter replaces anything whose build throws with an [ErrorWidget] — an
/// empty grey box — so a throw inside the viewport left the page showing the
/// header count and nothing under it, with no way to tell which row was at
/// fault. There is no way to `try/catch` a build from the parent (the child's
/// `build` runs a frame later), so the guard replaces [ErrorWidget.builder]
/// while this row is mounted, logs the real exception, and paints a visible
/// placeholder instead.
class _GuardedSessionTile extends StatefulWidget {
  final Session s;
  final int index;
  const _GuardedSessionTile({required this.s, required this.index});

  @override
  State<_GuardedSessionTile> createState() => _GuardedSessionTileState();
}

class _GuardedSessionTileState extends State<_GuardedSessionTile> {
  @override
  void initState() {
    super.initState();
    _pushTileErrorGuard();
  }

  @override
  void dispose() {
    _popTileErrorGuard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The row id alone is not a safe key: two sessions restored from the same
    // cache page can share it, and `Dismissible` asserts on duplicate keys,
    // which blanks the whole viewport. Index + id is always unique and stays
    // stable while the list is only reordered by `updated`.
    return _SessionTile(
      rowKey: 'sess:${widget.index}:${widget.s.id}',
      s: widget.s,
    );
  }
}

/// Stand-in painted when a row's build throws, so the list keeps its rhythm
/// and the rest of the sessions stay tappable.
class _BrokenSessionRow extends StatelessWidget {
  const _BrokenSessionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.tapGap / 2,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: OCSpace.tapTarget),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
        decoration: BoxDecoration(
          color: OCColors.redTint,
          borderRadius: BorderRadius.circular(OCRadius.inner),
        ),
        child: Text(
          'row failed to render',
          style: OCTypography.micro.copyWith(color: OCColors.redInk),
        ),
      ),
    );
  }
}
