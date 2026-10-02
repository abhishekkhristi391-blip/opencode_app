import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'chat.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: AppScope.read(context).refreshSessions,
      child: Column(children: [const _SessionsHeader(), const _SessionsList()]),
    );
  }
}

class _SessionsHeader extends StatelessWidget {
  const _SessionsHeader();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        final all = store.sessions
            .where((s) => s.title != OcStore.utilSessionTitle)
            .toList();
        return SectionTitle('${all.length} sessions');
      },
    );
  }
}

class _SessionsList extends StatefulWidget {
  const _SessionsList();

  @override
  State<_SessionsList> createState() => _SessionsListState();
}

class _SessionsListState extends State<_SessionsList> {
  bool parentsOnly = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        final all = store.sessions
            .where((s) => s.title != OcStore.utilSessionTitle)
            .toList();
        final list = parentsOnly ? all.where((s) => !s.isChild).toList() : all;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.lg,
                OCSpace.sm,
                OCSpace.lg,
                OCSpace.md,
              ),
              child: OCSegmentedControl<bool>(
                segments: const [
                  OCSegment(true, 'Main', icon: Icons.account_tree_outlined),
                  OCSegment(false, 'Sab', icon: Icons.list),
                ],
                value: parentsOnly,
                onChanged: (v) => setState(() => parentsOnly = v),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? EmptyHint(
                      icon: Icons.history,
                      title: 'Koi session nahi',
                      message: 'Naya chat start karo.',
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
                        label: 'New chat',
                        variant: OCButtonVariant.primaryBlack,
                        expand: false,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _SessionTile(s: list[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session s;
  const _SessionTile({required this.s});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.read(context);
    final active = store.current?.id == s.id;

    return Dismissible(
      key: ValueKey(s.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: OCSpace.xl),
        color: OCColors.redTint,
        child: const Icon(Icons.delete_outline, color: OCColors.redInk),
      ),
      confirmDismiss: (_) async {
        final ok = await confirmDialog(
          context,
          title: 'Session delete karein?',
          message:
              '"${s.label}" aur uski saari history permanently delete ho jayegi.',
          confirm: 'Delete',
          danger: true,
        );
        if (ok) await store.deleteSession(s.id);
        return ok;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: OCSpace.lg,
          vertical: OCSpace.xxs,
        ),
        decoration: BoxDecoration(
          color: active ? OCColors.orangeTint : OCColors.surface,
          borderRadius: BorderRadius.circular(OCRadius.inner),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OCRadius.inner),
          ),
          selected: active,
          selectedTileColor: Colors.transparent,
          leading: OCIconTile(
            icon: active ? Icons.forum : Icons.forum_outlined,
            accent: active ? OCAccent.orange : OCAccent.neutral,
            size: 32,
            iconSize: 17,
          ),
          title: Text(
            s.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: OCTypography.body,
          ),
          subtitle: Row(
            children: [
              Text(fmtAge(s.updated), style: OCTypography.micro),
              if (s.cost > 0) ...[
                Text(
                  ' · \$${s.cost.toStringAsFixed(2)}',
                  style: OCTypography.micro,
                ),
              ],
              if (s.summary.files > 0) ...[
                Text(' · ${s.summary.files}f', style: OCTypography.micro),
              ],
              if (s.isChild) ...[Text(' · child', style: OCTypography.micro)],
              if (s.isShared) ...[
                const SizedBox(width: OCSpace.sm),
                const Icon(Icons.public, size: 12, color: OCColors.orange),
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
              title: const Text('Naam badlo'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final n = await promptText(
                  context,
                  title: 'Naam badlo',
                  initial: s.label,
                );
                if (n != null && n.trim().isNotEmpty)
                  await store.renameSession(s.id, n.trim());
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: const Text('Fork banao'),
              subtitle: const Text('Naya session, same history'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final f = await store.forkSession(s.id);
                if (f != null && context.mounted) {
                  await store.openSession(f.id);
                  if (context.mounted) showSnack(context, 'Fork: ${f.label}');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: const Text('Child sessions dekho'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _showChildren(context);
              },
            ),
            if (s.isShared)
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('Share hatao'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  store.unshareSession(s.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Share link banao'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  store.shareSession(s.id);
                },
              ),
            if (s.shareUrl.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Share link copy karo'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  copyToClipboard(context, s.shareUrl, 'Link copy ho gaya');
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: OCColors.red),
              title: const Text(
                'Delete',
                style: TextStyle(color: OCColors.red),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await confirmDialog(
                  context,
                  title: 'Session delete karein?',
                  message: '"${s.label}" permanently delete ho jayegi.',
                  confirm: 'Delete',
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
                title: 'Koi child nahi',
                message: 'Is session me koi subagent session nahi bana.',
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
