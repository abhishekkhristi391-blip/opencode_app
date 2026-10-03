import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import 'line_icons.dart';
import 'markdown.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

/// Reference `.steps`: tool calls collapse into a compact vertical timeline
/// instead of a stack of cards.
///
/// Each step is one 34px line — a status dot on a 2px rail, the tool name in
/// bold, the summary in monospace with an ellipsis, and a chevron. Tapping a
/// step expands its output into the dark code block below it. Non-tool parts
/// (reasoning, patches, subtasks) still render as tiles underneath.
class ToolTimeline extends StatefulWidget {
  final List<Part> parts;
  const ToolTimeline({required this.parts, super.key});

  @override
  State<ToolTimeline> createState() => _ToolTimelineState();
}

class _ToolTimelineState extends State<ToolTimeline> {
  /// Keys of the steps whose output is showing.
  final Set<String> _open = <String>{};

  @override
  Widget build(BuildContext context) {
    final tools = <Part>[];
    final rest = <Part>[];
    for (final p in widget.parts) {
      (p.type == 'tool' ? tools : rest).add(p);
    }
    if (tools.isEmpty)
      return Column(children: [for (final p in rest) PartTile(p)]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Stack(
            children: [
              // The rail: a 2px line behind the dots, inset from the top and
              // bottom so it does not overshoot the first and last step.
              Positioned(
                left: 4,
                top: 10,
                bottom: 10,
                width: 2,
                child: ColoredBox(color: context.oc.line),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final p in tools) _buildStep(p)],
              ),
            ],
          ),
        ),
        for (final p in rest) PartTile(p),
      ],
    );
  }

  Widget _buildStep(Part p) {
    final t = context.oc;
    final key = '${p.id}:${p.toolCallId}';
    final open = _open.contains(key);
    final status = p.status;
    // Reference `.step.run`: accent while in flight, green once finished,
    // red on failure, muted outline before it starts.
    final dotColor = switch (status) {
      ToolStatus.completed => t.ok,
      ToolStatus.error => t.err,
      ToolStatus.running => t.acc,
      _ => t.mute,
    };

    final summary = (p.summaryLine.isEmpty ? p.toolName : p.summaryLine)
        .replaceAll('\n', ' ');
    final name = p.toolName.isEmpty ? 'tool' : p.toolName;
    final dur = p.toolEnd > 0 ? fmtDuration(p.toolEnd - p.toolStart) : '';
    final exit = p.exitCode;
    final out = p.output.isNotEmpty
        ? p.output
        : (p.errorText.isNotEmpty
              ? p.errorText
              : p.toolMeta['output']?.toString() ?? '');
    final hasDetail =
        out.isNotEmpty ||
        (p.toolInput.isNotEmpty &&
            p.toolInput.keys.any(
              (k) => k != 'command' || p.toolName != 'bash',
            ));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 10px dot, 2px ring in the page background so the rail reads as
        // passing behind it. Centred vertically against the step row.
        Positioned(
          left: -18,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: t.bg, width: 2),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: hasDetail
                  ? () => setState(
                      () => _open.contains(key)
                          ? _open.remove(key)
                          : _open.add(key),
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    // `<b>tool</b>` — bold name, then the summary filling the
                    // rest of the line and truncating with an ellipsis.
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.body.copyWith(
                          color: t.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        [
                          summary,
                          if (dur.isNotEmpty) dur,
                          if (exit != null) 'exit $exit',
                          if (p.truncated) 'truncated',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.mono(
                          size: 12,
                          color: t.mute,
                        ).copyWith(height: 1.2),
                      ),
                    ),
                    if (hasDetail) ...[
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: LIcon(LI.chevronDown, size: 16, color: t.mute),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (open)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (p.toolInput.isNotEmpty &&
                        p.toolInput.keys.any(
                          (k) => k != 'command' || p.toolName != 'bash',
                        ))
                      _InputBlock(json: p.toolInput),
                    if (out.isNotEmpty)
                      _OutputBlock(
                        text: out,
                        isError:
                            status == ToolStatus.error ||
                            (exit != null && exit != 0),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class PartTile extends StatelessWidget {
  final Part part;
  final bool compact;
  const PartTile(this.part, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) => switch (part.type) {
    'text' =>
      part.text.trim().isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Markdown(
                part.text,
                base: Theme.of(context).textTheme.bodyMedium,
                onLink: (url) => launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
    'reasoning' => _Collapsible(
      icon: Icons.psychology_alt_outlined,
      title: 'Thinking',
      subtitle: _firstLine(part.text),
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OCSpace.md,
          0,
          OCSpace.md,
          OCSpace.md,
        ),
        child: Text(
          part.text,
          style: OCTypography.caption.copyWith(
            height: 1.5,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
    'tool' => ToolTile(part),
    'file' => _FilePart(part),
    'patch' => _Collapsible(
      icon: Icons.difference_outlined,
      title: 'Patch',
      subtitle:
          '${part.patchText.split('\n').where((l) => l.startsWith('+') || l.startsWith('-')).length} lines',
      color: Theme.of(context).colorScheme.tertiary,
      child: DiffText(part.patchText),
    ),
    'subtask' => _Collapsible(
      icon: Icons.account_tree_outlined,
      title:
          'Subtask${part.subtaskAgent.isEmpty ? '' : ' · ${part.subtaskAgent}'}',
      subtitle: _firstLine(part.text),
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OCSpace.md,
          0,
          OCSpace.md,
          OCSpace.md,
        ),
        child: Mono(part.text.isEmpty ? part.raw.toString() : part.text),
      ),
    ),
    'agent' => _AgentPart(part),
    'retry' => _RetryPart(part),
    'compaction' => Container(
      margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
      padding: const EdgeInsets.all(OCSpace.md),
      decoration: BoxDecoration(
        color: OCColors.orangeTint,
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      child: Row(
        children: [
          const OCIconTile(
            icon: Icons.compress,
            accent: OCAccent.orange,
            size: 28,
            iconSize: 15,
          ),
          const SizedBox(width: OCSpace.md),
          Expanded(
            child: Text(
              'Context compact kiya gaya',
              style: OCTypography.caption.copyWith(color: OCColors.orangeInk),
            ),
          ),
        ],
      ),
    ),
    'snapshot' => const SizedBox.shrink(),
    _ => _UnknownPart(part),
  };
}

String _firstLine(String s) {
  final l = s
      .trim()
      .split('\n')
      .firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
  return l.length > 70 ? '${l.substring(0, 70)}…' : l;
}

class _Collapsible extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;
  const _Collapsible({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.color,
  });

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(OCRadius.inner);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
      decoration: BoxDecoration(
        color: OCColors.surfaceSubtle,
        borderRadius: shape,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: shape,
              onTap: () => setState(() => open = !open),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.md,
                  vertical: OCSpace.md,
                ),
                child: Row(
                  children: [
                    OCIconTile(
                      icon: widget.icon,
                      accent: OCAccent.neutral,
                      size: 28,
                      iconSize: 15,
                      color: widget.color,
                    ),
                    const SizedBox(width: OCSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: OCTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.color,
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty)
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OCTypography.micro.copyWith(
                                color: OCColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: OCColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            if (open) ...[const Divider(height: 1), widget.child],
          ],
        ),
      ),
    );
  }
}

class ToolTile extends StatelessWidget {
  final Part part;
  const ToolTile(this.part, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final st = part.status;
    final color = toolColor(st, cs);
    final dur = part.toolEnd > 0
        ? fmtDuration(part.toolEnd - part.toolStart)
        : '';
    final exit = part.exitCode;

    final title = part.summaryLine.isEmpty ? part.toolName : part.summaryLine;
    final out = part.output.isNotEmpty
        ? part.output
        : (part.errorText.isNotEmpty
              ? part.errorText
              : part.toolMeta['output']?.toString() ?? '');

    return _Collapsible(
      icon: toolIcon(part.toolName),
      title: part.toolName.isEmpty ? 'tool' : part.toolName,
      subtitle: [
        title.replaceAll('\n', ' '),
        if (dur.isNotEmpty) dur,
        if (exit != null) 'exit $exit',
        if (part.truncated) 'truncated',
      ].join(' · '),
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (part.toolInput.isNotEmpty &&
              part.toolInput.keys.any(
                (k) => k != 'command' || part.toolName != 'bash',
              ))
            _InputBlock(json: part.toolInput),
          if (out.isNotEmpty)
            _OutputBlock(
              text: out,
              isError: st == ToolStatus.error || (exit != null && exit != 0),
            ),
        ],
      ),
    );
  }
}

class _InputBlock extends StatelessWidget {
  final Map<String, dynamic> json;
  const _InputBlock({required this.json});

  @override
  Widget build(BuildContext context) {
    final text = json.entries
        .map(
          (e) => '${e.key}: ${e.value is String ? e.value : _pretty(e.value)}',
        )
        .join('\n');
    return Padding(
      padding: const EdgeInsets.fromLTRB(OCSpace.md, OCSpace.sm, OCSpace.md, 0),
      child: Text(
        text,
        style: OCTypography.monoSmall(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static String _pretty(dynamic v) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (e) {
      if (kDebugMode) debugPrint('JSON encode failed: $e');
      return v.toString();
    }
  }
}

class _OutputBlock extends StatefulWidget {
  final String text;
  final bool isError;
  const _OutputBlock({required this.text, required this.isError, super.key});

  @override
  State<_OutputBlock> createState() => _OutputBlockState();
}

class _OutputBlockState extends State<_OutputBlock> {
  static const _maxLines = 40;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final lines = widget.text.split('\n');
    final truncated = lines.length > _maxLines;
    final shown = _expanded || !truncated
        ? widget.text
        : lines.take(_maxLines).join('\n');

    // Reference `.out`: always the dark code surface, in both themes.
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.code,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              shown,
              style: OCTypography.mono(
                size: 12,
                color: t.codeInk,
              ).copyWith(height: 1.5),
            ),
          ),
          if (truncated)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '... ${widget.text.length} chars (${lines.length} lines)',
                      style: OCTypography.micro.copyWith(color: t.codeInk),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : 'Show more',
                      style: TextStyle(color: t.codeInk),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Clipboard.setData(ClipboardData(text: widget.text)),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: LIcon(LI.copy, size: 15, color: t.codeInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePart extends StatelessWidget {
  final Part part;
  const _FilePart(this.part);

  @override
  Widget build(BuildContext context) {
    final isImage = part.mime.startsWith('image/');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
      padding: const EdgeInsets.all(OCSpace.sm + 2),
      decoration: BoxDecoration(
        color: OCColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      child: Row(
        children: [
          OCIconTile(
            icon: isImage ? Icons.image_outlined : Icons.attach_file,
            accent: OCAccent.blue,
            size: 28,
            iconSize: 15,
          ),
          const SizedBox(width: OCSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.filename.isEmpty ? baseName(part.url) : part.filename,
                  style: OCTypography.body.copyWith(
                    color: OCColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(part.mime, style: OCTypography.micro),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentPart extends StatelessWidget {
  final Part part;
  const _AgentPart(this.part);

  @override
  Widget build(BuildContext context) => _Collapsible(
    icon: Icons.bolt,
    title: 'Agent · ${part.subtaskAgent.isEmpty ? '?' : part.subtaskAgent}',
    subtitle: part.text.isEmpty ? '' : part.text,
    color: Theme.of(context).colorScheme.primary,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        OCSpace.md,
        OCSpace.sm,
        OCSpace.md,
        OCSpace.md,
      ),
      child: Text(part.text, style: OCTypography.caption),
    ),
  );
}

class _RetryPart extends StatelessWidget {
  final Part part;
  const _RetryPart(this.part);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
    padding: const EdgeInsets.all(OCSpace.sm + 2),
    decoration: BoxDecoration(
      color: OCColors.surfaceMuted,
      borderRadius: BorderRadius.circular(OCRadius.inner),
    ),
    child: Row(
      children: [
        const OCIconTile(
          icon: Icons.refresh,
          accent: OCAccent.orange,
          size: 28,
          iconSize: 15,
        ),
        const SizedBox(width: OCSpace.md),
        Expanded(
          child: Text(
            part.reason.isEmpty ? 'Retrying…' : part.reason,
            style: OCTypography.caption.copyWith(color: OCColors.textPrimary),
          ),
        ),
      ],
    ),
  );
}

class _UnknownPart extends StatelessWidget {
  final Part part;
  const _UnknownPart(this.part);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
    padding: const EdgeInsets.all(OCSpace.sm + 2),
    decoration: BoxDecoration(
      color: OCColors.surfaceMuted,
      borderRadius: BorderRadius.circular(OCRadius.inner),
    ),
    child: Row(
      children: [
        const OCIconTile(
          icon: Icons.extension_outlined,
          accent: OCAccent.neutral,
          size: 28,
          iconSize: 15,
        ),
        const SizedBox(width: OCSpace.md),
        Expanded(
          child: Text(
            '${part.type}: ${part.text.isEmpty ? part.raw.toString() : part.text}',
            style: OCTypography.monoSmall(color: OCColors.textPrimary),
          ),
        ),
      ],
    ),
  );
}

class DiffText extends StatelessWidget {
  final String diff;
  const DiffText(this.diff, {super.key});

  @override
  Widget build(BuildContext context) {
    final add = OCColors.greenInk;
    final del = OCColors.redInk;
    final lines = diff.split('\n');
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      color: OCColors.surfaceSubtle,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lines.length,
          itemBuilder: (_, i) {
            final l = lines[i];
            return Container(
              width: double.infinity,
              color: l.startsWith('+')
                  ? OCColors.greenTint
                  : l.startsWith('-')
                  ? OCColors.redTint
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              child: Text(
                l.isEmpty ? ' ' : l,
                style: OCTypography.mono(
                  size: 11.5,
                  color: l.startsWith('+')
                      ? add
                      : l.startsWith('-')
                      ? del
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
