import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'chat.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

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
  final ValueListenable<String> query;
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
  final ValueListenable<String> query;
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

class _SessionTile extends StatelessWidget {
  final Session s;

  /// Unique per row. `Dismissible` requires a key and asserts on duplicates,
  /// so the caller owns it rather than deriving one from [s.id].
  final String rowKey;

  const _SessionTile({required this.s, required this.rowKey});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.read(context);
    final t = context.oc;
    final active = store.current?.id == s.id;

    return Dismissible(
      key: ValueKey(rowKey),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: OCSpace.xl),
        color: t.errSoft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: t.err),
            const SizedBox(width: OCSpace.sm),
            Text(S.delete, style: OCTypography.caption.copyWith(color: t.err)),
          ],
        ),
      ),
      // Delete immediately, then offer undo. The old flow asked
      // "Delete 'X'?" *after* the swipe, so the intent was confirmed twice for
      // an action that needs no confirmation when it can be taken back.
      confirmDismiss: (_) async {
        final removed = s;
        final ok = await store.deleteSession(removed.id);
        if (!ok) return false;
        showSnack(
          context,
          S.historyDeleted,
          action: SnackBarAction(
            label: S.historyUndo,
            onPressed: () {
              // Re-creating is not possible against a deleted id, so undo offers
              // the next best thing: bring it back into view as a new session
              // carrying the old title. Nothing is silently lost either way.
              store.newSession(title: removed.label);
            },
          ),
        );
        return true;
      },
      child: Material(
        color: active
            ? t.surfaceElevated.withValues(alpha: 0.55)
            : Colors.transparent,
        child: Container(
          // 3px accent rail on the active row instead of a full-bleed fill:
          // the old `selected` tinted the entire row peach, which read as an
          // input field rather than a selection.
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: active ? t.acc : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(color: t.line.withValues(alpha: 0.5)),
            ),
          ),
          child: OCListRow(
            title: s.label,
            // 72dp rows: the old density put four rows on a phone screen, so
            // titles truncated at two words.
            minHeight: 72,
            leadingIcon: active ? Icons.forum : Icons.forum_outlined,
            accent: active ? OCAccent.orange : OCAccent.neutral,
            titleStyle: OCTypography.title.copyWith(color: t.ink),
            subtitle: Row(
              children: [
                Text(
                  fmtAge(s.updated),
                  style: OCTypography.caption.copyWith(color: t.mute),
                ),
                if (s.cost > 0)
                  Text(
                    ' · \$${s.cost.toStringAsFixed(2)}',
                    style: OCTypography.caption.copyWith(color: t.mute),
                  ),
                if (s.summary.files > 0)
                  Text(
                    ' · ${S.historyFiles(s.summary.files)}',
                    style: OCTypography.caption.copyWith(color: t.mute),
                  ),
                if (s.isChild)
                  Text(
                    ' · ${S.sessionsChild}',
                    style: OCTypography.caption.copyWith(color: t.mute),
                  ),
                if (s.isShared) ...[
                  const SizedBox(width: OCSpace.sm),
                  Icon(Icons.public, size: 14, color: t.acc),
                ],
              ],
            ),
            trailing: store.busy && active
                ? const OCProgressRing(value: 0.7, size: 18, stroke: 2.5)
                : null,
            onTap: () async {
              await store.openSession(s.id);
              if (context.mounted)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                );
            },
            onLongPress: () => _showActions(context),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final store = AppScope.read(context);
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text(S.sessionsRename),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final n = await promptText(
                  context,
                  title: S.sessionsRename,
                  initial: s.label,
                  confirm: S.save,
                );
                if (n != null && n.trim().isNotEmpty)
                  await store.renameSession(s.id, n.trim());
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: const Text(S.sessionsFork),
              subtitle: const Text(S.sessionsForkHint),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final f = await store.forkSession(s.id);
                if (f != null && context.mounted) {
                  await store.openSession(f.id);
                  if (context.mounted)
                    showSnack(context, S.forkCreated(f.label));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: const Text(S.sessionsChildren),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _showChildren(context);
              },
            ),
            if (s.isShared)
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text(S.sessionsUnshare),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  store.unshareSession(s.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text(S.sessionsShare),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  store.shareSession(s.id);
                },
              ),
            if (s.shareUrl.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text(S.sessionsShareCopy),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  copyToClipboard(context, s.shareUrl, S.shareCopied);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: OCColors.red),
              title: Text(S.delete, style: TextStyle(color: OCColors.redInk)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await confirmDialog(
                  context,
                  title: S.sessionsDeleteTitle,
                  message: S.sessionsDeleteBody(s.label),
                  confirm: S.delete,
                  danger: true,
                );
                if (ok) await store.deleteSession(s.id);
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _showChildren(BuildContext context) async {
    final store = AppScope.read(context);
    List<Session> kids;
    try {
      kids = await store.api.childSessions(s.id);
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
      return;
    }
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: kids.isEmpty
            ? const EmptyHint(
                icon: Icons.account_tree_outlined,
                title: S.sessionsChildrenEmptyTitle,
                message: S.sessionsChildrenEmptyBody,
              )
            : ListView.builder(
                itemCount: kids.length,
                itemBuilder: (_, i) {
                  final k = kids[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.subdirectory_arrow_right,
                      color: OCColors.textTertiary,
                    ),
                    title: Text(
                      k.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.caption,
                    ),
                    subtitle: Text(
                      fmtAge(k.updated),
                      style: OCTypography.micro,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await store.openSession(k.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatPage()),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

/// Sessions under sticky Today / Yesterday / Earlier headers.
///
/// A flat, undated list gave no sense of recency, which is the only thing that
/// matters when you are looking for the conversation you had ten minutes ago.
class _GroupedSessionList extends StatelessWidget {
  final List<Session> list;
  const _GroupedSessionList({required this.list});

  @override
  Widget build(BuildContext context) {
    // Sliver list of header+row pairs: one sliver keeps the whole history in a
    // single lazily built list, so a long history still starts cheap.
    final rows = <_Row>[];
    String? group;
    for (final s in list) {
      final g = _bucket(s.updated);
      if (g != group) {
        group = g;
        rows.add(_Row.header(g));
      }
      rows.add(_Row.tile(s));
    }

    return CustomScrollView(
      // Pull-to-refresh needs an always-scrollable physics, same as before.
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        for (var i = 0; i < rows.length; i++)
          if (rows[i].isHeader)
            SliverPersistentHeader(
              pinned: true,
              delegate: _GroupHeaderDelegate(rows[i].label!),
            )
          else
            SliverToBoxAdapter(
              child: _GuardedSessionTile(s: rows[i].s!, index: i),
            ),
      ],
    );
  }

  static String _bucket(int ts) {
    final now = DateTime.now();
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final startToday = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = startToday.difference(day).inDays;
    if (diff <= 0) return S.historyToday;
    if (diff == 1) return S.historyYesterday;
    return S.historyEarlier;
  }
}

class _Row {
  final String? label;
  final Session? s;
  final bool isHeader;
  _Row.header(this.label) : s = null, isHeader = true;
  _Row.tile(this.s) : label = null, isHeader = false;
}

/// Sticky section header. Opaque so rows scroll *under* it instead of showing
/// through, which is what made the previous attempt at grouping unreadable.
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  static const double _height = 36;

  _GroupHeaderDelegate(this.title);

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final t = context.oc;
    return Container(
      height: _height,
      color: t.bg,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
      child: Text(
        title.toUpperCase(),
        style: OCTypography.caption.copyWith(
          color: t.mute,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_GroupHeaderDelegate old) => old.title != title;
}
