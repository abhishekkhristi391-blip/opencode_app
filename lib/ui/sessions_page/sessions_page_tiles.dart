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
    // One group per sticky header, each group's rows in its own builder sliver:
    // headers stay pinned while the tiles below them are built lazily, so a long
    // history no longer constructs every row up front.
    final groups = <_SessionGroup>[];
    String? group;
    var index = 0;
    for (final s in list) {
      final g = _bucket(s.updated);
      if (g != group) {
        group = g;
        groups.add(_SessionGroup(g));
      }
      groups.last.sessions.add(_IndexedSession(s, index++));
    }

    return CustomScrollView(
      // Pull-to-refresh needs an always-scrollable physics, same as before.
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        for (final g in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _GroupHeaderDelegate(g.label),
          ),
          SliverList.builder(
            itemCount: g.sessions.length,
            itemBuilder: (_, i) {
              final e = g.sessions[i];
              return _GuardedSessionTile(
                key: ValueKey('sess:${e.index}:${e.s.id}'),
                s: e.s,
                index: e.index,
              );
            },
          ),
        ],
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

/// A bucket ("Today" / "Yesterday" / "Earlier") and the sessions in it.
class _SessionGroup {
  final String label;
  final List<_IndexedSession> sessions = [];
  _SessionGroup(this.label);
}

/// A session plus its position in the *whole* list, so row keys stay unique even
/// when two cache-restored sessions share an id across group boundaries.
class _IndexedSession {
  final Session s;
  final int index;
  _IndexedSession(this.s, this.index);
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
