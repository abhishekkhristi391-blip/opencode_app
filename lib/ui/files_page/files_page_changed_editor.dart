part of '../files_page.dart';

/// Takes the colour instead of reading `context`: this is a top-level helper,
/// so it has no BuildContext of its own to hang `context.oc` off.
OutlineInputBorder _pillBorder(Color line, {bool focused = false}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(OCRadius.full),
      borderSide: BorderSide(
        color: focused ? line : line.withValues(alpha: 0.8),
      ),
    );

class ChangedFilesPage extends StatelessWidget {
  const ChangedFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(S.filesChangedTitle)),
      body: FutureBuilder<List<FileNode>>(
        future: store.api.fileStatus(),
        builder: (_, snap) {
          if (!snap.hasData) return const LoadingView();
          final list = snap.data!;
          if (list.isEmpty) {
            return const EmptyHint(
              icon: Icons.check_circle_outline,
              title: S.filesAllClean,
              message: S.filesNoChanges,
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ListTile(
              dense: true,
              leading: const OCIconTile(
                icon: Icons.insert_drive_file_outlined,
                accent: OCAccent.blue,
                size: 30,
                iconSize: 16,
              ),
              title: Text(list[i].path, style: OCTypography.mono(size: 12.5)),
              trailing: Icon(
                Icons.open_in_new,
                size: 16,
                color: context.oc.mute,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FileEditorPage(path: list[i].path),
                ),
              ),
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
  const _FileTile({
    required this.node,
    required this.onOpen,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: OCSpace.md,
        vertical: OCSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: node.isDir ? context.oc.surfaceElevated : context.oc.card,
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OCRadius.inner),
        ),
        leading: OCIconTile(
          icon: node.isDir ? Icons.folder_outlined : _icon(node.name),
          accent: node.isDir ? OCAccent.purple : OCAccent.neutral,
          size: 32,
          iconSize: 17,
        ),
        title: Text(
          node.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: OCTypography.caption.copyWith(
            color: node.ignored ? context.oc.faint : context.oc.ink,
          ),
        ),
        trailing: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.more_vert),
          onPressed: onMenu,
        ),
        onTap: onOpen,
      ),
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
      'png' ||
      'jpg' ||
      'jpeg' ||
      'gif' ||
      'webp' ||
      'svg' => Icons.image_outlined,
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
    // No storage-permission prompt: the write is performed by the server's
    // shell, so this app's own storage grant says nothing about it. A genuine
    // failure comes back as an ApiException from writeFile and is shown below.
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
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmDialog(
          context,
          title: S.filesUnsaved,
          message: S.filesUnsavedExit,
          confirm: S.exitNoSave,
        );
        if (leave && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                baseName(widget.path),
                style: OCTypography.h3.copyWith(fontSize: 15),
              ),
              Text(
                widget.path,
                style: OCTypography.micro,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            if (dirty)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 14, color: context.oc.acc),
                    const SizedBox(width: OCSpace.xs),
                    Text(
                      S.filesEdited,
                      style: OCTypography.micro.copyWith(color: context.oc.acc),
                    ),
                  ],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: S.save,
              onPressed: saving || !dirty ? null : _save,
            ),
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: () => copyToClipboard(context, c.text),
            ),
          ],
        ),
        body: loading
            ? const LoadingView()
            : err != null
            ? EmptyHint(
                icon: Icons.error_outline,
                title: S.filesReadFailed,
                message: err!,
              )
            : binary
            ? const EmptyHint(
                icon: Icons.memory,
                title: S.filesBinary,
                message: S.filesNotText,
              )
            : Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: OCTypography.mono(size: 12.5),
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(OCSpace.md),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      OCSpace.lg,
                      OCSpace.xs,
                      OCSpace.lg,
                      OCSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: context.oc.card,
                      border: Border(top: BorderSide(color: context.oc.line)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${c.text.split('\n').length} lines · ${c.text.length} chars',
                          style: OCTypography.micro,
                        ),
                        const Spacer(),
                        if (dirty)
                          OCButton(
                            onPressed: _save,
                            label: saving ? S.saving : S.save,
                            variant: OCButtonVariant.primaryBlack,
                            expand: false,
                            height: 36,
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
