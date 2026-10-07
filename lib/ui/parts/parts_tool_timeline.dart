part of '../parts.dart';

/// Reference `.steps`: tool calls collapse into a compact vertical stack of
/// action cards instead of a wall of cards.
///
/// Each step is one rounded card — a blue icon tile for the tool, the name in
/// bold, the summary (command or file) in monospace, a status dot + label on
/// the right, and a chevron. Tapping a step expands its output into the dark
/// code block below it. Non-tool parts (reasoning, patches, subtasks) still
/// render as tiles underneath.
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
    // Consecutive reasoning parts become one collapsed row. Rendered
    // individually they pushed the actual answer off screen and read like a
    // wall of italic text.
    final reasoning = <Part>[];
    for (final p in widget.parts) {
      if (p.type == 'tool') {
        tools.add(p);
        continue;
      }
      if (p.type == 'reasoning') {
        reasoning.add(p);
        continue;
      }
      rest.add(p);
    }
    // Reasoning comes first, as it happened: think, then act. It used to sit
    // under the tool rows, which read as the model "going back to thinking"
    // after every command.
    final thinking = reasoning.isEmpty ? null : ThinkingGroup(parts: reasoning);
    final others = <Widget>[for (final p in rest) PartTile(p)];
    if (tools.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [if (thinking != null) thinking, ...others],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thinking != null) thinking,
        // Reference `.chain`: each step is one rounded card, stacked with a
        // small gap, instead of rows on a shared rail. The card form survives
        // inside the assistant block because the icons carry the tool kind
        // where the dot rail once carried only status.
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final p in tools) _buildStep(p)],
        ),
        ...others,
      ],
    );
  }

  Widget _buildStep(Part p) {
    final t = context.oc;
    final key = '${p.id}:${p.toolCallId}';
    final open = _open.contains(key);
    final status = p.status;
    final exit = p.exitCode;
    // A finished bash call that exited non-zero is a failure even when the
    // event never reported `error`.
    final bad = status == ToolStatus.error || (exit != null && exit != 0);

    // Reference `.badge-dot`: accent while in flight, green once finished,
    // red on failure, muted before it starts.
    final dur = p.toolEnd > 0 ? fmtDuration(p.toolEnd - p.toolStart) : '';
    final (Color dot, String statusText, Color labelColor) = switch (status) {
      ToolStatus.completed =>
        bad
            ? (t.err, 'Failed', t.errInk)
            : (t.ok, dur.isEmpty ? 'Completed' : 'Completed · $dur', t.okInk),
      ToolStatus.error => (t.err, 'Failed', t.errInk),
      ToolStatus.running => (t.acc, 'Running', t.accInk),
      _ => (t.faint, 'Pending', t.faint),
    };

    final summary = (p.summaryLine.isEmpty ? p.toolName : p.summaryLine)
        .replaceAll('\n', ' ');
    final name = p.toolName.isEmpty ? 'tool' : p.toolName;
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

    // Reference `.chain-icon`: a rounded tile in the design's cool blue, the
    // glyph chosen by the tool kind.
    final icon = switch (name) {
      'bash' => LI.terminal,
      'edit' || 'write' || 'patch' => LI.code,
      _ => LI.spark,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.deep,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: LIcon(icon, size: 16, color: t.tertiary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // `<b>tool</b>` — bold name.
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.body.copyWith(
                            color: t.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // The summary (the command for bash, the file for
                        // edit) truncates under it in monospace.
                        Text(
                          exit != null && exit != 0 ? 'exit $exit' : summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.mono(
                            size: 12,
                            color: t.mute,
                          ).copyWith(height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dot,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.card, width: 1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: OCTypography.caption.copyWith(
                          fontSize: 12,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  if (hasDetail)
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: OCMotion.micro,
                      child: LIcon(LI.chevronDown, size: 16, color: t.mute),
                    ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (p.toolInput.isNotEmpty &&
                      p.toolInput.keys.any(
                        (k) => k != 'command' || p.toolName != 'bash',
                      ))
                    _InputBlock(json: p.toolInput),
                  if (out.isNotEmpty) _OutputBlock(text: out, isError: bad),
                ],
              ),
            ),
        ],
      ),
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
      title: S.partsThinking,
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
      title: S.partsPatch,
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
              S.contextCompacted,
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
