import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import 'markdown.dart';
import 'widgets.dart';

class PartTile extends StatelessWidget {
  final Part part;
  final bool compact;
  const PartTile(this.part, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) => switch (part.type) {
        'text' => part.text.trim().isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Markdown(part.text, base: Theme.of(context).textTheme.bodyMedium),
              ),
        'reasoning' => _Collapsible(
            icon: Icons.psychology_alt_outlined,
            title: 'Thinking',
            subtitle: _firstLine(part.text),
            color: Theme.of(context).colorScheme.tertiary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                part.text,
                style: TextStyle(
                  fontSize: 12.5,
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
            subtitle: '${part.patchText.split('\n').where((l) => l.startsWith('+') || l.startsWith('-')).length} lines',
            color: Theme.of(context).colorScheme.tertiary,
            child: DiffText(part.patchText),
          ),
        'subtask' => _Collapsible(
            icon: Icons.account_tree_outlined,
            title: 'Subtask${part.subtaskAgent.isEmpty ? '' : ' · ${part.subtaskAgent}'}',
            subtitle: _firstLine(part.text),
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Mono(part.text.isEmpty ? part.raw.toString() : part.text),
            ),
          ),
        'agent' => _AgentPart(part),
        'retry' => _RetryPart(part),
        'compaction' => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(Icons.compress, size: 15, color: Theme.of(context).colorScheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Context compact kiya gaya',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer))),
            ]),
          ),
        'snapshot' => const SizedBox.shrink(),
        _ => _UnknownPart(part),
      };
}

String _firstLine(String s) {
  final l = s.trim().split('\n').firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () => setState(() => open = !open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(widget.icon, size: 15, color: widget.color),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: widget.color)),
                        if (widget.subtitle.isNotEmpty)
                          Text(widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: cs.outline)),
                      ],
                    ),
                  ),
                  Icon(open ? Icons.expand_less : Icons.expand_more, size: 17, color: cs.outline),
                ],
              ),
            ),
          ),
          if (open) ...[const Divider(height: 1), widget.child],
        ],
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
    final dur = part.toolEnd > 0 ? fmtDuration(part.toolEnd - part.toolStart) : '';
    final exit = part.exitCode;

    final title = part.summaryLine.isEmpty ? part.toolName : part.summaryLine;
    final out = part.output.isNotEmpty
        ? part.output
        : (part.errorText.isNotEmpty ? part.errorText : part.toolMeta['output']?.toString() ?? '');

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
          if (part.toolInput.isNotEmpty && part.toolInput.keys.any((k) => k != 'command' || part.toolName != 'bash'))
            _InputBlock(json: part.toolInput),
          if (out.isNotEmpty) _OutputBlock(text: out, isError: st == ToolStatus.error || (exit != null && exit != 0)),
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
        .map((e) => '${e.key}: ${e.value is String ? e.value : _pretty(e.value)}')
        .join('\n');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'monospace', fontSize: 11.5, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  static String _pretty(dynamic v) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }
}

class _OutputBlock extends StatelessWidget {
  final String text;
  final bool isError;
  const _OutputBlock({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxLines = 40;
    final truncated = text.split('\n').length > maxLines;
    final shown = truncated ? text.split('\n').take(maxLines).join('\n') : text;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: isError ? cs.errorContainer.withValues(alpha: 0.4) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(shown,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.45,
                  color: isError ? cs.onErrorContainer : cs.onSurface,
                )),
          ),
          if (truncated)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('... ${text.length} chars',
                  style: TextStyle(fontSize: 10.5, color: cs.outline)),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 15,
              icon: const Icon(Icons.copy, size: 15),
              onPressed: () => Clipboard.setData(ClipboardData(text: text)),
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
    final cs = Theme.of(context).colorScheme;
    final isImage = part.mime.startsWith('image/');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(isImage ? Icons.image_outlined : Icons.attach_file, size: 17, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.filename.isEmpty ? baseName(part.url) : part.filename,
                    style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                Text(part.mime, style: TextStyle(fontSize: 10.5, color: cs.outline)),
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
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Text(part.text, style: const TextStyle(fontSize: 12)),
        ),
      );
}

class _RetryPart extends StatelessWidget {
  final Part part;
  const _RetryPart(this.part);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.refresh, size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(part.reason.isEmpty ? 'Retrying…' : part.reason, style: const TextStyle(fontSize: 12))),
        ]),
      );
}

class _UnknownPart extends StatelessWidget {
  final Part part;
  const _UnknownPart(this.part);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(Icons.extension_outlined, size: 14, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${part.type}: ${part.text.isEmpty ? part.raw.toString() : part.text}',
                style: const TextStyle(fontSize: 11.5)),
          ),
        ]),
      );
}

class DiffText extends StatelessWidget {
  final String diff;
  const DiffText(this.diff, {super.key});

  @override
  Widget build(BuildContext context) {
    final add = const Color(0xFF3DDC84);
    final del = const Color(0xFFFF5F57);
    final lines = diff.split('\n');
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final l in lines)
                Container(
                  width: double.infinity,
                  color: l.startsWith('+')
                      ? add.withValues(alpha: 0.12)
                      : l.startsWith('-')
                          ? del.withValues(alpha: 0.12)
                          : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  child: Text(
                    l.isEmpty ? ' ' : l,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      height: 1.4,
                      color: l.startsWith('+')
                          ? add
                          : l.startsWith('-')
                              ? del
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
