part of '../prompts.dart';

/// The one place a pending prompt is drawn. Mounted as a `Positioned.fill`
/// layer above the whole stack, so an approval survives a tab switch, a pushed
/// route (Files, Terminal, Settings), a drawer and a dialog.
///
/// Every entry point funnels here — the sheet auto-arms when a request arrives,
/// and the header badge, the drawer row and the working-strip chip all call
/// [showPendingPrompt]. One renderer means one prompt on screen and one place
/// where "answered" is decided.
class PromptOverlay extends StatelessWidget {
  const PromptOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Must *subscribe*, not just look up: this layer lives outside any screen,
    // so nothing above it rebuilds when a request arrives and a non-subscribing
    // read would leave the overlay frozen on its first (empty) frame.
    final store = AppScope.of(context);
    if (store.promptSheetDismissed) return const SizedBox.shrink();
    // One queue, oldest arrival first, whichever kind it is: a question asked
    // before a burst of tool permissions must not sit behind them.
    final next = store.oldestPendingPrompt;
    if (next == null) return const SizedBox.shrink();
    final p = next.permission;
    final q = next.question;
    if (p != null && BuddyController.instance.pending?.id == p.id) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      ignoring: false,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: SafeArea(
          child: Stack(
            children: [
              // Tapping the scrim closes the sheet but answers nothing: the
              // request is still pending on the server, so the badge stays up
              // and the agent stays correctly reported as blocked.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: store.dismissPromptSheet,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: p != null ? _PermissionCard(p) : _QuestionCard(q!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the pending prompt sheet from anywhere. Safe to call when nothing is
/// pending: it simply does nothing, so a stale button cannot open a blank card.
void showPendingPrompt(BuildContext context) {
  final scope = context.getInheritedWidgetOfExactType<AppScope>();
  if (scope == null) return;
  scope.notifier!.openPromptSheet();
}

/// The exact command about to run, collapsed to a few lines with a way to see
/// all of it.
///
/// Approving a command you cannot read is approving nothing, but a `git` or
/// `find` one-liner easily runs past three lines on a phone. So the box is
/// capped by default and the toggle sits directly under the text it belongs to
/// rather than in the card header, where it would read as chrome. A short
/// single-line command is never collapsed — there is nothing to expand, and a
/// button that does nothing is worse than no button.
class _CommandBox extends StatefulWidget {
  const _CommandBox(this.command);
  final String command;

  @override
  State<_CommandBox> createState() => _CommandBoxState();
}

class _CommandBoxState extends State<_CommandBox> {
  bool _open = false;

  bool get _collapsible =>
      widget.command.contains('\n') || widget.command.length > 110;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final collapsible = _collapsible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: OCSpace.md),
        Text(
          S.permFieldCommand.toUpperCase(),
          style: OCTypography.micro.copyWith(
            color: OCColors.textTertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(OCSpace.sm),
          decoration: BoxDecoration(
            color: OCColors.surfaceLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: OCColors.border),
          ),
          child: SelectableText(
            widget.command,
            maxLines: collapsible && !_open ? 3 : null,
            style: OCTypography.mono(size: 11.5),
          ),
        ),
        if (collapsible)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.xxs),
            child: TextButton(
              onPressed: () => setState(() => _open = !_open),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: OCSpace.xs),
                foregroundColor: t.acc,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _open
                        ? S.permCommandShowLess
                        : S.permCommandShowAll,
                    style: OCTypography.micro.copyWith(
                      color: t.acc,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: t.acc,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Tool, exact command, directories and patterns for the request on screen.
///
/// Split out of the card because these four are what the user is actually
/// approving. The generic `detail` dump above is a cross-section of every
/// metadata key the server happens to send; this is the short, named list that
/// answers "what am I about to let through, and how wide is it".
class _PermissionFacts extends StatelessWidget {
  const _PermissionFacts(this.p);
  final PermissionReq p;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final rows = <(String, String)>[
      if (p.tool.isNotEmpty) (S.permFieldTool, p.tool),
      if (p.directories.isNotEmpty) (
        S.permFieldDirectories,
        p.directories.join('\n'),
      ),
      if (p.patterns.isNotEmpty) (S.permFieldPatterns, p.patterns.join('\n')),
    ];
    if (rows.isEmpty && p.command.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The command gets its own box rather than one more row in the dump
        // below: it is the thing being approved, and it is the only field long
        // enough to need collapsing.
        if (p.command.isNotEmpty) _CommandBox(p.command),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: OCSpace.md),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(OCSpace.md),
            decoration: BoxDecoration(
              color: OCColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (label, value) in rows) ...[
                    Text(
                      label.toUpperCase(),
                      style: OCTypography.micro.copyWith(
                        color: OCColors.textTertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SelectableText(value, style: OCTypography.mono(size: 11.5)),
                    const SizedBox(height: OCSpace.xs),
                  ],
                ],
              ),
            ),
          ),
        ],
        // Broad grants get said out loud, next to the button that makes them.
        if (p.isBroadPattern)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: t.warn,
                ),
                const SizedBox(width: OCSpace.xxs),
                Expanded(
                  child: Text(
                    S.permAlwaysWarning,
                    style: OCTypography.micro.copyWith(color: t.warn),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final PermissionReq p;
  const _PermissionCard(this.p);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return OCCard(
      padding: const EdgeInsets.all(OCSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const OCIconTile(
                icon: Icons.shield_outlined,
                accent: OCAccent.purple,
                size: 36,
                iconSize: 20,
              ),
              const SizedBox(width: OCSpace.md),
              Expanded(
                child: Text(
                  S.permTitle,
                  style: OCTypography.h2.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          Text(S.permWhatDoing, style: OCTypography.caption),
          _SessionLine(sessionId: p.sessionId),
          // The raw metadata dump is gone: it repeated the patterns verbatim and
          // led with whatever key the server happened to emit first, which is
          // the opposite of what "what am I approving" needs.
          if (p.always.isNotEmpty) ...[
            const SizedBox(height: OCSpace.md),
            Text(S.permSuggestingRules(p.always), style: OCTypography.micro),
          ],
          _PermissionFacts(p),
          const SizedBox(height: OCSpace.lg),
          // Stacked, not a row of three. Across 360dp each button had ~100dp to
          // hold "Always Allow in Session", so the labels wrapped or clipped and
          // the two irreversible choices looked identical in weight to the
          // common one. Stacked, each label is on one line at full size, and the
          // destructive choice sits last where a thumb is not already heading.
          OCButton(
            label: S.permSheetAllow,
            variant: OCButtonVariant.primaryBlack,
            onPressed: () => store.answerPermission(p, 'once'),
          ),
          const SizedBox(height: OCSpace.xs),
          OCButton(
            label: S.permSheetAlways,
            variant: OCButtonVariant.secondaryPill,
            onPressed: () => store.answerPermission(p, 'always'),
          ),
          const SizedBox(height: OCSpace.xs),
          OCButton(
            label: S.permSheetDeny,
            variant: OCButtonVariant.ghostOutline,
            onPressed: () => store.answerPermission(p, 'reject'),
          ),
          const SizedBox(height: OCSpace.sm),
          if (store.permissions.length > 1)
            Center(
              child: Text(
                S.permMorePending(store.permissions.length - 1),
                style: OCTypography.micro,
              ),
            ),
        ],
      ),
    );
  }
}
