part of '../chat.dart';

/// Empty chat: headline, model/mode chips, workspace bar, then the four
/// suggestion cards anchored to the bottom of the screen.
///
/// Tapping a card sends it immediately.
class _Welcome extends StatelessWidget {
  final OcStore store;
  final void Function(String) onPick;
  const _Welcome(this.store, {required this.onPick});

  /// Title + icon per card. The old second line was a subtitle on every card;
  /// one of them ("And explain any failures") restated the title above it.
  static const _suggestions = <(LI, String)>[
    (LI.folder, S.chatSuggestionStructure),
    (LI.done, S.chatSuggestionTests),
    (LI.search, S.chatSuggestionTodo),
    (LI.spark, S.chatSuggestionPlan),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    // With the keyboard up the cards no longer fit under the hero, and their
    // whole job is to be tapped. Hide them rather than let the list scroll and
    // leave a half-visible card under the keyboard.
    final showCards = MediaQuery.of(context).viewInsets.bottom <= 0;

    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          // Pin the content to the full viewport so the cards sit on the bottom
          // edge. The old top-aligned ListView left the dead gap at the BOTTOM
          // instead, which is what made the screen look unfinished.
          //
          // IntrinsicHeight is required, not decorative: a scroll view hands its
          // child an unbounded height, and a Column distributing free space
          // under unbounded constraints throws. IntrinsicHeight measures the
          // column first; ConstrainedBox then stretches it to the viewport.
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OCSpace.screenGutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: OCSpace.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          S.chatWelcomeTitle,
                          style: OCTypography.heroTitle.copyWith(color: t.ink),
                        ),
                        const SizedBox(height: OCSpace.sm),
                        Text(
                          S.chatWelcomeHint,
                          style: OCTypography.body.copyWith(color: t.mute),
                        ),
                        const SizedBox(height: OCSpace.md),
                        // Two outlined chips instead of one muted sentence that
                        // read "Model provider/id - agent build": the id wrapped
                        // on narrow screens and buried the useful word, "Model".
                        _ModelModeChips(store: store),
                      ],
                    ),
                  ),
                  if (showCards)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: OCSpace.lg),
                        _ProjectBar(store: store),
                        const SizedBox(height: OCSpace.md),
                        for (final (icon, title) in _suggestions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: OCSpace.sm),
                            child: SuggestionCard(
                              icon: icon,
                              title: title,
                              onTap: () => onPick(title),
                            ),
                          ),
                        const SizedBox(height: OCSpace.sm),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined Model / Mode chips. Both open the existing pickers, so the app
/// gains no new controls — only a reachable place to see the current pair.
class _ModelModeChips extends StatelessWidget {
  const _ModelModeChips({required this.store});
  final OcStore store;

  @override
  Widget build(BuildContext context) {
    final model = store.modelId.isEmpty ? S.chipPickModel : store.modelId;
    return Wrap(
      spacing: OCSpace.sm,
      runSpacing: OCSpace.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedChip(
          icon: LI.tune,
          label: '${S.chatChipModel}: $model',
          // No such thing as a decorative "Model:" prefix in the reference:
          // the chip reads "Opus 4.5", the sheet carries the label.
          badge: isFreeModel(store.modelId) ? S.badgeFree : null,
          tooltip: S.chatChipModel,
          onTap: () => showModelSheet(context, store),
        ),
        OutlinedChip(
          icon: LI.spark,
          label:
              '${S.chatChipMode}: ${store.agent.isEmpty ? S.chipAgent : store.agent}',
          tooltip: S.chatChipMode,
          onTap: () => showAgentSheet(context, store),
        ),
      ],
    );
  }
}

/// Neutral outlined chip used by the hero and the composer. Accent is reserved
/// for the primary action, so the model/mode chips use `line`, not `accInk`.
class OutlinedChip extends StatelessWidget {
  const OutlinedChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.tooltip,
    this.badge,
  });

  final String label;
  final VoidCallback onTap;
  final LI? icon;
  final String? tooltip;

  /// Small trailing tag, e.g. "Free". Lets the row stay 32dp instead of
  /// growing a second line.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final chip = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Material(
        color: t.card,
        borderRadius: BorderRadius.circular(OCRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.full),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OCRadius.full),
              border: Border.all(color: t.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  LIcon(icon!, size: 14, color: t.mute, strokeWidth: 1.9),
                  const SizedBox(width: 6),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: t.accSoft,
                      borderRadius: BorderRadius.circular(OCRadius.xs),
                      border: Border.all(color: t.accLine),
                    ),
                    child: Text(
                      badge!,
                      style: OCTypography.micro.copyWith(color: t.acc),
                    ),
                  ),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.meta.copyWith(
                      color: t.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                LIcon(LI.chevronDown, size: 14, color: t.mute, strokeWidth: 2),
              ],
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? chip : Tooltip(message: tooltip!, child: chip);
  }
}

/// Which folder and branch the server is working in.
///
/// The app has no API to change the server's working directory, so this opens
/// the workspace's actual values instead of a switcher that could only ever
/// have one option.
class _ProjectBar extends StatelessWidget {
  const _ProjectBar({required this.store});
  final OcStore store;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final dir = store.paths?.worktree.isNotEmpty == true
        ? store.paths!.worktree
        : (store.paths?.directory ?? '');
    final name = dir.isEmpty ? S.projectUnknown : baseName(dir);
    final branch = (store.vcs?.branch ?? '').isEmpty ? null : store.vcs!.branch;

    return Semantics(
      button: true,
      label: '${S.projectDetailsTitle}, $name',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(OCRadius.full),
        child: InkWell(
          onTap: () => _showDetails(context),
          borderRadius: BorderRadius.circular(OCRadius.full),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OCRadius.full),
              border: Border.all(color: t.line),
            ),
            child: Row(
              children: [
                LIcon(LI.folder, size: 15, color: t.mute, strokeWidth: 1.9),
                const SizedBox(width: OCSpace.sm),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.meta.copyWith(
                      color: t.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (branch != null) ...[
                  const SizedBox(width: OCSpace.sm),
                  Container(width: 1, height: 12, color: t.line),
                  const SizedBox(width: OCSpace.sm),
                  LIcon(LI.fork, size: 14, color: t.mute, strokeWidth: 1.9),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      branch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.meta.copyWith(color: t.mute),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDetails(BuildContext context) async {
    final p = store.paths;
    final v = store.vcs;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenGutter,
                0,
                OCSpace.screenGutter,
                OCSpace.sm,
              ),
              child: Text(
                S.projectDetailsTitle,
                style: OCTypography.bodyStrong.copyWith(
                  color: sheetCtx.oc.mute,
                ),
              ),
            ),
            InfoRow(
              S.projectDirectory,
              (p?.directory ?? '').isEmpty ? S.projectUnknown : p!.directory,
              mono: true,
            ),
            InfoRow(
              S.projectWorktree,
              (p?.worktree ?? '').isEmpty ? S.projectUnknown : p!.worktree,
              mono: true,
            ),
            InfoRow(
              S.projectBranch,
              (v?.branch ?? '').isEmpty ? S.projectNoBranch : v!.branch,
              mono: true,
            ),
            const SizedBox(height: OCSpace.sm),
          ],
        ),
      ),
    );
  }
}
