part of '../prompts.dart';

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
