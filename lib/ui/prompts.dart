import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import 'app_scope.dart';
import 'line_icons.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

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

class _QuestionCard extends StatefulWidget {
  final QuestionReq q;
  const _QuestionCard(this.q);

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late Map<int, Set<String>> picks = {
    for (var i = 0; i < widget.q.questions.length; i++) i: <String>{},
  };
  final custom = <int, TextEditingController>{};

  @override
  void dispose() {
    for (final c in custom.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggle(int qi, String label, bool multiple) {
    setState(() {
      final s = picks.putIfAbsent(qi, () => <String>{});
      if (!multiple) {
        s
          ..clear()
          ..add(label);
      } else if (s.contains(label)) {
        s.remove(label);
      } else {
        s.add(label);
      }
    });
  }

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
                icon: Icons.help_outline,
                accent: OCAccent.orange,
                size: 36,
                iconSize: 20,
              ),
              const SizedBox(width: OCSpace.md),
              const Expanded(
                child: Text(
                  S.questionTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OCColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          _SessionLine(sessionId: widget.q.sessionId),
          const SizedBox(height: OCSpace.md),
          for (var i = 0; i < widget.q.questions.length; i++) ...[
            if (i > 0) const Divider(height: OCSpace.xxl),
            _question(context, widget.q.questions[i], i),
          ],
          const SizedBox(height: OCSpace.lg),
          Row(
            children: [
              Expanded(
                child: OCButton(
                  label: S.skipQ,
                  variant: OCButtonVariant.ghostOutline,
                  onPressed: () => store.rejectQuestion(widget.q),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                flex: 2,
                child: OCButton(
                  label: S.permSend,
                  variant: OCButtonVariant.primaryBlack,
                  onPressed: () {
                    final answers = <List<String>>[];
                    for (var i = 0; i < widget.q.questions.length; i++) {
                      final s = picks[i] ?? <String>{};
                      // Unconditional, matching the unconditional field below:
                      // the box is on every question, so a typed answer must
                      // always be sent or the sheet would silently discard it.
                      final t = custom[i]?.text.trim();
                      if (t != null && t.isNotEmpty) s.add(t);
                      answers.add(s.toList());
                    }
                    store.answerQuestion(widget.q, answers);
                  },
                ),
              ),
            ],
          ),
          if (store.questions.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: OCSpace.sm),
              child: Center(
                child: Text(
                  S.permMorePending(store.questions.length - 1),
                  style: OCTypography.micro,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _question(BuildContext context, QuestionItem item, int qi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.header.isNotEmpty)
          Text(
            item.header.toUpperCase(),
            style: OCTypography.micro.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        const SizedBox(height: OCSpace.xs),
        Text(
          item.question,
          style: OCTypography.body.copyWith(color: OCColors.textPrimary),
        ),
        if (item.multiple)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.xxs),
            child: Text(S.questionMultiHint, style: OCTypography.micro),
          ),
        const SizedBox(height: OCSpace.sm),
        for (final o in item.options)
          InkWell(
            onTap: () => _toggle(qi, o.label, item.multiple),
            child: Container(
              margin: const EdgeInsets.only(bottom: OCSpace.xs),
              // 48dp: these are the primary targets of the whole sheet, and a
              // four-option question with descriptions is otherwise easy to
              // mis-tap in a hurry.
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(
                horizontal: OCSpace.sm,
                vertical: OCSpace.sm,
              ),
              decoration: BoxDecoration(
                color: (picks[qi] ?? const {}).contains(o.label)
                    ? OCColors.orangeTint
                    : OCColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(OCRadius.inner),
                border: Border.all(
                  color: (picks[qi] ?? const {}).contains(o.label)
                      ? OCColors.orange
                      : Colors.transparent,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      item.multiple
                          ? ((picks[qi] ?? const {}).contains(o.label)
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded)
                          : ((picks[qi] ?? const {}).contains(o.label)
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded),
                      size: 20,
                      color: (picks[qi] ?? const {}).contains(o.label)
                          ? OCColors.orange
                          : OCColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: OCSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.label,
                          style: OCTypography.caption.copyWith(
                            color: OCColors.textPrimary,
                          ),
                        ),
                        if (o.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: OCSpace.xxs),
                            child: Text(
                              o.description,
                              style: OCTypography.micro,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Every question gets the free-text card, not only the ones the server
        // flagged `custom`. The flag describes what the *tool* suggested, not
        // what the human may type, and a question with no free-text box is a
        // question you cannot answer with your own words.
        Padding(
          padding: const EdgeInsets.only(top: OCSpace.sm),
          child: TextField(
            controller: custom.putIfAbsent(qi, TextEditingController.new),
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: S.questionCustomHint,
              hintStyle: OCTypography.caption,
              isDense: true,
              filled: true,
              fillColor: OCColors.surfaceSubtle,
              prefixIcon: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: OCColors.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(OCRadius.inner),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(OCRadius.inner),
                borderSide: BorderSide.none,
              ),
            ),
            style: OCTypography.caption.copyWith(color: OCColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Names the chat a request came from when it is not the one on screen.
///
/// A permission raised by a subagent, or by a second chat running in the TUI,
/// is still something the user must answer — but answering it while looking at
/// an unrelated transcript is confusing without this line. Answering does *not*
/// switch sessions: the request is addressed by its own id, so the reply lands
/// wherever it belongs.
class _SessionLine extends StatelessWidget {
  const _SessionLine({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (sessionId.isEmpty) return const SizedBox.shrink();
    final foreign = store.current?.id != sessionId;
    final label = store.sessionLabel(sessionId);
    return Padding(
      padding: const EdgeInsets.only(top: OCSpace.xs),
      child: Row(
        children: [
          LIcon(
            foreign ? LI.chat : LI.history,
            size: 13,
            color: OCColors.textTertiary,
          ),
          const SizedBox(width: OCSpace.xxs),
          Expanded(
            child: Text(
              foreign ? S.promptOtherSession(label) : S.promptInSession(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OCTypography.micro,
            ),
          ),
          // Dismissing is always available and always safe: the request stays
          // pending and the badge keeps it visible.
          TextButton(
            onPressed: store.dismissPromptSheet,
            style: TextButton.styleFrom(
              // 48dp tall: same rule as the option cards — a sheet you have to
              // aim at is a sheet people miss.
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
              foregroundColor: OCColors.textSecondary,
              shape: const CircleBorder(),
            ),
            child: Text(S.promptLater, style: OCTypography.micro),
          ),
        ],
      ),
    );
  }
}

/// Small "copy" affordance used by the share card.
class ShareCard extends StatelessWidget {
  final String url;
  const ShareCard({super.key, required this.url});

  @override
  Widget build(BuildContext context) => OCCard(
    padding: EdgeInsets.zero,
    child: ListTile(
      leading: const OCIconTile(
        icon: Icons.link,
        accent: OCAccent.blue,
        size: 36,
      ),
      title: Text(S.shareLinkTitle, style: OCTypography.h3.copyWith(fontSize: 15)),
      subtitle: Text(
        url,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: OCTypography.mono(size: 11.5, color: OCColors.textSecondary),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, color: OCColors.textSecondary),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url));
          showSnack(context, S.linkCopied);
        },
      ),
    ),
  );
}
