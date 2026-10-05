part of '../chat.dart';

class _FilePickerSheet extends StatefulWidget {
  const _FilePickerSheet();

  @override
  State<_FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends State<_FilePickerSheet> {
  String dir = '.';
  List<FileNode> nodes = [];
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? d]) async {
    setState(() {
      loading = true;
      err = null;
      if (d != null) dir = d;
    });
    try {
      final list = await AppScope.read(context).api.files(dir);
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        return a.name.compareTo(b.name);
      });
      if (!mounted) return;
      setState(() {
        nodes = list;
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(
              children: [
                if (dir != '.')
                  IconButton(
                    iconSize: 19,
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => _load(dir == '.' ? '.' : dirName(dir)),
                  ),
                Expanded(
                  child: Mono(dir == '.' ? S.filesProjectRoot : dir, size: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
                ? const EmptyHint(
                    icon: Icons.folder_off_outlined,
                    title: S.empty,
                    message: S.filesEmptyBody,
                  )
                : ListView.builder(
                    itemCount: nodes.length,
                    itemBuilder: (_, i) {
                      final n = nodes[i];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          n.isDir ? Icons.folder_outlined : _iconFor(n.name),
                          size: 19,
                          color: n.isDir
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          n.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () =>
                            n.isDir ? _load(n.path) : Navigator.pop(context, n),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => Icons.code,
      'js' || 'ts' || 'jsx' || 'tsx' => Icons.javascript,
      'py' => Icons.code,
      'json' => Icons.data_object,
      'md' => Icons.article_outlined,
      'yaml' || 'yml' => Icons.settings_input_component,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => Icons.image_outlined,
      'sh' => Icons.terminal,
      'lock' => Icons.lock_outline,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}
