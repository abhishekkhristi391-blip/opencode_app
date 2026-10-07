part of '../chat.dart';

/// Token / cost line under a finished reply. Hidden unless the settings toggle
/// is on, and reduced to the bare counts when it is.
class _ReplyMeta extends StatelessWidget {
  final ChatMessage msg;
  final bool visible;
  const _ReplyMeta({required this.msg, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final t = context.oc;
    final i = msg.info;
    final bits = <String>[
      if (i.tokens.total > 0) i.tokens.pretty,
      if (i.cost > 0) '\$${i.cost.toStringAsFixed(4)}',
    ];
    if (bits.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        bits.join(' · '),
        style: OCTypography.micro.copyWith(color: t.mute),
      ),
    );
  }
}

/// The assistant messages of the turn that ends at [msg]: everything since the
/// user's last message.
List<ChatMessage> _turnOf(OcStore store, ChatMessage msg) {
  final all = store.messages;
  final end = all.indexWhere((x) => x.info.id == msg.info.id);
  if (end < 0) return [msg];
  var start = end;
  while (start > 0 && !all[start - 1].info.isUser) {
    start--;
  }
  return all.sublist(start, end + 1);
}

/// The prose of a turn, step messages joined; tool and reasoning parts are not
/// text and stay out.
String _replyText(Iterable<ChatMessage> turn) => turn
    .expand((m) => m.parts.where((p) => p.type == 'text').map((p) => p.text))
    .where((s) => s.trim().isNotEmpty)
    .join('\n\n');

/// Copy, read aloud, revert, and the overflow menu: one row, under the last
/// message of every finished turn.
///
/// The overflow used to be a second row of its own under the newest reply only,
/// so the same message carried two action rows while older replies carried
/// none. It stays in the row rather than moving to a long press: the long press
/// still opens this same menu, it is just no longer the only way in.
class _ReplyActions extends StatelessWidget {
  final ChatMessage msg;
  const _ReplyActions({required this.msg});

  @override
  Widget build(BuildContext context) {
    // read(), not of(): these buttons don't need to rebuild on every update.
    final store = AppScope.read(context);
    final t = context.oc;

    return Padding(
      padding: const EdgeInsets.only(left: -8, top: 2),
      child: Row(
        children: [
          _ActionBtn(
            icon: LI.copy,
            label: S.copy,
            onTap: () =>
                copyToClipboard(context, _replyText(_turnOf(store, msg))),
          ),
          // Read aloud is the one reply action that has to repaint while it
          // runs, so it subscribes to the service on its own. The tile's cached
          // markdown subtree is not rebuilt by this: the builder is scoped to
          // the button, below the cached boundary.
          _ReadAloudAction(msg: msg),
          _ActionBtn(
            icon: LI.undo,
            label: S.messageUndo,
            // Undo the whole turn, not just its last step.
            onTap: () => store.revert(_turnOf(store, msg).first.info.id),
          ),
          const SizedBox(width: OCSpace.xxs),
          _ActionDot(
            tooltip: S.moreActions,
            icon: LI.more,
            color: t.faint,
            onTap: () => showMessageMenu(context, msg),
          ),
        ],
      ),
    );
  }
}

/// Reads one reply aloud, or stops whatever is being read.
///
/// Scoped to the button so a listening state change repaints 32dp instead of
/// the reply above it.
class _ReadAloudAction extends StatelessWidget {
  final ChatMessage msg;

  const _ReadAloudAction({required this.msg});

  @override
  Widget build(BuildContext context) {
    // read(), not of(): this sits inside a cached message tile. Subscribing with
    // `of` would invalidate that tile's markdown cache on every voice change,
    // which is exactly the streaming repaint this file is careful to avoid.
    final voice = VoiceScope.read(context);
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => _ActionBtn(
        // The stop square is what is being read right now, so the button turns
        // into the way out of it.
        icon: voice.isSpeaking ? LI.stop : LI.volume,
        label: voice.isSpeaking ? S.voiceStopReadingTooltip : S.voiceReadAloudTooltip,
        onTap: () {
          if (voice.isSpeaking) {
            voice.stopSpeaking();
            return;
          }
          final text = _replyText(_turnOf(AppScope.read(context), msg));
          if (text.trim().isEmpty) {
            showSnack(context, S.voiceNothingToRead);
            return;
          }
          voice.speak(text);
        },
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        // The reference draws the reply actions as bare 32dp circular hits
        // that tint on hover/press. The old pill-plus-caption put a text label
        // under every reply, which is a lot of chrome for two verbs.
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          // 48dp hit area even though the disc is 32.
          child: SizedBox(
            width: OCSpace.tapTarget,
            height: OCSpace.tapTarget,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: OCColors.surfaceElevated,
                ),
                child: LIcon(icon, size: 16, color: t.mute),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
