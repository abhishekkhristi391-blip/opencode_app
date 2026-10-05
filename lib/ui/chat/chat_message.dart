part of '../chat.dart';

/// One tappable suggestion: 36dp icon tile, title, chevron.
///
/// Was a two-line card at a 16dp radius and ~76dp tall with no icon and no
/// press feedback, so four of them read as a stack of dialogs rather than a
/// set of shortcuts. One line, 12dp, 64dp tall.
class SuggestionCard extends StatefulWidget {
  const SuggestionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final LI icon;
  final String title;
  final VoidCallback onTap;

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final pressed = _down && !ocReduceMotion(context);
    return AnimatedScale(
      // 0.98, not the global 0.97: on a 64dp row that is a 1.3dp edge shift and
      // the card looks like it is resizing rather than being pressed.
      scale: pressed ? OCMotion.pressScaleSoft : 1,
      duration: OCMotion.micro,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: OCMotion.micro,
        decoration: BoxDecoration(
          color: _down ? t.surfaceElevated : t.card,
          borderRadius: BorderRadius.circular(OCRadius.suggestion),
          border: Border.all(
            color: _down ? t.acc.withValues(alpha: 0.4) : t.line,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(OCRadius.suggestion),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            onHighlightChanged: (v) => setState(() => _down = v),
            borderRadius: BorderRadius.circular(OCRadius.suggestion),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.bg,
                      borderRadius: BorderRadius.circular(OCRadius.md),
                    ),
                    child: LIcon(
                      widget.icon,
                      size: 18,
                      color: t.mute,
                      strokeWidth: 1.9,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.h3.copyWith(
                        color: t.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: OCSpace.sm),
                  LIcon(
                    LI.chevronRight,
                    size: 16,
                    color: t.mute,
                    strokeWidth: 2,
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

// ---------------------------------------------------------------------
// message bubble
// ---------------------------------------------------------------------

class _MessageTile extends StatefulWidget {
  final ChatMessage msg;
  final bool isLastReply;
  final bool showTokens;
  const _MessageTile({
    super.key,
    required this.msg,
    required this.isLastReply,
    required this.showTokens,
  });

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile> {
  // FIX: every store update used to re-parse the markdown of EVERY message.
  // Now a tile only rebuilds when its own message actually changed.
  Widget? _cache;
  int _sig = 0;

  /// The error text the user closed on this turn. Held here rather than in the
  /// store because clearing is a view decision — the message is still failed,
  /// the user just does not want to read about it again. Part of [_signature]
  /// so closing actually repaints the cached tile.
  String? _dismissedError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cache = null; // theme / screen size changed
  }

  int _signature() {
    final m = widget.msg;
    return Object.hash(
      identityHashCode(m.info),
      m.parts.length,
      Object.hashAll(m.parts.map(identityHashCode)),
      m.errorText,
      widget.isLastReply,
      widget.showTokens,
      _dismissedError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sig = _signature();
    if (_cache == null || sig != _sig) {
      _sig = sig;
      _cache = RepaintBoundary(child: _buildContent(context));
    }
    return _cache!;
  }

  Future<void> _openMenu() async {
    await showMessageMenu(context, widget.msg);
  }

  Widget _buildContent(BuildContext context) {
    final t = context.oc;
    final m = widget.msg;
    final user = m.info.isUser;

    final text = m.parts
        .where((p) => p.type == 'text')
        .map((p) => p.text)
        .join('\n')
        .trim();
    final files = m.parts.where((p) => p.type == 'file').toList();
    final others = m.parts
        .where(
          (p) =>
              p.type != 'text' &&
              p.type != 'file' &&
              p.type != 'step-start' &&
              p.type != 'step-finish',
        )
        .toList();

    // OcStore._upsertMessage swaps an optimistic user message for the
    // server's echo with an *empty* part list, then fills in the parts when
    // their events land. Rendering the bubble during that window is what put
    // a stray empty black pill in the transcript, so a row with nothing to
    // show collapses to nothing.
    final hasContent =
        text.isNotEmpty ||
        files.isNotEmpty ||
        others.isNotEmpty ||
        m.errorText != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            // Long press stays as the full menu; the inline row carries the two
            // actions that are actually used, so they are not hidden behind a
            // gesture nobody discovers.
            onLongPress: _openMenu,
            borderRadius: BorderRadius.circular(12),
            child: user
                ? _userBubble(context, t, text, files, hasContent)
                : _assistantBlock(context, t, text, others, m, hasContent),
          ),
          // Only the user's own bubble gets this row. The assistant's actions
          // live inside [_assistantBlock], one row per reply; rendering this one
          // for an assistant message too is what put a copy + ⋮ row directly
          // under the copy / read-aloud / undo row and made the two rows look
          // like they belonged to different messages.
          if (user && hasContent)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _MessageActions(msg: m, text: text),
            ),
        ],
      ),
    );
  }

  Widget _userBubble(
    BuildContext context,
    OCTokens t,
    String text,
    List<Part> files,
    bool hasContent,
  ) {
    if (!hasContent) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Container(
          // The reference's `p-space-md`.
          padding: const EdgeInsets.all(OCSpace.md),
          decoration: BoxDecoration(
            // `bg-surface-container-highest text-on-surface`, not an inverted
            // ink fill: on this canvas a white bubble was the brightest thing
            // on screen and outranked the assistant's own prose.
            color: OCColors.surfaceHighest,
            // Reference: 22px radii with a 6px tail on the bottom right.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final f in files) _IncomingFileChip(f),
              if (text.isNotEmpty)
                Markdown(
                  text,
                  // user-body stays Inter; only the fill changed.
                  base: OCTypography.body.copyWith(color: t.ink),
                  onLink: (url) => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assistantBlock(
    BuildContext context,
    OCTokens t,
    String text,
    List<Part> others,
    ChatMessage m,
    bool hasContent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (others.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ToolTimeline(parts: others),
          ),
        if (text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Markdown(
              text,
              // assistantBody, not body: the reference sets the assistant's
              // prose in Source Serif 4 and the user's in Inter.
              base: OCTypography.assistantBody.copyWith(color: t.ink),
              onLink: (url) => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        if (m.streaming && !hasContent) const _TypingDots(),
        // Only the newest reply can carry an error, and that is what clears it
        // for free: the moment the user sends again this stops being the newest
        // reply, so a stale failure does not sit in the transcript for the rest
        // of the session. Closed by hand otherwise.
        if (m.displayError != null &&
            widget.isLastReply &&
            _dismissedError != m.displayError)
          _InlineError(
            m.displayError!,
            onDismiss: () => setState(() => _dismissedError = m.displayError),
          ),
        if (m.displayError == null && !m.streaming && m.info.tokens.total > 0)
          _ReplyMeta(msg: m, visible: widget.showTokens),
        // Every finished reply gets the same row. The row used to belong to the
        // newest reply only, which meant scrolling up found a reply with no way
        // to copy or undo it without a long press nobody discovers.
        if (!m.streaming && m.displayError == null && hasContent)
          _ReplyActions(msg: m),
      ],
    );
  }
}
