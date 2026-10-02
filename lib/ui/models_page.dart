import 'package:flutter/material.dart';

import '../api/client.dart';
import '../main.dart';
import '../models/models.dart';
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
      if (onlyConnected && info != null && !info.connected.contains(p.id)) continue;
      final ms = p.models.where((m) {
        if (q.isEmpty) return true;
        return m.id.toLowerCase().contains(q) || m.name.toLowerCase().contains(q);
      }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Model search karo…',
                prefixIcon: Icon(Icons.search, size: 19),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                FilterChip(
                  label: const Text('Sab', style: TextStyle(fontSize: 12)),
                  selected: providerFilter.isEmpty,
                  onSelected: (_) => setState(() => providerFilter = ''),
                ),
                for (final p in providers.where((e) => e.models.isNotEmpty).take(30))
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilterChip(
                      avatar: info != null && info.connected.contains(p.id)
                          ? const Icon(Icons.check_circle, size: 13, color: Color(0xFF3DDC84))
                          : null,
                      label: Text(p.id, style: const TextStyle(fontSize: 12)),
                      selected: providerFilter == p.id,
                      onSelected: (_) => setState(() => providerFilter = providerFilter == p.id ? '' : p.id),
                    ),
                  ),
              ],
            ),
          ),
          if (info != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Checkbox(
                    value: onlyConnected,
                    onChanged: (v) => setState(() => onlyConnected = v ?? true),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Sirf connected providers', style: TextStyle(fontSize: 12)),
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
                        padding: const EdgeInsets.only(bottom: 16),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, size: 17),
                  const SizedBox(width: 8),
                  const Text('Agent', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 10),
                  Expanded(child: _AgentDropdown(agents: store.agents, value: store.agent)),
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
      return Text(value, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline));
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
              child: Text('${a.name}  ·  ${a.modeLabel}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
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
    final cs = Theme.of(context).colorScheme;
    final store = AppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Icon(connected ? Icons.check_circle : Icons.cloud_off, size: 14, color: connected ? const Color(0xFF3DDC84) : cs.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(entry.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              Text('${models.length}', style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
          ),
        ),
        for (final m in models)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 34, right: 12),
            title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            subtitle: Row(
              children: [
                if (m.reasoning)
                  const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.psychology, size: 11, color: Color(0xFFB388FF))),
                if (m.toolcall)
                  const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.build, size: 11, color: Color(0xFF64B5F6))),
                if (m.attachment)
                  const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.image, size: 11, color: Color(0xFF4DB6AC))),
                if (m.contextLimit > 0)
                  Text('${(m.contextLimit / 1000).round()}k ctx', style: TextStyle(fontSize: 10.5, color: cs.outline)),
              ],
            ),
            trailing: selected == m.key
                ? Icon(Icons.check_circle, size: 18, color: cs.primary)
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
