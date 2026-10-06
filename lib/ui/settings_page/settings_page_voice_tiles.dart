part of '../settings_page.dart';

/// Recognition language, listed from the device rather than hardcoded.
///
/// A language the engine cannot hear is worse than no list at all, so this asks
/// the recogniser what it actually supports and says so when it cannot answer.
class _VoiceLanguageTile extends StatefulWidget {
  final VoiceService voice;

  const _VoiceLanguageTile({required this.voice});

  @override
  State<_VoiceLanguageTile> createState() => _VoiceLanguageTileState();
}

class _VoiceLanguageTileState extends State<_VoiceLanguageTile> {
  List<VoiceLocale>? _locales;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final locales = await widget.voice.locales();
    if (!mounted) return;
    setState(() {
      _locales = locales;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final voice = widget.voice;
    final selected = voice.language;
    // Either the id we stored, or the human name the engine reports for it.
    final current = _locales?.where((l) => l.id == selected).firstOrNull;
    final label = selected.isEmpty
        ? S.voiceLanguageSystem
        : (current?.name ?? selected);
    final detail = _loading
        ? S.voiceLanguageSub
        : (_locales == null || _locales!.isEmpty
            ? S.voiceLanguageUnavailable
            : S.voiceLanguageSub);
    return ListTile(
      dense: true,
      leading: OCIconTile(
        icon: Icons.translate_outlined,
        accent: OCAccent.neutral,
        size: 32,
        iconSize: 18,
      ),
      title: Text(S.voiceLanguage, style: OCTypography.caption),
      subtitle: Text(detail, style: OCTypography.micro),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: OCTypography.micro.copyWith(
                color: context.oc.mute,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: OCColors.textTertiary,
          ),
        ],
      ),
      onTap: _loading ? null : () => _pick(voice),
    );
  }

  Future<void> _pick(VoiceService voice) async {
    final locales = _locales;
    if (locales == null || locales.isEmpty) {
      // Re-ask rather than showing an empty sheet: the engine may have been
      // installed or updated since the page opened.
      await _load();
      if (!mounted) return;
      showToast(context, S.voiceLanguageUnavailable);
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              dense: true,
              title: Text(
                S.voiceLanguageSystem,
                style: OCTypography.caption.copyWith(
                  color: sheetCtx.oc.acc,
                ),
              ),
              onTap: () => Navigator.pop(sheetCtx, ''),
            ),
            for (final locale in locales)
              ListTile(
                dense: true,
                title: Text(locale.name, style: OCTypography.caption),
                subtitle: Text(locale.id, style: OCTypography.micro),
                onTap: () => Navigator.pop(sheetCtx, locale.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await voice.setLanguage(picked);
  }
}

/// Speech rate as three named steps rather than a raw slider.
///
/// flutter_tts wants 0..1 and the useful range is narrow; a slider invites
/// picking a value that sounds identical to the one next to it.
class _VoiceRateTile extends StatelessWidget {
  final VoiceService voice;

  const _VoiceRateTile({required this.voice});

  static const double _slow = 0.35;
  static const double _normal = 0.5;
  static const double _fast = 0.75;

  @override
  Widget build(BuildContext context) {
    final rate = voice.rate;
    final current = (rate - _slow).abs() < 0.06
        ? 0
        : (rate - _fast).abs() < 0.08
            ? 2
            : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(OCSpace.md, OCSpace.sm, OCSpace.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OCIconTile(
                icon: Icons.speed_outlined,
                accent: OCAccent.neutral,
                size: 32,
                iconSize: 18,
              ),
              const SizedBox(width: OCSpace.md),
              Text(S.voiceRate, style: OCTypography.caption),
              const Spacer(),
              Text(
                switch (current) {
                  0 => S.voiceRateSlow,
                  2 => S.voiceRateFast,
                  _ => S.voiceRateNormal,
                },
                style: OCTypography.micro.copyWith(color: context.oc.mute),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.xs),
            child: Row(
              children: [
                for (final (index, step) in [
                  (_slow, S.voiceRateSlow),
                  (_normal, S.voiceRateNormal),
                  (_fast, S.voiceRateFast),
                ].indexed) ...[
                  Expanded(
                    child: _RateStep(
                      label: step.$2,
                      selected: current == index,
                      onTap: () => voice.setRate(step.$1),
                    ),
                  ),
                  if (index < 2) const SizedBox(width: OCSpace.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RateStep extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RateStep({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? t.accSoft : OCColors.surfaceHighest,
        borderRadius: BorderRadius.circular(OCRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.sm),
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OCRadius.sm),
              border: Border.all(color: selected ? t.acc : t.line),
            ),
            child: Text(
              label,
              style: OCTypography.micro.copyWith(
                color: selected ? t.acc : t.mute,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Microphone status, with the only route back once Android has stopped asking.
///
/// speech_to_text cannot re-prompt after a denial, so this row is the difference
/// between "voice is broken" and "voice needs one tap in Settings".
class _VoiceMicTile extends StatelessWidget {
  final VoiceService voice;

  const _VoiceMicTile({required this.voice});

  @override
  Widget build(BuildContext context) {
    final denied = voice.permissionDenied;
    final state = denied
        ? S.voiceMicDenied
        : voice.recognizerReady
            ? S.voiceMicGranted
            : S.voiceMicUnknown;
    return ListTile(
      dense: true,
      leading: OCIconTile(
        icon: denied ? Icons.mic_off_outlined : Icons.mic_outlined,
        accent: denied ? OCAccent.red : OCAccent.neutral,
        size: 32,
        iconSize: 18,
      ),
      title: Text(S.voiceMicPermission, style: OCTypography.caption),
      subtitle: Text(state, style: OCTypography.micro),
      trailing: denied
          ? Text(
              S.voiceOpenSettings,
              style: OCTypography.micro.copyWith(color: context.oc.acc),
            )
          : null,
      onTap: denied
          ? () async {
              final opened = await voice.openMicrophoneSettings();
              if (!context.mounted) return;
              if (!opened) showToast(context, S.voiceSettingsUnopened);
            }
          : () async {
              // Starting a short session is the only way to make Android ask
              // again, so that is what this does.
              await voice.toggleDictation();
              await voice.stopDictation();
            },
    );
  }
}

/// Whether a synthesiser answered at all.
///
/// Read aloud silently doing nothing is the most confusing voice failure there
/// is, so the row says outright when there is no engine.
class _VoiceEngineTile extends StatelessWidget {
  final VoiceService voice;

  const _VoiceEngineTile({required this.voice});

  @override
  Widget build(BuildContext context) {
    final ready = voice.speechAvailable;
    return ListTile(
      dense: true,
      leading: OCIconTile(
        icon: ready ? Icons.record_voice_over_outlined : Icons.volume_off_outlined,
        accent: ready ? OCAccent.green : OCAccent.red,
        size: 32,
        iconSize: 18,
      ),
      title: Text(S.voiceEngine, style: OCTypography.caption),
      subtitle: Text(
        ready ? S.voiceEngineReady : S.voiceEngineMissing,
        style: OCTypography.micro,
      ),
      trailing: voice.failure == VoiceFailure.playback
          ? Text(
              voiceFailureText(VoiceFailure.playback),
              style: OCTypography.micro.copyWith(color: context.oc.err),
            )
          : null,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool danger;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: OCIconTile(
      icon: icon,
      accent: danger ? OCAccent.red : OCAccent.neutral,
      size: 32,
      iconSize: 18,
    ),
    title: Text(
      title,
      style: OCTypography.caption.copyWith(
        color: danger ? OCColors.red : OCColors.textPrimary,
      ),
    ),
    subtitle: Text(subtitle, style: OCTypography.micro),
    trailing: const Icon(
      Icons.chevron_right,
      size: 18,
      color: OCColors.textTertiary,
    ),
    onTap: onTap,
  );
}
