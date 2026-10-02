import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import 'parts.dart';
import 'widgets.dart';

class DiffPage extends StatefulWidget {
  const DiffPage({super.key});

  @override
  State<DiffPage> createState() => _DiffPageState();
}

class _DiffPageState extends State<DiffPage> {
  String source = 'session';
  String gitMode = 'worktree';
  List<FileDiff> sessionFiles = [];
  String rawDiff = '';
  List<String> vcsFiles = [];
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });
    final store = AppScope.read(context);
    try {
      if (source == 'session') {
        if (store.current == null) {
          setState(() {
            err = 'Koi active session nahi.';
            loading = false;
          });
          return;
        }
        final d = await store.api.diff(store.current!.id);
        rawDiff = '';
        vcsFiles = [];
        sessionFiles = d;
      } else {
        final d = await store.api.vcsDiff(mode: gitMode);
        rawDiff = d;
        try {
          final st = await store.api.vcsStatus();
          vcsFiles = st.map((e) {
            final a = asMap(e);
            final type = asStr(a['type'], 'modified');
            final path = asStr(a['path'], asStr(a['file']));
            return '$type\t$path';
          }).toList();
        } catch (_) {}
        sessionFiles = [];
      }
      if (!mounted) return;
      setState(() => loading = false);
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
    final store = AppScope.of(context);
    final isRepo = store.vcs?.isRepo == true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              SegmentedButton<String>(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: 'session', label: Text('Session', style: TextStyle(fontSize: 12)), icon: Icon(Icons.chat, size: 15)),
                  ButtonSegment(value: 'git', label: Text('Git', style: TextStyle(fontSize: 12)), icon: Icon(Icons.commit, size: 15)),
                ],
                selected: {source},
                onSelectionChanged: (s) {
                  setState(() => source = s.first);
                  _load();
                },
              ),
              const Spacer(),
              IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: _load),
            ],
          ),
        ),
        if (source == 'git' && isRepo)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final m in const ['worktree', 'staged'])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(m, style: const TextStyle(fontSize: 12)),
                      selected: gitMode == m,
                      onSelected: (_) {
                        setState(() => gitMode = m);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          )
        else if (source == 'git')
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 15, color: cs.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Ye project git repo nahi hai, isliye git diff nahi hai.',
                    style: TextStyle(fontSize: 12, color: cs.outline)),
              ),
            ]),
          ),
        const Divider(height: 1),
        Expanded(
          child: loading
              ? const LoadingView()
              : err != null
                  ? EmptyHint(icon: Icons.error_outline, title: 'Diff load nahi hua', message: err!)
                  : source == 'session'
                      ? (sessionFiles.isEmpty
                          ? const EmptyHint(
                              icon: Icons.check_circle_outline,
                              title: 'Koi change nahi',
                              message: 'Is session me abhi tak koi file modify nahi hui.')
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: sessionFiles.length,
                              itemBuilder: (_, i) => _SessionDiffTile(d: sessionFiles[i]),
                            ))
                      : _GitDiffView(raw: rawDiff, files: vcsFiles),
        ),
      ],
    );
  }
}

class _SessionDiffTile extends StatelessWidget {
  final FileDiff d;
  const _SessionDiffTile({required this.d});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = AppScope.of(context);
    final preview = _unifiedPreview(d);

