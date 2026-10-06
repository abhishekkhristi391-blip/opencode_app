part of '../sessions_page.dart';

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
        showUndoSnack(context, S.historyDeleted, () {
          // Re-creating is not possible against a deleted id, so undo offers
          // the next best thing: bring it back into view as a new session
          // carrying the old title. Nothing is silently lost either way.
          store.newSession(title: removed.label);
        });
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
            // A visible overflow button, because rename/delete/pin were only reachable
            // through a long-press that nothing on screen advertised.
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (store.busy && active)
                  const OCProgressRing(value: 0.7, size: 18, stroke: 2.5),
                IconButton(
                  onPressed: () => _showActions(context),
                  icon: const Icon(Icons.more_vert),
                  tooltip: S.sessionsActions,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
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
    final isPinned = store.pinned.contains(s.id);
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
              leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(isPinned ? S.sessionsUnpin : S.sessionsPin),
              subtitle: const Text(S.sessionsPinnedHint),
              onTap: () {
                Navigator.pop(sheetCtx);
                store.togglePin(s.id);
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
