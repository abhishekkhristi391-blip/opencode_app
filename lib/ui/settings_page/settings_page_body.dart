part of '../settings_page.dart';

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

          const SectionTitle(S.setMascot),
          _Group(
            children: [
              ValueListenableBuilder<BuddyChar>(
                valueListenable: buddyChar,
                builder: (context, ch, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OCSpace.sm,
                    OCSpace.sm,
                    OCSpace.sm,
                    OCSpace.xs,
                  ),
                  child: Row(
                    children: [
                      for (final c in BuddyChar.values)
                        Padding(
                          padding: const EdgeInsets.only(right: OCSpace.sm),
                          child: ChoiceChip(
                            label: Text(
                              c == BuddyChar.dev
                                  ? S.setMascotDev
                                  : c == BuddyChar.sticko
                                      ? S.setMascotSticko
                                      : S.setMascotSara,
                              style: OCTypography.caption.copyWith(
                                color: OCColors.textPrimary,
                              ),
                            ),
                            selected: ch == c,
                            onSelected: (_) => store.setMascot(c),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _GroupDivider(),
              _ActionTile(
                icon: Icons.smart_toy_outlined,
                title: S.setMascotTest,
                subtitle: S.setMascotTestSub,
                onTap: () {
                  if (BuddyController.instance.pending == null) {
                    BuddyController.instance.runDemo();
                  }
                },
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
