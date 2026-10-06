part of '../files_page.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => FilesPageState();
}

class FilesPageState extends State<FilesPage> {
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

  /// Called by the shell header's refresh button.
  void reload() => _load();

  /// Called by the shell header's new-file button: opens the same menu the
  /// in-page button does, so there is one behaviour, not two copies.
  void promptCreate() => _createMenu();

  @override
  void dispose() {
    pathC.dispose();
    super.dispose();
  }

  /// Normalises a user-typed directory into what the file API expects: the
  /// project root is `.`, a `./` prefix is dropped, and an empty field never
  /// reaches the API as `''` (which used to break loading outright).
  static String _normDir(String? p) {
    var s = (p ?? '').trim();
    while (s.startsWith('./')) {
      s = s.substring(2);
    }
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.isEmpty || s == '.') return '.';
    return s;
  }

  /// A name is usable only if it stays inside the current folder.
  static bool _validName(String n) {
    final s = n.trim();
    return s.isNotEmpty &&
        s != '.' &&
        s != '..' &&
        !s.contains('/') &&
        !s.contains('\\') &&
        !s.contains('\u0000');
  }

  /// "+" menu: create a file or a folder in the directory on screen.
  Future<void> _createMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text(S.filesNewFileItem),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _newFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text(S.filesNewFolderItem),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _newFolder();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newFile() async {
    final name = await promptText(context, title: S.filesNameLabel(false));
    if (name == null || !mounted) return;
    if (!_validName(name)) {
      showSnack(context, S.filesBadName, error: true);
      return;
    }
    final path = dir == '.' ? name : '$dir/$name';
    final exists = nodes.any((n) => n.name == name.trim());
    if (exists) {
      showSnack(context, S.filesExists(name), error: true);
      return;
    }
    try {
      await AppScope.read(context).writeFile(path, '');
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      FileNode? made;
      for (final n in nodes) {
        if (n.name == name.trim()) {
          made = n;
          break;
        }
      }
      if (made != null) _open(made);
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  Future<void> _newFolder() async {
    final name = await promptText(context, title: S.filesNameLabel(true));
    if (name == null || !mounted) return;
    if (!_validName(name)) {
      showSnack(context, S.filesBadName, error: true);
      return;
    }
    final path = dir == '.' ? name.trim() : '$dir/${name.trim()}';
    try {
      await AppScope.read(context).mkdirEntry(path);
      await _load();
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  Future<void> _load([String? d]) async {
    setState(() {
      loading = true;
      err = null;
      if (d != null) {
        dir = _normDir(d);
        pathC.text = dir;
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
      } catch (e) {
        debugPrint('File status check failed: $e');
      }
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
    final t = context.oc;
    // Built from the normalised dir so absolute paths and plain relative ones
    // both produce correct segments (the old `('.$dir')` blindly prefixed a
    // `.` onto every path, including `/storage/...`).
    final d = _normDir(dir);
    final absolute = d.startsWith('/');
    final segs = d.split('/').where((e) => e.isNotEmpty).toList();
    final crumbs = absolute
        ? <String>['/', ...segs]
        : (segs.isEmpty ? <String>['.'] : segs);
    String crumbPath(int i) {
      if (absolute)
        return i == 0 ? '/' : '/${crumbs.sublist(1, i + 1).join('/')}';
      return i == 0 ? '.' : crumbs.sublist(0, i + 1).join('/');
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.screenX,
            OCSpace.md,
            OCSpace.screenX,
            OCSpace.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pathC,
                  onSubmitted: _load,
                  style: OCTypography.mono(size: 12.5, color: t.ink),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: S.filesPathHint,
                    hintStyle: OCTypography.mono(color: t.mute, size: 12.5),
                    filled: true,
                    fillColor: t.surfaceElevated,
                    prefixIcon: Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: t.mute,
                    ),
                    suffixIcon: IconButton(
                      tooltip: S.filesGo,
                      iconSize: 18,
                      color: t.mute,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _load(pathC.text),
                    ),
                    border: _pillBorder(t.acc),
                    enabledBorder: _pillBorder(t.acc),
                    focusedBorder: _pillBorder(t.acc, focused: true),
                  ),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              IconButton(
                tooltip: S.filesNewTitle,
                color: t.mute,
                icon: const Icon(Icons.add),
                onPressed: _createMenu,
              ),
              IconButton(
                tooltip: S.refresh,
                color: t.mute,
                icon: const Icon(Icons.refresh),
                onPressed: () => _load(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: OCSpace.tapTarget,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
            children: [
              for (var i = 0; i < crumbs.length; i++) ...[
                if (i > 0) Icon(Icons.chevron_right, size: 15, color: t.faint),
                InkWell(
                  borderRadius: BorderRadius.circular(OCRadius.sm),
                  onTap: () => _load(crumbPath(i)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OCSpace.sm,
                      vertical: OCSpace.sm,
                    ),
                    child: Text(
                      i == 0 ? (absolute ? '/' : S.filesRootCrumb) : crumbs[i],
                      style: OCTypography.caption.copyWith(
                        color: i == crumbs.length - 1 ? t.acc : t.ink,
                        fontWeight: i == crumbs.length - 1
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
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
                title: Text(
                  S.filesShowIgnored,
                  style: OCTypography.caption.copyWith(color: t.ink),
                ),
                activeThumbColor: t.acc,
                activeTrackColor: t.acc,
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (modifiedCount > 0)
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangedFilesPage()),
                ),
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(
                  S.filesChangedCount(modifiedCount),
                  style: OCTypography.caption.copyWith(color: t.ink),
                ),
              ),
          ],
        ),
        Divider(height: 1, color: t.line),
        Expanded(
          child: loading
              ? const LoadingView()
              : err != null
              ? EmptyHint(
                  icon: Icons.error_outline,
                  title: S.filesLoadFailed,
                  message: err!,
                )
              : nodes.isEmpty
              ? EmptyHint(
                  icon: Icons.folder_off_outlined,
                  title: S.filesEmptyName(true),
                  message: S.filesEmptyHere,
                )
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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FileEditorPage(path: n.path)),
    );
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
              title: const Text(S.rename),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final v = await promptText(
                  context,
                  title: S.rename,
                  initial: n.name,
                );
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
              title: const Text(S.filesDuplicate),
              onTap: () async {
                Navigator.pop(sheetCtx);
                try {
                  await store.runShell(
                    'cp -r ${_q(n.path)} ${_q('${n.path}.copy')}',
                  );
                  _load();
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
            if (n.isDir)
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text(S.filesFolderExists),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final v = await promptText(
                    context,
                    title: S.filesNameLabel(true),
                  );
                  if (v == null || v.trim().isEmpty) return;
                  try {
                    await store.mkdirEntry('${n.path}/${v.trim()}');
                    _load();
                  } catch (e) {
                    if (mounted) showSnack(context, '$e', error: true);
                  }
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text(S.filesSendToChat),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await store.send('@${n.path} review this file');
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.oc.err),
              title: Text(
                S.deleteFile,
                style: TextStyle(color: context.oc.err),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final ok = await confirmDialog(
                  context,
                  title: S.filesDeleteTitle,
                  message: S.filesDeleteBody(n.path),
                  confirm: S.deleteFile,
                  danger: true,
                );
                if (!ok) return;
                try {
                  await store.deleteEntry(n.path);
                  _load();
                } catch (e) {
                  if (mounted) showSnack(context, '$e', error: true);
                }
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
