import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';

import '../api/client.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
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
          InfoRow(S.setUrlLabel, store.baseUrl, mono: true),
          InfoRow(
            'Status',
            store.online
                ? 'connected (${store.serverVersion})'
                : 'disconnected',
          ),
          InfoRow('Project', store.paths?.directory ?? '-', mono: true),
          InfoRow('Worktree', store.paths?.worktree ?? '-', mono: true),
          InfoRow('Config dir', store.paths?.config ?? '-', mono: true),
          InfoRow(
            'Git branch',
            store.vcs?.branch.isNotEmpty == true
                ? store.vcs!.branch
                : 'not a repo',
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
          const Divider(height: OCSpace.xxl),

          // ---------------- session actions ----------------
          const SectionTitle('Current session'),
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
                confirm: 'Restart',
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
                confirm: 'Upgrade',
              );
              if (!ok) return;
              try {
                await store.api.upgrade();
                await store.connect();
                if (context.mounted) showSnack(context, 'Upgrade complete');
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
                title: S.setPermExternalTitle(d.path),
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
          const Divider(height: OCSpace.xxl),

          // ---------------- chat display ----------------
          const SectionTitle('Chat'),
          SwitchListTile(
            dense: true,
            title: Text('Show tokens in chat', style: OCTypography.caption),
            subtitle: Text('Under each reply', style: OCTypography.micro),
            value: store.showTokensInChat,
            activeTrackColor: context.oc.acc,
            onChanged: store.setShowTokensInChat,
          ),
          const Divider(height: OCSpace.xxl),

          // ---------------- providers ----------------
          const SectionTitle('Providers'),
          _Providers(),
          const Divider(height: 26),

          // ---------------- config ----------------
          const SectionTitle('Config'),
          _ConfigEditor(config: store.config),
          const Divider(height: 26),

          // ---------------- mcp ----------------
          SectionTitle('MCP servers (${store.mcp.length})'),
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
                  PopupMenuItem(value: 'disconnect', child: Text('Disconnect')),
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
          const Divider(height: OCSpace.xxl),

          // ---------------- lsp / formatter ----------------
          const SectionTitle('Language servers'),
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
          const SectionTitle('Formatters'),
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
          const Divider(height: OCSpace.xxl),

          // ---------------- skills ----------------
          const SkillsSection(),
          const Divider(height: OCSpace.xxl),
          const SectionTitle('About'),
          const InfoRow('App', 'OpenCode Client 1.0.0'),
          const InfoRow('Server API', 'opencode 1.18.x'),
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
              decoration: const InputDecoration(
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
            child: const Text('Cancel'),
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
              child: const Text('Cancel'),
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
              '${p.models.length} models',
              style: OCTypography.micro,
            ),
            trailing: TextButton(
              onPressed: () async {
                await store.api.removeAuth(p.id);
                await store.refreshCatalog();
                if (context.mounted) showSnack(context, '${p.id} logout');
              },
              child: const Text('Logout', style: TextStyle(fontSize: 12)),
            ),
          ),
        if (unconnected.isNotEmpty) const SectionTitle('API key daalo'),
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
            child: const Text('Cancel'),
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
                showSnack(context, 'JSON invalid: $e', error: true);
                return;
              }
              if (parsed is! Map<String, dynamic>) {
                showSnack(context, 'Root object hona chahiye', error: true);
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
