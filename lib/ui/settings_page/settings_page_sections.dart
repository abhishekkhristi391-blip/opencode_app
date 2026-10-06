part of '../settings_page.dart';

/// One settings group: the reference's `bg-surface-container-low rounded-xl`
/// card holding a run of rows.
///
/// The page used to be one flat run of rows separated by full-width dividers,
/// which on a dark canvas gave no sense of which rows belonged together. The
/// card does that job with shape, and the dividers become inset row rules.
///
/// Rows keep their own 16dp gutter, so a row's label sits 16dp inside the card
/// edge. The reference's rows sit closer to theirs; the difference is a few dp
/// and it is left alone rather than editing the padding of `InfoRow` and
/// `ListTile`, which every other page shares.
class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
      child: Container(
        decoration: BoxDecoration(
          color: context.oc.card,
          // `rounded-xl`: one step tighter than a standard card so a column of
          // groups reads as stacked panels instead of one continuous wall.
          borderRadius: BorderRadius.circular(12),
          // The reference's `shadow-sm`.
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        // Clipped so a row rule at the top or bottom stops at the card's radius.
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Row rule inside a [_Group], inset so it stops short of the row labels.
class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: OCSpace.screenX);
  }
}

class _Providers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final info = store.providerInfo;
    if (info == null) return const LoadingView();

    final connected = info.all
        .where((p) => info.connected.contains(p.id))
        .toList();
    final unconnected = info.all
        .where((p) => !info.connected.contains(p.id) && p.needsKey)
        .take(25)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (connected.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.screenX,
              0,
              OCSpace.screenX,
              OCSpace.sm,
            ),
            child: Text(S.noProviderConnected, style: OCTypography.caption),
          ),
        for (final p in connected)
          ListTile(
            dense: true,
            leading: const OCIconTile(
              icon: Icons.check_circle,
              accent: OCAccent.green,
              size: 30,
              iconSize: 16,
            ),
            title: Text(p.name, style: OCTypography.caption),
            subtitle: Text(
              S.modelsCount(p.models.length),
              style: OCTypography.micro,
            ),
            trailing: TextButton(
              onPressed: () async {
                await store.api.removeAuth(p.id);
                await store.refreshCatalog();
                if (context.mounted) showSnack(context, '${p.id} logout');
              },
              child: const Text(S.logout, style: TextStyle(fontSize: 12)),
            ),
          ),
        if (unconnected.isNotEmpty) const SectionTitle(S.providersNeedsKey),
        for (final p in unconnected)
          ListTile(
            dense: true,
            leading: const OCIconTile(
              icon: Icons.cloud_off_outlined,
              accent: OCAccent.neutral,
              size: 30,
              iconSize: 16,
            ),
            title: Text(p.name, style: OCTypography.caption),
            subtitle: Text(p.env.join(', '), style: OCTypography.micro),
            trailing: TextButton(
              onPressed: () => _addKey(context, p),
              child: const Text('Key', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Future<void> _addKey(BuildContext context, ProviderEntry p) async {
    final store = AppScope.read(context);
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${p.name} API key'),
        content: TextField(
          controller: c,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            hintText: p.env.isEmpty ? 'sk-...' : p.env.first,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancel),
          ),
          OCButton(
            label: S.save,
            variant: OCButtonVariant.primaryBlack,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok != true || c.text.trim().isEmpty) return;
    try {
      await store.api.setApiKey(p.id, c.text.trim());
      await store.refreshCatalog();
      if (context.mounted) showSnack(context, '${p.name} connected');
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
    }
  }
}

class _ConfigEditor extends StatefulWidget {
  final Map<String, dynamic> config;
  const _ConfigEditor({required this.config});

  @override
  State<_ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends State<_ConfigEditor> {
  late final TextEditingController c = TextEditingController(
    text: _pretty(widget.config),
  );

  static String _pretty(Map<String, dynamic> j) {
    try {
      return const JsonEncoder.withIndent('  ').convert(j);
    } catch (e) {
      if (kDebugMode) debugPrint('JSON encode failed: $e');
      return j.toString();
    }
  }

  @override
  void didUpdateWidget(covariant _ConfigEditor old) {
    super.didUpdateWidget(old);
    if (old.config != widget.config) c.text = _pretty(widget.config);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 240,
            padding: const EdgeInsets.all(OCSpace.md),
            decoration: BoxDecoration(
              color: OCColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(OCRadius.inner),
            ),
            child: TextField(
              controller: c,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: OCTypography.mono(size: 11.5),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: OCSpace.sm),
          OCButton(
            onPressed: () async {
              dynamic parsed;
              try {
                parsed = jsonDecode(c.text);
              } catch (e) {
                showSnack(context, S.configInvalidJsonError(e), error: true);
                return;
              }
              if (parsed is! Map<String, dynamic>) {
                showSnack(context, S.configNotRootObject, error: true);
                return;
              }
              await AppScope.read(context).saveConfig(parsed);
            },
            icon: Icons.save_outlined,
            label: S.setSaveConfig,
            variant: OCButtonVariant.primaryBlack,
          ),
          const SizedBox(height: OCSpace.sm),
          Text(S.patchConfigNote, style: OCTypography.micro),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final NamedStatus s;
  const _StatusRow(this.s);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: OCIconTile(
        icon: s.healthy ? Icons.check_circle : Icons.error_outline,
        accent: s.healthy ? OCAccent.green : OCAccent.neutral,
        size: 30,
        iconSize: 16,
      ),
      title: Text(s.name.isEmpty ? s.id : s.name, style: OCTypography.caption),
      subtitle: Text(
        [s.status, s.message, s.detail].where((x) => x.isNotEmpty).join(' · '),
        style: OCTypography.micro,
      ),
    );
  }
}

/// Everything about voice in one place.
///
/// A single `ListenableBuilder` over the service rather than one per row: the
/// settings page is a long flat list and seven independent subscriptions to the
/// same notifier is how a row ends up showing a stale value next to a fresh one.
class _VoiceSettings extends StatelessWidget {
  const _VoiceSettings();

  @override
  Widget build(BuildContext context) {
    final voice = VoiceScope.of(context);
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) => _Group(
        children: [
          _VoiceLanguageTile(voice: voice),
          const _GroupDivider(),
          _VoiceRateTile(voice: voice),
          const _GroupDivider(),
          SwitchListTile(
            dense: true,
            title: Text(S.voiceReadAloud, style: OCTypography.caption),
            subtitle: Text(S.voiceReadAloudSub, style: OCTypography.micro),
            value: voice.readAloud,
            activeTrackColor: context.oc.acc,
            onChanged: voice.setReadAloud,
          ),
          const _GroupDivider(),
          // Hands-free cannot run without it, so the dependency is stated rather
          // than left to be discovered when the toggle refuses to turn on.
          SwitchListTile(
            dense: true,
            title: Text(S.voiceAutoSend, style: OCTypography.caption),
            subtitle: Text(S.voiceAutoSendSub, style: OCTypography.micro),
            value: voice.autoSend,
            activeTrackColor: context.oc.acc,
            onChanged: voice.setAutoSend,
          ),
          const _GroupDivider(),
          _VoiceMicTile(voice: voice),
          const _GroupDivider(),
          _VoiceEngineTile(voice: voice),
          const _GroupDivider(),
          _ActionTile(
            icon: Icons.volume_up_outlined,
            title: S.voiceTest,
            subtitle: S.voiceTestLine,
            onTap: () {
              voice.testVoice(S.voiceTestLine);
              showToast(context, S.voiceTest);
            },
          ),
        ],
      ),
    );
  }
}
