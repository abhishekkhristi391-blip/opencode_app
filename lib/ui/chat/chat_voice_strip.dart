part of '../chat.dart';

/// The one sentence for a voice failure.
///
/// Shared by the composer strip and Settings > Voice so the two never word the
/// same stop differently. Raw platform codes never reach the user: the service
/// classifies them and this only picks the sentence.
String voiceFailureText(VoiceFailure failure) => switch (failure) {
      VoiceFailure.permission => S.voiceFailedPermission,
      VoiceFailure.recognizer => S.voiceFailedRecognizer,
      VoiceFailure.noSpeech => S.voiceFailedNoSpeech,
      VoiceFailure.network => S.voiceFailedNetwork,
      VoiceFailure.busy => S.voiceFailedBusy,
      VoiceFailure.language => S.voiceFailedLanguage,
      VoiceFailure.noModel => S.voiceFailedNoModel,
      VoiceFailure.playback => S.voiceFailedPlayback,
      VoiceFailure.autoSendOff => S.voiceFailedAutoSendOff,
      VoiceFailure.unknown => S.voiceFailedUnknown,
    };

/// The voice line under the field: what is happening, what was heard, how to stop.
///
/// Dictation and hands-free share it because they are the same microphone, and
/// two indicators would be two truths to reconcile.
///
/// It lives in the composer, below the transcript, and subscribes to the service
/// on its own. Nothing above it rebuilds when the microphone opens: the partial
/// text changes at a few frames a second during dictation, and routing that
/// through the composer would repaint every cached message tile with it.
class _VoiceStrip extends StatefulWidget {
  const _VoiceStrip();

  @override
  State<_VoiceStrip> createState() => _VoiceStripState();
}

class _VoiceStripState extends State<_VoiceStrip> {
  /// What has already been said out loud, so one failure is one message.
  VoiceFailure? _shownFailure;
  VoiceFailure? _shownNotice;

  /// Why hands-free or dictation stopped gets one snackbar, not a banner that
  /// has to be dismissed. Hands-free can end three different ways in a minute
  /// and a persistent bar would fight the composer for the same row.
  void _reportOnce(BuildContext context, VoiceService voice) {
    final failure = voice.failure;
    final notice = voice.notice;
    if (failure == _shownFailure && notice == _shownNotice) return;
    if (failure == null && notice == null) {
      // Cleared, not reported: forget it so the *next* identical failure is
      // still worth a message. Two mic failures in a row both have to be said.
      _shownFailure = null;
      _shownNotice = null;
      return;
    }
    _shownFailure = failure;
    _shownNotice = notice;
    final reason = notice ?? failure!;
    // After the frame: a snackbar raised during build throws.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showSnack(context, voiceFailureText(reason));
      voice.clearNotice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    // read(), not of(): the subscription is the ListenableBuilder directly
    // below. `of` would additionally make this widget's parent rebuild on every
    // level update during dictation.
    final voice = VoiceScope.read(context);
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) {
        _reportOnce(context, voice);
        if (!voice.micActive && !voice.isBusy) {
          return const SizedBox.shrink();
        }
        final listening = voice.isListening;
        final label = switch (voice.phase) {
          VoicePhase.requestingPermission => S.voiceStarting,
          VoicePhase.listening => S.voiceListening,
          VoicePhase.processing => S.voiceProcessing,
          VoicePhase.speaking => S.voiceSpeaking,
          VoicePhase.waiting => S.voiceWaiting,
          _ => S.voiceListening,
        };
        // The live partial lives here, not in the field: dictation only commits
        // the final sentence, and a field that rewrites itself mid-sentence
        // fights the caret.
        final text = listening && voice.partial.isNotEmpty
            ? voice.partial
            : label;
        return Padding(
          padding: const EdgeInsets.only(top: OCSpace.xs),
          child: Row(
            children: [
              _LevelDot(active: listening, level: voice.level),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.caption.copyWith(
                    color: listening ? t.ink : t.mute,
                  ),
                ),
              ),
              if (voice.isSpeaking && voice.spokenTotal > 1) ...[
                Text(
                  S.voiceUtterance(voice.spokenIndex, voice.spokenTotal),
                  style: OCTypography.caption.copyWith(color: t.mute),
                ),
                const SizedBox(width: OCSpace.sm),
              ],
              _ActionBtn(
                icon: LI.stop,
                label: voice.isSpeaking
                    ? S.voiceStopReadingTooltip
                    : S.voiceStopListeningTooltip,
                // Reading and listening are different ways out, and during a
                // hands-free turn this ends the whole loop.
                onTap: voice.isSpeaking
                    ? voice.stopSpeaking
                    : voice.stopDictation,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The 6dp dot that breathes while the microphone is open.
class _LevelDot extends StatefulWidget {
  final bool active;
  final double level;

  const _LevelDot({required this.active, required this.level});

  @override
  State<_LevelDot> createState() => _LevelDotState();
}

class _LevelDotState extends State<_LevelDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: OCMotion.pulse,
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final dot = (double alpha) => Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: t.acc.withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
        );
    if (!widget.active) return dot(0.35);
    // A blinking light is a flashing element. With animations off it is simply
    // on, which still says the microphone is open.
    if (ocReduceMotion(context)) return dot(1);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => dot(0.4 + 0.6 * _pulse.value),
    );
  }
}

