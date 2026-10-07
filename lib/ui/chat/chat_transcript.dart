part of '../chat.dart';

/// Rebuilds only when busy/busyStatus changes
class _BusyBarWidget extends StatelessWidget {
  const _BusyBarWidget();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        if (!store.busy) return const SizedBox.shrink();
        return _BusyBar(store.busyStatus);
      },
    );
  }
}

/// The transcript.
///
/// There is exactly one scrollable here and the parent owns its controller, so
/// follow-mode, the jump button and the loader cannot disagree. Anything that
/// needs to scroll (suggestion lists, sheets) lives in the composer or in a
/// modal route, never in the message list.
class _ChatMessages extends StatelessWidget {
  final ScrollController scroll;
  final bool showJump;
  final int unread;
  final bool Function(ScrollNotification) onNotification;
  final VoidCallback onJump;
  final Future<void> Function(OcStore) onLoadOlder;
  final void Function(String) onPickSuggestion;

  const _ChatMessages({
    required this.scroll,
    required this.showJump,
    required this.unread,
    required this.onNotification,
    required this.onJump,
    required this.onLoadOlder,
    required this.onPickSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    // Bound to the transcript's own signal, not to the whole store: a token now
    // repaints this list and nothing else in the app. `messageListenable` also
    // carries the app-wide notifications that change this list's own chrome
    // (loading state, `hasMoreMessages`, `showTokensInChat`), so a session
    // switch or a settings toggle still lands here.
    return ListenableBuilder(
      listenable: store.messageListenable,
      builder: (context, _) => _buildList(context, store),
    );
  }

  Widget _buildList(BuildContext context, OcStore store) {
    final messages = store.messages;

    if (store.messagesLoading && messages.isEmpty) {
      // A centred spinner for ~1s tells the user nothing about what is coming.
      // OCSkeletonList is the same shape as the list that replaces it, so the
      // page does not jump when the messages arrive.
      return const OCSkeletonList(rows: 6, semanticLabel: S.chatLoading);
    }
    if (messages.isEmpty) {
      return _Welcome(store, onPick: onPickSuggestion);
    }

    // The footer belongs to the last assistant reply only; older ones keep
    // their tokens hidden behind the store flag like everything else.
    var lastAssistantIndex = -1;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (!messages[i].info.isUser) {
        lastAssistantIndex = i;
        break;
      }
    }

    // One agent turn is many assistant messages (one per step: think, run a
    // command, think again...). Only the last one that shows anything carries
    // the action row and the token line, otherwise every step grows a 48dp row
    // and the transcript fills with buttons. A streaming message counts as
    // shown so the row does not hop back one message while a reply starts.
    final turnEnd = List<bool>.filled(messages.length, false);
    var turnClosed = false;
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.info.isUser) {
        turnClosed = false;
        continue;
      }
      if (!turnClosed && _showsSomething(m)) {
        turnEnd[i] = true;
        turnClosed = true;
      }
    }

    final hasOlder = store.hasMoreMessages;
    final leading = hasOlder ? 1 : 0;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: onNotification,
          // An explicit scrollbar, on the right, that only exists while the
          // transcript is actually taller than the viewport.
          //
          // Nothing in the app attached one before, so the bar a user reported
          // on the left edge was the platform's own scroll overlay — it draws
          // outside our layout, ignores the theme, and is bright enough to be
          // mistaken for UI. Owning it here means one thin muted thumb that
          // appears only when there is something to scroll and stays clear of
          // the left edge and the message text.
          child: Scrollbar(
            controller: scroll,
            // Not thumbVisibility:true. That keeps a full-height thumb on screen
            // even when four messages fit, which is the same "bar that means
            // nothing" problem as the one being fixed. Left false, the thumb can
            // only appear in response to a scroll or a drag — and a list that
            // does not overflow never produces either.
            thumbVisibility: false,
            trackVisibility: false,
            thickness: 3,
            radius: const Radius.circular(OCRadius.full),
            interactive: true,
            child: ListView.builder(
              controller: scroll,
              // Interactive Scrollbar insets its own 3dp, so the transcript
              // keeps the same gutter as the hero and the composer.
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenGutter,
                6,
                OCSpace.screenGutter,
                OCSpace.md,
              ),
              itemCount: messages.length + leading,
              cacheExtent: 600,
              itemBuilder: (_, i) {
                if (hasOlder && i == 0) {
                  return _LoadOlderButton(
                    onTap: () => onLoadOlder(store),
                    loading: store.messagesLoading,
                  );
                }
                final index = i - leading;
                final m = messages[index];
                return _MessageTile(
                  key: ValueKey(m.info.id),
                  msg: m,
                  isLastReply: index == lastAssistantIndex,
                  turnEnd: turnEnd[index],
                  showTokens: store.showTokensInChat,
                );
              },
            ),
          ),
        ),
        if (showJump)
          Positioned(
            right: OCSpace.screenGutter,
            bottom: OCSpace.md,
            child: _JumpToLatest(onTap: onJump, unread: unread),
          ),
      ],
    );
  }
}

/// Whether an assistant message renders anything at all: a streaming one (its
/// typing dots), an error, or any part other than the step bookkeeping.
bool _showsSomething(ChatMessage m) =>
    m.streaming ||
    m.displayError != null ||
    m.parts.any((p) => p.type != 'step-start' && p.type != 'step-finish');

/// Floating pill that appears once the reader scrolls away from the tail.
class _JumpToLatest extends StatelessWidget {
  final VoidCallback onTap;
  final int unread;
  const _JumpToLatest({required this.onTap, this.unread = 0});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      label: S.jumpToLatest,
      child: Material(
        color: t.card,
        borderRadius: BorderRadius.circular(999),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: t.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LIcon(LI.arrowDown, size: 16, color: t.mute, strokeWidth: 2.2),
                const SizedBox(width: 6),
                Text(
                  S.jumpToLatest,
                  style: OCTypography.micro.copyWith(
                    color: t.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: t.acc,
                      borderRadius: BorderRadius.circular(OCRadius.pill),
                    ),
                    child: Text(
                      '$unread',
                      style: OCTypography.micro.copyWith(
                        color: t.onAcc,
                        fontWeight: FontWeight.w700,
                      ),
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
}

// ---------------------------------------------------------------------

class _LoadOlderButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const _LoadOlderButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OCSpace.sm),
      child: Center(
        child: loading
            ? const OCProgressRing(value: 0.65, size: 22, stroke: 3)
            : OCButton(
                onPressed: onTap,
                icon: Icons.keyboard_arrow_up,
                label: S.chatLoadOlder,
                variant: OCButtonVariant.secondaryPill,
                expand: false,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
