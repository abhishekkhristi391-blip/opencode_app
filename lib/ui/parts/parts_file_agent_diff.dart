part of '../parts.dart';

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
    title: S.partsAgent(part.subtaskAgent),
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

/// One collapsed row for a run of reasoning parts.
///
/// Collapsed by default. The previous behaviour showed every reasoning block
/// inline, so a single turn could fill the viewport with italic text before the
/// answer appeared.
class ThinkingGroup extends StatelessWidget {
  final List<Part> parts;
  const ThinkingGroup({required this.parts, super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final text = parts
        .map((p) => p.text)
        .where((s) => s.trim().isNotEmpty)
        .join('\n\n');
    // Tool timing lives in raw['time'] the same way Message.time does.
    final starts = parts
        .map((p) => asInt(asMap(p.raw['time'])['start']))
        .where((v) => v > 0)
        .toList();
    final ends = parts
        .map((p) => asInt(asMap(p.raw['time'])['end']))
        .where((v) => v > 0)
        .toList();
    final start = starts.isEmpty ? 0 : starts.reduce((a, b) => a < b ? a : b);
    final end = ends.isEmpty ? 0 : ends.reduce((a, b) => a > b ? a : b);
    final secs = start > 0 && end > start ? (end - start) / 1000 : 0;

    if (text.trim().isEmpty) return const SizedBox.shrink();

    return _Collapsible(
      compact: true,
      icon: Icons.psychology_alt_outlined,
      title: S.partsThinking,
      // Duration, not the first sentence: the first line of a reasoning block
      // is usually "We need to look at…" and read as noise in a collapsed row.
      subtitle: secs > 0.4 ? S.partsThoughtFor(secs.round()) : S.partsThinking,
      color: t.mute,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OCSpace.md,
          OCSpace.md,
          OCSpace.md,
          OCSpace.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              text,
              style: OCTypography.caption.copyWith(height: 1.5, color: t.mute),
            ),
            const SizedBox(height: OCSpace.sm),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  copyToClipboard(context, text);
                  showSnack(context, S.copied);
                },
                borderRadius: BorderRadius.circular(OCRadius.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OCSpace.sm,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LIcon(LI.copy, size: 12, color: t.mute),
                      const SizedBox(width: 4),
                      Text(
                        S.copy,
                        style: OCTypography.micro.copyWith(color: t.mute),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