/// The hands-free toggle.
///
/// A pill with a label rather than another bare glyph: switching it on starts
/// sending messages with no tap at all, which is a mode and should look like
/// one. It sits next to the model pill, never inside the send slot.
///
/// Owns its own subscription so the level feed from a listening session repaints
/// this pill and nothing else.
/// Hands-free conversation, as a glyph.
///
/// It was a pill with the word "Hands-free" next to the mic, and that word is
/// what made the row overflow: a fixed-width label competing with the model pill
/// for the same space on a 320dp phone. The glyph carries the state through
/// colour and the tooltip and semantics label carry the meaning, so the label
/// can be long without costing layout. No text in any orientation.
class _HandsFreeButton extends StatelessWidget {
  const _HandsFreeButton();

  @override
  Widget build(BuildContext context) {
    // read(), not of(): the button rebuilds from its own ListenableBuilder below,
    // and the composer must not inherit the voice change on its behalf.
    final voice = VoiceScope.read(context);
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => _button(context, voice),
    );
  }

  Widget _button(BuildContext context, VoiceService voice) {
    final t = context.oc;
    final on = voice.conversation;
    final label = on
        ? S.voiceStopConversationTooltip
        : S.voiceConversationTooltip;
    return Semantics(
      button: true,
      toggled: on,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: OCSpace.tapTarget,
          height: OCSpace.tapTarget,
          child: Material(
            // Terracotta fill only while the microphone is actually open, so the
            // one always-red control in the row means one thing.
            color: on ? t.acc : Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => toggleHandsFree(context, voice),
              customBorder: const CircleBorder(),
              child: Center(
                child: LIcon(
                  LI.mic,
                  size: 22,
                  strokeWidth: on ? 2.2 : 1.7,
                  color: on ? t.bg : t.mute,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turning hands-free on sends messages without a tap, so the first time it is
/// explained and confirmed rather than discovered afterwards.
///
/// Shared by the composer button and the sheet row, so both confirm identically.
Future<void> toggleHandsFree(BuildContext context, VoiceService voice) async {
  if (voice.conversation) {
    await voice.toggleConversation();
    return;
  }
  if (voice.needsIntro) {
    final ok = await confirmDialog(
      context,
      title: S.voiceConversationTooltip,
      message: S.voiceConversationIntro,
      confirm: S.voiceStart,
    );
    if (!ok) return;
    voice.ackIntro();
  }
  await voice.toggleConversation();
}

/// The same control as a sheet row, for the narrow layouts where the composer
/// row has no room for the glyph.
class _HandsFreeSheetRow extends StatelessWidget {
  const _HandsFreeSheetRow();

  @override
  Widget build(BuildContext context) {
    // `of`, not `read`: a sheet row is built once when the sheet opens, so it
    // has to reflect the live state rather than the state at build time.
    final voice = VoiceScope.of(context);
    final on = voice.conversation;
    return _SheetRow(
      icon: LI.mic,
      label: on ? S.voiceStopConversationTooltip : S.voiceConversationTooltip,
      onTap: () async {
        final nav = Navigator.of(context);
        await toggleHandsFree(context, voice);
        nav.pop();
      },
    );
  }
}