    return ExpansionTile(
      leading: const Icon(Icons.insert_drive_file_outlined, size: 20),
      title: Text(d.file.isEmpty ? d.path : d.file,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
      subtitle: Row(children: [
        if (d.addCount > 0) Text('+${d.addCount}', style: const TextStyle(fontSize: 11, color: Color(0xFF3DDC84))),
        if (d.addCount > 0 && d.delCount > 0) const SizedBox(width: 6),
        if (d.delCount > 0) Text('-${d.delCount}', style: const TextStyle(fontSize: 11, color: const Color(0xFFFF5F57))),
        if (d.addCount == 0 && d.delCount == 0)
          Text('binary ya new file', style: TextStyle(fontSize: 11, color: cs.outline)),
      ]),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      children: [
        if (preview.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DiffText(preview),
          )
        else
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Is file ka textual diff nahi hai.', style: TextStyle(fontSize: 12, color: cs.outline)),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 6,
            children: [
              TextButton.icon(
                onPressed: () => copyToClipboard(context, preview),
                icon: const Icon(Icons.copy, size: 15),
                label: const Text('Copy diff', style: TextStyle(fontSize: 12)),
              ),
              if (store.vcs?.isRepo == true)
                TextButton.icon(
                  onPressed: () async {
                    final ok = await confirmDialog(context,
                        title: 'Patch apply karein?',
                        message: '${d.file} par patch apply hoga.',
                        confirm: 'Apply');
                    if (!ok) return;
                    try {
                      await store.api.vcsApply(_toGitPatch(d, store.vcs!.defaultBranch.isEmpty ? null : store.vcs!.defaultBranch));
                      if (context.mounted) showSnack(context, 'Apply ho gaya');
                    } catch (e) {
                      if (context.mounted) showSnack(context, '$e', error: true);
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 15),
                  label: const Text('Apply', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a unified diff from the session's before/after snapshots.
  static String _unifiedPreview(FileDiff d) {
    if (d.before.isEmpty && d.after.isEmpty) return '';
    final a = _split(d.before);
    final b = _split(d.after);
    final out = StringBuffer();
    final path = d.file.isEmpty ? d.path : d.file;
    out.writeln('--- a/$path');
    out.writeln('+++ b/$path');
    final ops = _diffOps(a, b);
    for (final o in ops.take(600)) {
      out.writeln(o);
    }
    if (ops.length > 600) out.writeln('... ${ops.length - 600} aur lines');
    return out.toString();
  }

  static List<String> _split(String s) => s.isEmpty ? const [] : s.replaceAll('\r\n', '\n').split('\n');

  /// Simple LCS-based line diff; small enough for the file sizes involved.
  static List<String> _diffOps(List<String> a, List<String> b) {
    final n = a.length, m = b.length;
    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
    for (var i = n - 1; i >= 0; i--) {
      for (var j = m - 1; j >= 0; j--) {
        dp[i][j] = a[i] == b[j] ? dp[i + 1][j + 1] + 1 : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
      }
    }
    final out = <String>[];
    var i = 0, j = 0;
    var context = 0;
    while (i < n && j < m) {
      if (a[i] == b[j]) {
        out.add(' ${a[i]}');
        i++;
        j++;
        context++;
      } else if (dp[i + 1][j] >= dp[i][j + 1]) {
        out.add('-${a[i]}');
        i++;
        context = 0;
      } else {
        out.add('+${b[j]}');
        j++;
        context = 0;
      }
      if (context > 6) {
        while (i < n && j < m && a[i] == b[j]) {
          out.add(' ${a[i]}');
          i++;
          j++;
        }
        context = 0;
      }
    }
    while (i < n) {
      out.add('-${a[i++]}');
    }
    while (j < m) {
      out.add('+${b[j++]}');
    }
    return out;
  }

  static String _toGitPatch(FileDiff d, String? base) => _unifiedPreview(d);
}

class _GitDiffView extends StatelessWidget {
  final String raw;
  final List<String> files;
  const _GitDiffView({required this.raw, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty && raw.isEmpty) {
      return const EmptyHint(
          icon: Icons.check_circle_outline, title: 'Koi diff nahi', message: 'Worktree clean hai.');
    }
    if (raw.isEmpty) {
      return ListView.builder(
        itemCount: files.length,
        itemBuilder: (_, i) {
          final parts = files[i].split('\t');
          final color = parts.first.contains('A')
              ? const Color(0xFF3DDC84)
              : parts.first.contains('D')
                  ? const Color(0xFFFF5F57)
                  : null;
          return ListTile(
            dense: true,
            leading: Text(parts.first, style: TextStyle(fontSize: 11, color: color)),
            title: Text(parts.length > 1 ? parts[1] : parts.first,
                style: const TextStyle(fontSize: 12.5, fontFamily: 'monospace')),
          );
        },
      );
    }
    return Column(
      children: [
        Expanded(child: SingleChildScrollView(child: DiffText(raw))),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('${raw.split('\n').length} lines',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                ),
                TextButton.icon(
                  onPressed: () => copyToClipboard(context, raw),
                  icon: const Icon(Icons.copy, size: 15),
                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
