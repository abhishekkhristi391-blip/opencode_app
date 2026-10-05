import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';

import '../api/client.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import '../voice/voice_scope.dart';
import '../voice/voice_service.dart';
import 'app_scope.dart';
import 'chat.dart' show voiceFailureText;
import 'commands_page.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    AppScope.read(context).refreshConfig();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await store.refreshConfig();
        await store.refreshServerInfo();
        await store.refreshCatalog();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: OCSpace.xxxl),
        children: [
          // ---------------- server ----------------
          const SectionTitle(S.setServerLabel),
          _Group(
            children: [
            InfoRow(S.setUrlLabel, store.baseUrl, mono: true),
            InfoRow(
              S.setStatus,
              store.online
                  ? S.setConnectedWith +
                        (store.serverVersion.isEmpty ? '' : ' (${store.serverVersion})')
                  : S.setDisconnected,
            ),
            InfoRow(S.setProject, store.paths?.directory ?? '-', mono: true),
            InfoRow(S.setWorktree, store.paths?.worktree ?? '-', mono: true),
            InfoRow(S.setConfigDir, store.paths?.config ?? '-', mono: true),
            InfoRow(
              S.setGitBranch,
              store.vcs?.branch.isNotEmpty == true
                  ? store.vcs!.branch
                  : S.setNotARepo,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.sm,
                OCSpace.screenX,
                0,
              ),
              child: Wrap(
                spacing: OCSpace.sm,
                children: [
                  OCButton(
                    onPressed: () => _editServer(context, store),
                    icon: Icons.edit,
                    label: S.setChangeServer,
                    variant: OCButtonVariant.secondaryPill,
                    expand: false,
                  ),
                  OCButton(
                    onPressed: store.connect,
                    icon: Icons.refresh,
                    label: S.setReconnect,
                    variant: OCButtonVariant.secondaryPill,
                    expand: false,
                  ),
                ],
              ),
            ),
              _GroupDivider(),
            ],
          ),

          // ---------------- session actions ----------------
          const SectionTitle(S.setCurrentSession),
          _Group(
            children: [
            _ActionTile(
              icon: Icons.auto_awesome,
              title: S.setInitAgents,
              subtitle: S.setInitAgentsSub,
              onTap: store.initAgents,
            ),
            _ActionTile(
              icon: Icons.compress,
              title: S.setSummarize,
              subtitle: S.setSummarizeSub,
              onTap: store.summarize,
            ),
            _ActionTile(
              icon: Icons.undo,
              title: S.setRevertLast,
              subtitle: S.setRevertLastBody,
              onTap: () async {
                final id = store.current?.id;
                if (id == null || store.messages.isEmpty) {
                  showSnack(context, S.noMessagesYet);
                  return;
                }
                await store.revert(store.messages.last.info.id);
              },
            ),
            _ActionTile(
              icon: Icons.redo,
              title: S.setUnrevert,
              subtitle: S.setRevertAllBodyShort,
              onTap: store.unrevert,
            ),
            _ActionTile(
              icon: Icons.refresh,
              title: S.setInstanceRestart,
              subtitle: S.setUpgradeBody,
              danger: true,
              onTap: () async {
                final ok = await confirmDialog(
                  context,
                  title: S.setInstanceRestartTitle,
                  message: S.setUpgradeConfirmBody,
                  confirm: S.setRestart,
                );
                if (!ok) return;
                try {
                  await store.api.disposeInstance();
                  await store.connect();
                  if (context.mounted) showSnack(context, S.instanceRestarted);
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
            _ActionTile(
              icon: Icons.system_update,
              title: S.setUpgradeCmd,
              subtitle: S.setUpgradeSub,
              danger: true,
              onTap: () async {
                final ok = await confirmDialog(
                  context,
                  title: S.setUpgradeTitle,
                  message: S.setUpgradeBody2,
                  confirm: S.setUpgrade,
                );
                if (!ok) return;
                try {
                  await store.api.upgrade();
                  await store.connect();
                  if (context.mounted) showSnack(context, S.setUpgradeDone);
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
            _ActionTile(
              icon: Icons.folder_open,
              title: S.setExternalFolder,
              subtitle: S.setExternalFolderSub,
              onTap: () async {
                final ok = await confirmDialog(
                  context,
                  title: S.setPermExternalTitle(store.paths?.directory ?? ''),
                  message: S.setPermExternalNote,
                  confirm: S.permAllow,
                );
                if (!ok) return;
                try {
                  await store.api.patchConfig({
                    'permission': {
                      'edit': 'allow',
                      'bash': 'allow',
                      'external_directory': 'allow',
                    },
                  });
                  await store.refreshConfig();
                  if (context.mounted) showSnack(context, S.externalPermGranted);
                } catch (e) {
                  if (context.mounted) showSnack(context, '$e', error: true);
                }
              },
            ),
              _GroupDivider(),
            ],
          ),

          // ---------------- chat display ----------------
          const SectionTitle(S.setChat),
          _Group(
            children: [
            SwitchListTile(
              dense: true,
              title: Text(S.setShowTokens, style: OCTypography.caption),
              subtitle: Text(S.setShowTokensSub, style: OCTypography.micro),
              value: store.showTokensInChat,
              activeTrackColor: context.oc.acc,
              onChanged: store.setShowTokensInChat,
            ),
              _GroupDivider(),
            ],
          ),

          // ---------------- voice ----------------
          const SectionTitle(S.setVoice),
          const _VoiceSettings(),

          // ---------------- providers ----------------
          const SectionTitle(S.setProviders),
          _Group(
            children: [
            _Providers(),
              _GroupDivider(),
            ],
          ),

          // ---------------- config ----------------
          const SectionTitle(S.setConfig),
          _Group(
            children: [
            _ConfigEditor(config: store.config),
              _GroupDivider(),
            ],
          ),

          // ---------------- mcp ----------------
          SectionTitle(S.setMcpServers(store.mcp.length)),
          _Group(
            children: [
            if (store.mcp.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OCSpace.screenX,
                  0,
                  OCSpace.screenX,
                  OCSpace.sm,
                ),
                child: Text(S.noMcpServers, style: OCTypography.caption),
              ),
            for (final e in store.mcp.entries)
              ListTile(
                dense: true,
                leading: OCIconTile(
                  icon: e.value.healthy
                      ? Icons.check_circle
                      : Icons.error_outline,
                  accent: e.value.healthy ? OCAccent.green : OCAccent.red,
                  size: 30,
                  iconSize: 16,
                ),
                title: Text(e.key, style: OCTypography.caption),
                subtitle: Text(
                  [
                    e.value.status,
                    if (e.value.message.isNotEmpty) e.value.message,
                    if (e.value.detail.isNotEmpty) e.value.detail,
                  ].where((x) => x.isNotEmpty).join(' · '),
                  style: OCTypography.micro,
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: OCColors.textSecondary,
                  ),
                  onSelected: (v) async {
                    if (v == 'connect') {
                      await store.api.mcpConnect(e.key);
                      store.refreshConfig();
                    } else if (v == 'disconnect') {
                      await store.api.mcpDisconnect(e.key);
                      store.refreshConfig();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'connect', child: Text(S.setConnect)),
                    PopupMenuItem(value: 'disconnect', child: Text(S.setDisconnect)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.sm,
                OCSpace.screenX,
                0,
              ),
              child: OCButton(
                onPressed: () => _addMcp(context),
                icon: Icons.add,
                label: S.setAddMcp,
                variant: OCButtonVariant.secondaryPill,
                expand: false,
              ),
            ),
              _GroupDivider(),
            ],
          ),

          // ---------------- lsp / formatter ----------------
          const SectionTitle(S.setLanguageServers),
          _Group(
            children: [
            if (store.lsp.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OCSpace.screenX,
                  0,
                  OCSpace.screenX,
                  OCSpace.sm,
                ),
                child: Text(S.noLspActive, style: OCTypography.caption),
              ),
            for (final l in store.lsp) _StatusRow(l),
            const SectionTitle(S.setFormatters),
            if (store.formatters.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OCSpace.screenX,
                  0,
                  OCSpace.screenX,
                  OCSpace.sm,
                ),
                child: Text(S.noFormatters, style: OCTypography.caption),
              ),
            for (final f in store.formatters) _StatusRow(f),
              _GroupDivider(),
            ],
          ),

          // ---------------- skills ----------------
          _Group(
            children: [
            const SkillsSection(),
            ],
          ),

          // ---------------- about ----------------
          const SectionTitle(S.setAbout),
          _Group(
            children: [
            const InfoRow(S.setApp, S.setAppVersion),
            const InfoRow(S.setServerApi, S.setServerVersionRange),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.md,
                OCSpace.screenX,
                0,
              ),
              child: Text(
                S.termuxSetupNote(S.serverSetupCommand),
                style: OCTypography.micro.copyWith(height: 1.5),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editServer(BuildContext context, OcStore store) async {
    final url = TextEditingController(text: store.baseUrl);
    final user = TextEditingController(text: store.username);
    final pass = TextEditingController(text: store.password);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(S.setServerLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: url,
              decoration: const InputDecoration(labelText: S.setUrlLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: user,
              decoration: const InputDecoration(labelText: S.setUserLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                labelText: S.setPassword('OPENCODE_SERVER_PASSWORD'),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                for (final preset in const [
                  'http://127.0.0.1:4096',
                  'http://127.0.0.1:4097',
                  'http://10.0.2.2:4096',
                ])
                  ActionChip(
                    label: Text(preset, style: OCTypography.micro),
                    onPressed: () => url.text = preset,
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancel),
          ),
          OCButton(
            label: S.setConnect,
            variant: OCButtonVariant.primaryBlack,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok == true) {
      await store.setServer(url.text, user: user.text, pass: pass.text);
    }
  }

  Future<void> _addMcp(BuildContext context) async {
    final store = AppScope.read(context);
    final name = TextEditingController();
    final value = TextEditingController();
    String type = 'local';
    await showDialog(
      context: context,
      builder: (dlg) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text(S.setAddMcp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: S.nameLabel),
              ),
              const SizedBox(height: 10),
              OCSegmentedControl<String>(
                segments: const [
                  OCSegment('local', 'Local'),
                  OCSegment('remote', 'Remote'),
                ],
                value: type,
                onChanged: (v) => setD(() => type = v),
              ),
              const SizedBox(height: OCSpace.md),
              TextField(
                controller: value,
                decoration: InputDecoration(
                  labelText: S.setMcpLabel(type),
                  hintText: type == 'local' ? 'npx' : 'https://example.com/mcp',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlg),
              child: const Text(S.cancel),
            ),
            OCButton(
              label: S.setAdd,
              variant: OCButtonVariant.primaryBlack,
              onPressed: () {
                if (name.text.trim().isEmpty || value.text.trim().isEmpty)
                  return;
                store.addMcp(
                  name.text.trim(),
                  type,
                  value.text.trim(),
                  const [],
                );
                Navigator.pop(dlg);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
