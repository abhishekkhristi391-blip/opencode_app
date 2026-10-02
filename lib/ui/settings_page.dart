import 'dart:convert';

import 'package:flutter/material.dart';

import '../api/client.dart';
import '../main.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'commands_page.dart';
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
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await store.refreshConfig();
        await store.refreshServerInfo();
        await store.refreshCatalog();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          // ---------------- server ----------------
          const SectionTitle('Server'),
          InfoRow('URL', store.baseUrl, mono: true),
          InfoRow('Status', store.online ? 'connected (${store.serverVersion})' : 'disconnected'),
          InfoRow('Project', store.paths?.directory ?? '-', mono: true),
          InfoRow('Worktree', store.paths?.worktree ?? '-', mono: true),
          InfoRow('Config dir', store.paths?.config ?? '-', mono: true),
          InfoRow('Git branch', store.vcs?.branch.isNotEmpty == true ? store.vcs!.branch : 'not a repo'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed: () => _editServer(context, store),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change server', style: TextStyle(fontSize: 12.5)),
              ),
              OutlinedButton.icon(
                onPressed: store.connect,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reconnect', style: TextStyle(fontSize: 12.5)),
              ),
            ]),
          ),
          const Divider(height: 26),

          // ---------------- session actions ----------------
          const SectionTitle('Current session'),
          _ActionTile(
            icon: Icons.auto_awesome,
            title: 'AGENTS.md banao (/init)',
            subtitle: 'Project ka instruction file generate karo',
            onTap: store.initAgents,
          ),
          _ActionTile(
            icon: Icons.compress,
            title: 'Summarize karo',
            subtitle: 'Chat ka context compact karo',
            onTap: store.summarize,
          ),
          _ActionTile(
            icon: Icons.undo,
            title: 'Revert',
            subtitle: 'Pichle message ke changes wapas lo',
            onTap: () async {
              final id = store.current?.id;
              if (id == null || store.messages.isEmpty) {
                showSnack(context, 'Koi message nahi');
                return;
              }
              await store.revert(store.messages.last.info.id);
            },
          ),
          _ActionTile(
            icon: Icons.redo,
            title: 'Unrevert',
            subtitle: 'Saare reverted changes wapas lo',
            onTap: store.unrevert,
          ),
          _ActionTile(
            icon: Icons.refresh,
            title: 'Instance restart',
            subtitle: 'Server ka current instance dispose karke fresh start',
            danger: true,
            onTap: () async {
              final ok = await confirmDialog(context,
                  title: 'Instance restart?',
                  message: 'Current instance dispose ho jayega. Active kaam ruk sakta hai.',
                  confirm: 'Restart');
              if (!ok) return;
              try {
                await store.api.disposeInstance();
                await store.connect();
                if (context.mounted) showSnack(context, 'Instance restart ho gaya');
              } catch (e) {
                if (context.mounted) showSnack(context, '$e', error: true);
              }
            },
          ),
          _ActionTile(
            icon: Icons.system_update,
            title: 'opencode upgrade',
            subtitle: 'Server side opencode ko latest version pe le jao',
            danger: true,
            onTap: () async {
              final ok = await confirmDialog(context,
                  title: 'Upgrade karein?',
                  message: 'Server restart ho sakta hai.',
                  confirm: 'Upgrade');
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
            title: 'External folder likhne ki permission do',
            subtitle: 'Project ke bahar bhi files create karne allow karega',
            onTap: () async {
              final ok = await confirmDialog(context,
                  title: 'External directory permission allow karein?',
                  message: 'Ye opencode ko project folder ke bahar bhi files likhne dega (jaise /storage/emulated/0/).',
                  confirm: 'Allow');
              if (!ok) return;
              try {
                await store.api.patchConfig({
                  'permission': {
                    'edit': 'allow',
                    'bash': 'allow',
                    'external_directory': 'allow',
                  }
                });
                await store.refreshConfig();
                if (context.mounted) showSnack(context, 'External directory permission allow ho gaya');
              } catch (e) {
                if (context.mounted) showSnack(context, '$e', error: true);
              }
            },
          ),
          const Divider(height: 26),

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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Koi MCP server nahi.',
                  style: TextStyle(fontSize: 12, color: cs.outline)),
            ),
          for (final e in store.mcp.entries)
            ListTile(
              dense: true,
              leading: Icon(e.value.healthy ? Icons.check_circle : Icons.error_outline,
                  size: 18, color: e.value.healthy ? const Color(0xFF3DDC84) : cs.error),
              title: Text(e.key, style: const TextStyle(fontSize: 13.5)),
              subtitle: Text(
                  [e.value.status, if (e.value.message.isNotEmpty) e.value.message, if (e.value.detail.isNotEmpty) e.value.detail]
                      .where((x) => x.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(fontSize: 11)),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
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
                  PopupMenuItem(value: 'connect', child: Text('Connect')),
                  PopupMenuItem(value: 'disconnect', child: Text('Disconnect')),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => _addMcp(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('MCP server add karo', style: TextStyle(fontSize: 12.5)),
            ),
          ),
          const Divider(height: 26),

          // ---------------- lsp / formatter ----------------
          const SectionTitle('Language servers'),
          if (store.lsp.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Koi LSP active nahi.', style: TextStyle(fontSize: 12, color: cs.outline)),
            ),
          for (final l in store.lsp) _StatusRow(l),
          const SectionTitle('Formatters'),
          if (store.formatters.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Koi formatter nahi.', style: TextStyle(fontSize: 12, color: cs.outline)),
            ),
          for (final f in store.formatters) _StatusRow(f),
          const Divider(height: 26),

          // ---------------- skills ----------------
          const SkillsSection(),
          const Divider(height: 26),
          const SectionTitle('About'),
          const InfoRow('App', 'OpenCode Client 1.0.0'),
          const InfoRow('Server API', 'opencode 1.18.x'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'Is app ke liye Termux me opencode server chalna zaroori hai. Server ko usi project folder se start karo jise app me dekhna hai.',
              style: TextStyle(fontSize: 11.5, color: cs.outline, height: 1.5),
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
        title: const Text('Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: url, decoration: const InputDecoration(labelText: 'URL')),
            const SizedBox(height: 10),
            TextField(
                controller: user, decoration: const InputDecoration(labelText: 'Username (basic auth)')),
            const SizedBox(height: 10),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password (OPENCODE_SERVER_PASSWORD)'),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 6, children: [
              for (final preset in const [
                'http://127.0.0.1:4096',
                'http://127.0.0.1:4097',
                'http://10.0.2.2:4096',
              ])
                ActionChip(
                  label: Text(preset, style: const TextStyle(fontSize: 11)),
                  onPressed: () => url.text = preset,
                ),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Connect')),
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
          title: const Text('MCP server add karo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'local', label: Text('Local')),
                  ButtonSegment(value: 'remote', label: Text('Remote')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setD(() => type = s.first),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: value,
                decoration: InputDecoration(
                  labelText: type == 'local' ? 'Command (e.g. npx)' : 'URL',
                  hintText: type == 'local' ? 'npx' : 'https://example.com/mcp',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dlg), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || value.text.trim().isEmpty) return;
                store.addMcp(name.text.trim(), type, value.text.trim(), const []);
                Navigator.pop(dlg);
              },
              child: const Text('Add'),
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

    final connected = info.all.where((p) => info.connected.contains(p.id)).toList();
    final unconnected = info.all
        .where((p) => !info.connected.contains(p.id) && p.needsKey)
        .take(25)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (connected.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Koi provider connected nahi. Neeche se API key daal do.',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
          ),
        for (final p in connected)
          ListTile(
            dense: true,
            leading: const Icon(Icons.check_circle, size: 17, color: Color(0xFF3DDC84)),
            title: Text(p.name, style: const TextStyle(fontSize: 13.5)),
            subtitle: Text('${p.models.length} models', style: const TextStyle(fontSize: 11)),
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
            leading: const Icon(Icons.cloud_off_outlined, size: 17),
            title: Text(p.name, style: const TextStyle(fontSize: 13.5)),
            subtitle: Text(p.env.join(', '), style: const TextStyle(fontSize: 10.5)),
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
          decoration: InputDecoration(hintText: p.env.isEmpty ? 'sk-...' : p.env.first),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
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
  late final TextEditingController c = TextEditingController(text: _pretty(widget.config));

  static String _pretty(Map<String, dynamic> j) {
    try {
      return const JsonEncoder.withIndent('  ').convert(j);
    } catch (_) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 240,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: c,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.45),
              decoration: const InputDecoration(border: InputBorder.none, filled: false, isDense: true),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
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
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Config save karo', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 6),
          Text('PATCH /config — ye global opencode config update karta hai.',
              style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.outline)),
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
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(s.healthy ? Icons.check_circle : Icons.error_outline,
          size: 17, color: s.healthy ? const Color(0xFF3DDC84) : cs.outline),
      title: Text(s.name.isEmpty ? s.id : s.name, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
          [s.status, s.message, s.detail].where((x) => x.isNotEmpty).join(' · '),
          style: const TextStyle(fontSize: 10.5)),
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
        leading: Icon(icon, size: 19, color: danger ? Colors.redAccent : null),
        title: Text(title,
            style: TextStyle(fontSize: 13.5, color: danger ? Colors.redAccent : null)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      );
}
