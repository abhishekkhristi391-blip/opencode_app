part of '../chat.dart';

/// Reference `.send`: a 40px circle that is Stop while the agent runs, an
/// up-arrow while there is something to send, and the voice glyph otherwise.
class _SendButton extends StatelessWidget {
  final OcStore store;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStop;

  /// Whether the row has room for the optional dictation action beside the
  /// primary one. Width only — never text — so the row cannot change shape
  /// while a reply is streaming and shove the controls around.
  final bool micSlot;
  const _SendButton({
    required this.store,
    required this.controller,
    required this.onSend,
    required this.onStop,
    this.micSlot = false,
  });

  @override
  Widget build(BuildContext context) {
    // read(), not of(): the send slot subscribes below. Depending on
    // VoiceScope here would rebuild the whole slot on every level update, and
    // `of` on a parent would drag the composer with it.
    final voice = VoiceScope.read(context);
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          if (store.busy) {
            // Stop replaces Send in the same slot, so it keeps the same terracotta
            // container instead of flipping to a high-contrast disc mid-turn.
            return _CircleButton(
              icon: LI.stop,
              bg: OCColors.secondary,
              fg: OCColors.onSecondary,
              semanticLabel: S.chatStopTooltip,
              onTap: onStop,
              diameter: OCSpace.tapTarget,
              glyph: 22,
            );
          }
          final canSend =
              value.text.trim().isNotEmpty || store.attachments.isNotEmpty;
          if (canSend) {
            final send = _CircleButton(
              // The reference's `bg-secondary-container text-on-secondary-container`.
              icon: LI.send,
              bg: OCColors.secondary,
              fg: OCColors.onSecondary,
              semanticLabel: S.chatSendTooltip,
              onTap: onSend,
              diameter: OCSpace.tapTarget,
              glyph: 22,
            );
            // With text in the field the primary action is Send, so dictation has
            // nowhere to be except beside it. This is the optional second action:
            // it only exists when the row measured that it fits, and it never
            // replaces Send.
            if (!micSlot) return send;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dictation(context, voice),
                const SizedBox(width: _tapGap),
                send,
              ],
            );
          }
          // The reference puts a dictation button in this slot, and it is the
          // right place for it: it is where the send button would be, so it is
          // the one control a thumb already knows to reach for when it is empty.
          // While the microphone is open it turns into the stop for that session
          // rather than disappearing, so the way out is always in the same spot.
          if (voice.micActive) {
            return _CircleButton(
              icon: LI.mic,
              bg: OCColors.secondary,
              fg: OCColors.onSecondary,
              semanticLabel: S.voiceStopListeningTooltip,
              onTap: voice.stopDictation,
              diameter: OCSpace.tapTarget,
              glyph: 22,
            );
          }
          if (voice.recognizerMissing) {
            // No speech engine on the device. A dead button is worse than none,
            // and Settings > Voice is where this gets explained.
            return const SizedBox.shrink();
          }
          return _dictation(context, voice);
        },
      ),
    );
  }

  /// The mic control: stop while dictation is live, otherwise open it. Bare
  /// glyph, not a disc, because it shares the row with Send and a filled circle
  /// there would compete with it.
  Widget _dictation(BuildContext context, VoiceService voice) => _CircleButton(
    icon: LI.mic,
    bg: Colors.transparent,
    fg: voice.micActive ? OCColors.secondary : context.oc.mute,
    semanticLabel: voice.micActive
        ? S.voiceStopListeningTooltip
        : S.voiceMicTooltip,
    onTap: voice.micActive ? voice.stopDictation : voice.toggleDictation,
    diameter: OCSpace.tapTarget,
    glyph: 22,
  );
}

class _CircleButton extends StatelessWidget {
  final LI icon;
  final Color bg;
  final Color fg;
  final String semanticLabel;
  final VoidCallback onTap;

  /// Visible disc. Defaults to the 48dp minimum; the reference draws the small
  /// in-composer controls at 32-36 inside it.
  final double diameter;

  /// Glyph size, which the reference keeps at 18-20 regardless of the disc.
  final double glyph;
  const _CircleButton({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.semanticLabel,
    required this.onTap,
    this.diameter = 48,
    this.glyph = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          // 48dp hit area on every control: the visible disc may be 32 or 36,
          // but the target a thumb has to find never shrinks with it.
          child: SizedBox(
            width: OCSpace.tapTarget,
            height: OCSpace.tapTarget,
            child: Center(
              child: Container(
                width: diameter,
                height: diameter,
                alignment: Alignment.center,
                child: LIcon(icon, size: glyph, color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
