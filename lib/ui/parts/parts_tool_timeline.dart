part of '../parts.dart';

/// Reference `.steps`: a whole batch of tool calls folds into one collapsible
/// block under a single summary title ("Searched files", "Ran 3 commands"),
/// so the transcript stays on the answer. Opening the block reveals the
/// reasoning and the per-step rail; tapping a step expands its raw output.
/// Non-tool parts (patches, subtasks) render as tiles inside the block.
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
    final t = context.oc;
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
    final others = <Widget>[for (final p in rest) PartTile(p)];

    // No tool calls: reasoning keeps its own compact row and plain tiles
    // (patches, retries, compaction) render as themselves.
    if (tools.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reasoning.isNotEmpty) ThinkingGroup(parts: reasoning),
          ...others,
        ],
      );
    }

    // Every tool call of this step folds into one accordion. Collapsed it is a
    // single summary line; opening it reveals the reasoning, the step-by-step
    // rail and the raw output, so the transcript only ever shows the headline
    // and the final answer.
    final anyRunning = tools.any(
      (p) => p.status == ToolStatus.running || p.status == ToolStatus.pending,
    );
    final anyError = tools.any((p) => p.status == ToolStatus.error);
    final accent = anyError
        ? t.err
        : (anyRunning ? t.acc : t.mute);

    return _Collapsible(
      icon: _groupIcon(tools),
      title: _groupTitle(tools, anyRunning),
      subtitle: _groupSubtitle(tools),
      color: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reasoning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ThinkingGroup(parts: reasoning),
            ),
          _rail(context, tools),
          ...others,
        ],
      ),
    );
  }

  Widget _rail(BuildContext context, List<Part> tools) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 0, 6),
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

/// The kind of work a batch of tool calls represents. Drives the accordion's
/// icon and its summary title.
enum _Op { search, edit, command, web, agent, mixed }

_Op _opOf(String name) => switch (name) {
  'read' || 'glob' || 'grep' || 'list' || 'search' => _Op.search,
  'write' || 'edit' || 'patch' || 'multiedit' => _Op.edit,
  'bash' || 'shell' => _Op.command,
  'webfetch' || 'websearch' => _Op.web,
  'task' || 'agent' => _Op.agent,
  _ => _Op.mixed,
};

/// The batch's dominant action: one category if the calls agree, the majority
/// category when it clearly dominates (>=60%), otherwise a generic "mixed".
_Op _dominantOp(List<Part> tools) {
  final counts = <_Op, int>{};
  for (final p in tools) {
    final op = _opOf(p.toolName);
    counts[op] = (counts[op] ?? 0) + 1;
  }
  if (counts.length == 1) return counts.keys.first;
  for (final e in counts.entries) {
    if (e.key != _Op.mixed && e.value / tools.length >= 0.6) return e.key;
  }
  return _Op.mixed;
}

IconData _groupIcon(List<Part> tools) => switch (_dominantOp(tools)) {
  _Op.search => toolIcon('grep'),
  _Op.edit => toolIcon('edit'),
  _Op.command => toolIcon('bash'),
  _Op.web => toolIcon('webfetch'),
  _Op.agent => toolIcon('task'),
  _Op.mixed => Icons.build_outlined,
};

String _groupTitle(List<Part> tools, bool running) {
  final op = _dominantOp(tools);
  final n = tools.length;
  if (running) {
    return switch (op) {
      _Op.search => S.groupSearching,
      _Op.edit => S.groupEditing,
      _Op.command => S.groupRunningCommands,
      _Op.web => S.groupBrowsing,
      _Op.agent => S.groupRunningTasks,
      _Op.mixed => S.groupWorking,
    };
  }
  return switch (op) {
    _Op.search => S.groupSearchedFiles,
    _Op.edit => S.groupEditedFiles,
    _Op.command => S.groupRanCommands(n),
    _Op.web => S.groupBrowsedWeb,
    _Op.agent => S.groupRanTasks,
    _Op.mixed => S.groupRanSteps(n),
  };
}

String _groupSubtitle(List<Part> tools) {
  final start = tools
      .map((p) => p.toolStart)
      .where((v) => v > 0)
      .fold<int>(0, (a, b) => a == 0 || b < a ? b : a);
  final end = tools
      .map((p) => p.toolEnd)
      .where((v) => v > 0)
      .fold<int>(0, (a, b) => b > a ? b : a);
  final dur = start > 0 && end > start ? fmtDuration(end - start) : '';
  // A single call names itself ("npm run build"); a batch reports its size.
  final head = tools.length == 1
      ? tools.single.summaryLine.replaceAll('\n', ' ').trim()
      : S.groupSteps(tools.length);
  return [if (head.isNotEmpty) head, if (dur.isNotEmpty) dur].join(' · ');
}
