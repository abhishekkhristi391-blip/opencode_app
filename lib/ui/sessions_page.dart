import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'chat.dart';
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
      child: Column(
        children: [
          const _SessionsHeader(),
          const _SessionsList(),
        ],
      ),
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
        final all = store.sessions.where((s) => s.title != OcStore.utilSessionTitle).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: Text('${all.length} sessions',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
              ),
            ],
          ),
        );
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
        final all = store.sessions.where((s) => s.title != OcStore.utilSessionTitle).toList();
        final list = parentsOnly ? all.where((s) => !s.isChild).toList() : all;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: SegmentedButton<bool>(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: true, label: Text('Main'), icon: Icon(Icons.account_tree_outlined, size: 15)),
                  ButtonSegment(value: false, label: Text('Sab'), icon: Icon(Icons.list, size: 15)),
                ],
                selected: {parentsOnly},
                onSelectionChanged: (s) => setState(() => parentsOnly = s.first),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? EmptyHint(
                      icon: Icons.history,
                      title: 'Koi session nahi',
                      message: 'Naya chat start karo.',
                      action: FilledButton.icon(
                        onPressed: () async {
                          await store.newSession();
                          if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New chat'),
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
    final cs = Theme.of(context).colorScheme;
    final active = store.current?.id == s.id;

    return Dismissible(
      key: ValueKey(s.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        final ok = await confirmDialog(context,
            title: 'Session delete karein?',
            message: '"${s.label}" aur uski saari history permanently delete ho jayegi.',
            confirm: 'Delete',
            danger: true);
        if (ok) await store.deleteSession(s.id);
        return ok;
      },
      child: ListTile(
        selected: active,
        selectedTileColor: cs.primaryContainer.withValues(alpha: 0.35),
        leading: Icon(active ? Icons.forum : Icons.forum_outlined,
            color: active ? cs.primary : cs.outline),
        title: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        subtitle: Row(
          children: [
            Text(fmtAge(s.updated), style: TextStyle(fontSize: 11, color: cs.outline)),
            if (s.cost > 0) ...[
              Text(' · \$${s.cost.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
            if (s.summary.files > 0) ...[
              Text(' · ${s.summary.files}f', style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
            if (s.isChild) ...[
              Text(' · child', style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
            if (s.isShared) ...[
              const SizedBox(width: 6),
              Icon(Icons.public, size: 12, color: cs.primary),
            ],
          ],
        ),
        trailing: store.busy && active
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
        onTap: () async {
          await store.openSession(s.id);
          if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
        },
        onLongPress: () => _showActions(context),
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
                final n = await promptText(context, title: 'Naam badlo', initial: s.label);
                if (n != null && n.trim().isNotEmpty) await store.renameSession(s.id, n.trim());
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
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await confirmDialog(context,
                    title: 'Session delete karein?',
                    message: '"${s.label}" permanently delete ho jayegi.',
                    confirm: 'Delete',
                    danger: true);
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
            ? const EmptyHint(icon: Icons.account_tree_outlined, title: 'Koi child nahi', message: 'Is session me koi subagent session nahi bana.')
            : ListView.builder(
                itemCount: kids.length,
                itemBuilder: (_, i) {
                  final k = kids[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.subdirectory_arrow_right),
                    title: Text(k.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(fmtAge(k.updated), style: const TextStyle(fontSize: 11)),
                    onTap: () async {
                      Navigator.pop(context);
                      await store.openSession(k.id);
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
