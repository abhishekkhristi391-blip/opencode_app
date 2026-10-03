import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'parts.dart';
import 'primitives.dart';
import 'theme.dart';
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
        } catch (e) {
          debugPrint('Failed to load VCS status: $e');
        }
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
    final store = AppScope.of(context);
    final isRepo = store.vcs?.isRepo == true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.screenX,
            OCSpace.md,
            OCSpace.md,
            OCSpace.sm,
          ),
          child: Row(
            children: [
              OCSegmentedControl<String>(
                segments: const [
                  OCSegment('session', 'Session', icon: Icons.chat),
                  OCSegment('git', 'Git', icon: Icons.commit),
                ],
                value: source,
                onChanged: (v) {
                  setState(() => source = v);
                  _load();
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: _load,
              ),
            ],
          ),
        ),
        if (source == 'git' && isRepo)
          SizedBox(
            height: OCSpace.tapTarget,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
              children: [
                for (final m in const ['worktree', 'staged'])
                  Padding(
                    padding: const EdgeInsets.only(right: OCSpace.sm),
                    child: ChoiceChip(
                      label: Text(
                        m,
                        style: OCTypography.caption.copyWith(
                          color: OCColors.textPrimary,
                        ),
                      ),
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
            margin: const EdgeInsets.fromLTRB(
              OCSpace.screenX,
              0,
              OCSpace.screenX,
              OCSpace.sm,
            ),
            padding: const EdgeInsets.all(OCSpace.md),
            decoration: BoxDecoration(
              color: OCColors.surfaceMuted,
              borderRadius: BorderRadius.circular(OCRadius.inner),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: OCColors.textTertiary,
                ),
                const SizedBox(width: OCSpace.sm),
                const Expanded(
                  child: Text(
                    'Ye project git repo nahi hai, isliye git diff nahi hai.',
                    style: TextStyle(
                      fontSize: 12,
                      color: OCColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 1, color: OCColors.borderHairline),
        Expanded(
          child: loading
              ? const LoadingView()
              : err != null
              ? EmptyHint(
                  icon: Icons.error_outline,
                  title: 'Diff load nahi hua',
                  message: err!,
                )
              : source == 'session'
              ? (sessionFiles.isEmpty
                    ? const EmptyHint(
                        icon: Icons.check_circle_outline,
                        title: 'Koi change nahi',
                        message:
                            'Is session me abhi tak koi file modify nahi hui.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: OCSpace.lg),
                        itemCount: sessionFiles.length,
                        itemBuilder: (_, i) =>
                            _SessionDiffTile(d: sessionFiles[i]),
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
    final store = AppScope.of(context);
    final preview = _unifiedPreview(d);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: OCColors.surface,
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: OCColors.surface,
        collapsedBackgroundColor: OCColors.surface,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const OCIconTile(
          icon: Icons.insert_drive_file_outlined,
          accent: OCAccent.blue,
          size: 32,
        ),
        title: Text(
          d.file.isEmpty ? d.path : d.file,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: OCTypography.caption,
        ),
        subtitle: Row(
          children: [
            if (d.addCount > 0)
              Text(
                '+${d.addCount}',
                style: const TextStyle(
                  fontSize: 11,
                  color: OCColors.greenInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (d.addCount > 0 && d.delCount > 0)
              const SizedBox(width: OCSpace.sm),
            if (d.delCount > 0)
              Text(
                '-${d.delCount}',
                style: const TextStyle(
                  fontSize: 11,
                  color: OCColors.redInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (d.addCount == 0 && d.delCount == 0)
              const Text('binary ya new file', style: TextStyle(fontSize: 11)),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          OCSpace.screenX,
          0,
          OCSpace.screenX,
          OCSpace.md,
        ),
        children: [
          if (preview.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(OCRadius.inner),
              child: DiffText(preview),
            )
          else
            Padding(
              padding: const EdgeInsets.all(OCSpace.md),
              child: Text(
                'Is file ka textual diff nahi hai.',
                style: OCTypography.caption,
              ),
            ),
          const SizedBox(height: OCSpace.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: OCSpace.sm,
              children: [
                TextButton.icon(
                  onPressed: () => copyToClipboard(context, preview),
                  icon: const Icon(Icons.copy, size: 15),
                  label: const Text(
                    'Copy diff',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                if (store.vcs?.isRepo == true)
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await confirmDialog(
                        context,
                        title: 'Patch apply karein?',
                        message: '${d.file} par patch apply hoga.',
                        confirm: 'Apply',
                      );
                      if (!ok) return;
                      try {
                        await store.api.vcsApply(
                          _toGitPatch(
                            d,
                            store.vcs!.defaultBranch.isEmpty
                                ? null
                                : store.vcs!.defaultBranch,
                          ),
                        );
                        if (context.mounted)
                          showSnack(context, 'Apply ho gaya');
                      } catch (e) {
                        if (context.mounted)
                          showSnack(context, '$e', error: true);
                      }
                    },
                    icon: const Icon(Icons.play_arrow, size: 15),
                    label: const Text('Apply', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
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

  static List<String> _split(String s) =>
      s.isEmpty ? const [] : s.replaceAll('\r\n', '\n').split('\n');

  /// Simple LCS-based line diff; small enough for the file sizes involved.
  static List<String> _diffOps(List<String> a, List<String> b) {
    final n = a.length, m = b.length;
    final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
    for (var i = n - 1; i >= 0; i--) {
      for (var j = m - 1; j >= 0; j--) {
        dp[i][j] = a[i] == b[j]
            ? dp[i + 1][j + 1] + 1
            : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
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
        icon: Icons.check_circle_outline,
        title: 'Koi diff nahi',
        message: 'Worktree clean hai.',
      );
    }
    if (raw.isEmpty) {
      return ListView.builder(
        itemCount: files.length,
        itemBuilder: (_, i) {
          final parts = files[i].split('\t');
          final color = parts.first.contains('A')
              ? OCColors.greenInk
              : parts.first.contains('D')
              ? OCColors.redInk
              : null;
          return ListTile(
            dense: true,
            leading: Text(
              parts.first,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            title: Text(
              parts.length > 1 ? parts[1] : parts.first,
              style: OCTypography.mono(size: 12.5),
            ),
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
            padding: const EdgeInsets.fromLTRB(
              OCSpace.md,
              OCSpace.sm,
              OCSpace.md,
              OCSpace.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${raw.split('\n').length} lines',
                    style: OCTypography.micro,
                  ),
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
