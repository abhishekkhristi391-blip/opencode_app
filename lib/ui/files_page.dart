import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import 'widgets.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final pathC = TextEditingController();
  String dir = '.';
  List<FileNode> nodes = [];
  int modifiedCount = 0;
  bool loading = true;
  String? err;
  bool showIgnored = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    pathC.dispose();
    super.dispose();
  }

  Future<void> _load([String? d]) async {
    setState(() {
      loading = true;
      err = null;
      if (d != null) {
        dir = d;
        pathC.text = d;
      }
    });
    final store = AppScope.read(context);
    try {
      final list = await store.api.files(dir);
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      int changed = 0;
      try {
        changed = (await store.api.fileStatus()).length;
      } catch (_) {/* tracked-status is optional */}
      if (!mounted) return;
      setState(() {
        nodes = showIgnored ? list : list.where((n) => !n.ignored).toList();
        modifiedCount = changed;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        err = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final crumbs = dir == '.' ? <String>['.'] : ('.$dir').split('/').where((e) => e.isNotEmpty).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pathC,
                  onSubmitted: _load,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'path (project root se relative)',
                    prefixIcon: const Icon(Icons.folder_outlined, size: 18),
                    suffixIcon: IconButton(
                        iconSize: 18, icon: const Icon(Icons.arrow_forward), onPressed: () => _load(pathC.text)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () => _load(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (var i = 0; i < crumbs.length; i++) ...[
                if (i > 0) Icon(Icons.chevron_right, size: 15, color: cs.outline),
                InkWell(
                  onTap: () {
                    final p = i == 0 ? '.' : './${crumbs.sublist(1, i + 1).join('/')}';
                    _load(p);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: Text(i == 0 ? 'root' : crumbs[i],
                        style: TextStyle(
                            fontSize: 12, color: i == crumbs.length - 1 ? cs.primary : cs.onSurface)),
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                dense: true,
                value: showIgnored,
                onChanged: (v) {
                  setState(() => showIgnored = v);
                  _load();
                },
                title: const Text('Ignored files dikhao', style: TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (modifiedCount > 0)
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangedFilesPage())),
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text('$modifiedCount changed', style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: loading
              ? const LoadingView()
              : err != null
                  ? EmptyHint(icon: Icons.error_outline, title: 'Load nahi hua', message: err!)
                  : nodes.isEmpty
                      ? const EmptyHint(icon: Icons.folder_off_outlined, title: 'Khaali folder', message: 'Yahan koi file nahi.')
                      : ListView.builder(
                          itemCount: nodes.length,
                          itemBuilder: (_, i) => _FileTile(
                            node: nodes[i],
                            onOpen: () => _open(nodes[i]),
                            onMenu: () => _menu(nodes[i]),
                          ),
                        ),
        ),
      ],
    );
  }

  Future<void> _open(FileNode n) async {
    if (n.isDir) return _load(n.path);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => FileEditorPage(path: n.path)));
  }

  Future<void> _menu(FileNode n) async {
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
              title: const Text('Rename'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final v = await promptText(context, title: 'Rename', initial: n.name);
                if (v == null || v.trim().isEmpty) return;
                final parent = dirName(n.path);
                final target = parent == '.' ? v.trim() : '$parent/${v.trim()}';
                try {
                  await store.runShell('mv ${_q(n.path)} ${_q(target)}');
                  _load();
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                try {
                  await store.runShell('cp -r ${_q(n.path)} ${_q('${n.path}.copy')}');
                  _load();
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
            if (n.isDir)
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Naya folder yahan'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final v = await promptText(context, title: 'Folder ka naam');
                  if (v == null || v.trim().isEmpty) return;
                  await store.mkdirEntry('${n.path}/${v.trim()}');
                  _load();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Chat me bhejo'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await store.send('@${n.path} is file ko review karo');
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await confirmDialog(context,
                    title: 'Delete karein?',
                    message: '${n.path} permanently delete ho jayegi.',
                    confirm: 'Delete',
                    danger: true);
                if (!ok) return;
                await store.deleteEntry(n.path);
                _load();
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  static String _q(String s) => "'${s.replaceAll("'", "'\\''")}'";
}

class ChangedFilesPage extends StatelessWidget {
  const ChangedFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Changed files')),
      body: FutureBuilder<List<FileNode>>(
        future: store.api.fileStatus(),
        builder: (_, snap) {
          if (!snap.hasData) return const LoadingView();
          final list = snap.data!;
          if (list.isEmpty) {
            return const EmptyHint(
                icon: Icons.check_circle_outline, title: 'Sab clean', message: 'Koi tracked file change nahi hai.');
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              dense: true,
              leading: const Icon(Icons.insert_drive_file_outlined, size: 19),
              title: Text(list[i].path, style: const TextStyle(fontSize: 12.5, fontFamily: 'monospace')),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FileEditorPage(path: list[i].path))),
            ),
          );
        },
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final FileNode node;
  final VoidCallback onOpen;
  final VoidCallback onMenu;
  const _FileTile({required this.node, required this.onOpen, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
        node.isDir ? Icons.folder_outlined : _icon(node.name),
        size: 20,
        color: node.isDir ? cs.primary : (node.ignored ? cs.outlineVariant : null),
      ),
      title: Text(node.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13.5, color: node.ignored ? cs.outline : null)),
      trailing: IconButton(
        iconSize: 18,
        icon: const Icon(Icons.more_vert),
        onPressed: onMenu,
      ),
      onTap: onOpen,
    );
  }

  static IconData _icon(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => Icons.code,
      'js' || 'mjs' || 'cjs' => Icons.javascript,
      'ts' || 'tsx' => Icons.code,
      'py' => Icons.code,
      'json' => Icons.data_object,
      'md' => Icons.article_outlined,
      'yaml' || 'yml' => Icons.settings_input_component,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'svg' => Icons.image_outlined,
      'sh' || 'bash' => Icons.terminal,
      'html' || 'css' => Icons.web,
      'lock' => Icons.lock_outline,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}

// ---------------------------------------------------------------------
// editor
// ---------------------------------------------------------------------

class FileEditorPage extends StatefulWidget {
  final String path;
  const FileEditorPage({super.key, required this.path});

  @override
  State<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends State<FileEditorPage> {
  final c = TextEditingController();
  String original = '';
  bool loading = true;
  bool saving = false;
  bool binary = false;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  bool get dirty => c.text != original;

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final text = await AppScope.read(context).api.readFile(widget.path);
      if (!mounted) return;
      setState(() {
        c.text = text;
        original = text;
        // A NUL byte is a reliable "not text" marker for our purposes.
        binary = text.contains('\u0000');
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        err = '$e';
        loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await AppScope.read(context).writeFile(widget.path, c.text);
      if (!mounted) return;
      setState(() {
        original = c.text;
        saving = false;
      });
      showSnack(context, 'Saved');
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      showSnack(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmDialog(context,
            title: 'Changes save nahi kiye',
            message: 'Aap bhool gaye. Exit karein?',
            confirm: 'Exit');
        if (leave && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(baseName(widget.path), style: const TextStyle(fontSize: 15)),
              Text(widget.path,
                  style: TextStyle(fontSize: 10.5, color: cs.outline), overflow: TextOverflow.ellipsis),
            ],
          ),
          actions: [
            if (dirty)
              Center(child: Text('edited', style: TextStyle(fontSize: 10.5, color: cs.tertiary))),
            IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save',
                onPressed: saving || !dirty ? null : _save),
            IconButton(icon: const Icon(Icons.copy_all_outlined), onPressed: () => copyToClipboard(context, c.text)),
          ],
        ),
        body: loading
            ? const LoadingView()
            : err != null
                ? EmptyHint(icon: Icons.error_outline, title: 'Padha nahi ja saka', message: err!)
                : binary
                    ? const EmptyHint(
                        icon: Icons.memory, title: 'Binary file', message: 'Ye text file nahi hai, edit nahi ho sakti.')
                    : Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: c,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontFamilyFallback: ['monospace'],
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                              decoration: const InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              border: Border(top: BorderSide(color: cs.outlineVariant)),
                            ),
                            child: Row(
                              children: [
                                Text('${c.text.split('\n').length} lines · ${c.text.length} chars',
                                    style: TextStyle(fontSize: 11, color: cs.outline)),
                                const Spacer(),
                                if (dirty)
                                  TextButton(
                                    onPressed: _save,
                                    child: Text(saving ? 'Saving…' : 'Save'),
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
