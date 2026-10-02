import 'package:flutter/material.dart';

import '../api/client.dart';
import '../main.dart';
import '../models/models.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  final search = TextEditingController();
  String providerFilter = '';
  bool onlyConnected = true;

  @override
  void initState() {
    super.initState();
    final s = AppScope.read(context);
    if (s.providerId.isNotEmpty) providerFilter = s.providerId;
    s.refreshCatalog();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final info = store.providerInfo;
    final providers = info?.ordered ?? const <ProviderEntry>[];

    final q = search.text.trim().toLowerCase();
    final visible = <({ProviderEntry p, List<ModelInfo> models})>[];
    for (final p in providers) {
      if (providerFilter.isNotEmpty && p.id != providerFilter) continue;
      if (onlyConnected && info != null && !info.connected.contains(p.id))
        continue;
      final ms =
          p.models.where((m) {
            if (q.isEmpty) return true;
            return m.id.toLowerCase().contains(q) ||
                m.name.toLowerCase().contains(q);
          }).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
      if (ms.isNotEmpty) visible.add((p: p, models: ms));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models & Agents'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: store.refreshCatalog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.screenX,
              OCSpace.md,
              OCSpace.screenX,
              OCSpace.sm,
            ),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Model search karo…',
                hintStyle: OCTypography.caption,
                prefixIcon: const Icon(
                  Icons.search,
                  size: 19,
                  color: OCColors.textTertiary,
                ),
                isDense: true,
                filled: true,
                fillColor: OCColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.lg,
                  vertical: OCSpace.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.full),
                  borderSide: const BorderSide(color: OCColors.borderHairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.full),
                  borderSide: const BorderSide(color: OCColors.borderHairline),
                ),
              ),
            ),
          ),
          SizedBox(
            height: OCSpace.tapTarget,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
              children: [
                FilterChip(
                  label: Text(
                    'Sab',
                    style: OCTypography.caption.copyWith(
                      color: OCColors.textPrimary,
                    ),
                  ),
                  selected: providerFilter.isEmpty,
                  onSelected: (_) => setState(() => providerFilter = ''),
                ),
                for (final p
                    in providers.where((e) => e.models.isNotEmpty).take(30))
                  Padding(
                    padding: const EdgeInsets.only(left: OCSpace.sm),
                    child: FilterChip(
                      avatar: info != null && info.connected.contains(p.id)
                          ? const Icon(
                              Icons.check_circle,
                              size: 13,
                              color: OCColors.greenInk,
                            )
                          : null,
                      label: Text(
                        p.id,
                        style: OCTypography.caption.copyWith(
                          color: OCColors.textPrimary,
                        ),
                      ),
                      selected: providerFilter == p.id,
                      onSelected: (_) => setState(
                        () =>
                            providerFilter = providerFilter == p.id ? '' : p.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (info != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OCSpace.lg),
              child: Row(
                children: [
                  Checkbox(
                    value: onlyConnected,
                    onChanged: (v) => setState(() => onlyConnected = v ?? true),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text(
                    'Sirf connected providers',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: info == null
                ? const LoadingView(label: 'Providers load ho rahe hain')
                : visible.isEmpty
                ? EmptyHint(
                    icon: Icons.search_off,
                    title: 'Koi model nahi mila',
                    message: onlyConnected && info.connected.isEmpty
                        ? 'Koi provider connected nahi hai. Settings me API key daal do.'
                        : 'Filter badal ke dekho.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: OCSpace.lg),
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final e = visible[i];
                      final connected = info.connected.contains(e.p.id);
                      return _ProviderBlock(
                        entry: e.p,
                        models: e.models,
                        connected: connected,
                        selected: '${store.providerId}/${store.modelId}',
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: OCColors.surface,
                border: Border(top: BorderSide(color: OCColors.borderHairline)),
              ),
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenX,
                OCSpace.sm,
                OCSpace.screenX,
                OCSpace.sm,
              ),
              child: Row(
                children: [
                  const OCIconTile(
                    icon: Icons.smart_toy_outlined,
                    accent: OCAccent.purple,
                    size: 32,
                  ),
                  const SizedBox(width: OCSpace.md),
                  const Text('Agent', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: OCSpace.md),
                  Expanded(
                    child: _AgentDropdown(
                      agents: store.agents,
                      value: store.agent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentDropdown extends StatelessWidget {
  final List<Agent> agents;
  final String value;
  const _AgentDropdown({required this.agents, required this.value});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (agents.isEmpty) {
      return Text(value, style: OCTypography.micro);
    }
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: agents.any((a) => a.name == value) ? value : agents.first.name,
        isExpanded: true,
        isDense: true,
        items: [
          for (final a in agents)
            DropdownMenuItem(
              value: a.name,
              child: Text(
                '${a.name}  ·  ${a.modeLabel}',
                style: OCTypography.caption.copyWith(
                  color: OCColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (v) => v == null ? null : store.setAgent(v),
      ),
    );
  }
}

class _ProviderBlock extends StatelessWidget {
  final ProviderEntry entry;
  final List<ModelInfo> models;
  final bool connected;
  final String selected;
  const _ProviderBlock({
    required this.entry,
    required this.models,
    required this.connected,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.screenX,
            OCSpace.md,
            OCSpace.screenX,
            OCSpace.sm,
          ),
          child: Row(
            children: [
              OCIconTile(
                icon: connected ? Icons.check_circle : Icons.cloud_off,
                accent: connected ? OCAccent.green : OCAccent.neutral,
                size: 26,
                iconSize: 14,
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(child: Text(entry.name, style: OCTypography.bodyStrong)),
              Text('${models.length}', style: OCTypography.micro),
            ],
          ),
        ),
        for (final m in models)
          ListTile(
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OCRadius.inner),
            ),
            tileColor: selected == m.key ? OCColors.orangeTint : null,
            contentPadding: const EdgeInsets.only(
              left: OCSpace.xxxl,
              right: OCSpace.md,
            ),
            title: Text(
              m.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OCTypography.caption,
            ),
            subtitle: Row(
              children: [
                if (m.reasoning)
                  const Padding(
                    padding: EdgeInsets.only(right: OCSpace.sm),
                    child: Icon(
                      Icons.psychology,
                      size: 12,
                      color: OCColors.purple,
                    ),
                  ),
                if (m.toolcall)
                  const Padding(
                    padding: EdgeInsets.only(right: OCSpace.sm),
                    child: Icon(Icons.build, size: 12, color: OCColors.blue),
                  ),
                if (m.attachment)
                  const Padding(
                    padding: EdgeInsets.only(right: OCSpace.sm),
                    child: Icon(Icons.image, size: 12, color: OCColors.green),
                  ),
                if (m.contextLimit > 0)
                  Text(
                    '${(m.contextLimit / 1000).round()}k ctx',
                    style: OCTypography.micro,
                  ),
              ],
            ),
            trailing: selected == m.key
                ? const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: OCColors.orange,
                  )
                : null,
            onTap: () {
              store.setModel(entry.id, m.id);
              showSnack(context, 'Model: ${m.key}');
            },
          ),
      ],
    );
  }
}
