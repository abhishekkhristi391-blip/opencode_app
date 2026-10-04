import 'package:flutter/material.dart';

import '../api/client.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'chat.dart';
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
    final t = context.oc;
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
        title: const Text(S.modelsTitle),
        actions: [
          IconButton(
            tooltip: S.refresh,
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
                hintText: S.modelsSearchHint,
                hintStyle: OCTypography.caption.copyWith(color: t.mute),
                prefixIcon: Icon(Icons.search, size: 19, color: t.mute),
                isDense: true,
                filled: true,
                fillColor: t.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.lg,
                  vertical: OCSpace.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.full),
                  borderSide: BorderSide(color: t.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.full),
                  borderSide: BorderSide(color: t.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.full),
                  borderSide: BorderSide(color: t.acc),
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
                    S.modelsFilterAll,
                    style: OCTypography.caption.copyWith(color: t.ink),
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
                          ? Icon(Icons.check_circle, size: 13, color: t.ok)
                          : null,
                      label: Text(
                        p.id,
                        style: OCTypography.caption.copyWith(color: t.ink),
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
            // A switch, not a checkbox: it is a persistent view setting, and the
            // old bare checkbox sat 12dp from the edge with a 12px label.
            InkWell(
              onTap: () => setState(() => onlyConnected = !onlyConnected),
              child: SizedBox(
                height: OCSpace.tapTarget,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OCSpace.screenX,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.modelsConnectedOnly,
                          style: OCTypography.body.copyWith(color: t.ink),
                        ),
                      ),
                      Switch(
                        value: onlyConnected,
                        onChanged: (v) => setState(() => onlyConnected = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Divider(height: 1, color: t.line),
          Expanded(
            child: info == null
                ? const LoadingView(label: S.modelsLoadingProviders)
                : visible.isEmpty
                ? EmptyHint(
                    icon: Icons.search_off,
                    title: S.modelsNoneTitle,
                    message: onlyConnected && info.connected.isEmpty
                        ? S.modelsNoneBody
                        : S.modelsNoneFiltered,
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
              decoration: BoxDecoration(
                color: t.card,
                border: Border(top: BorderSide(color: t.line)),
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
                  Text(
                    S.modelsAgentLabel,
                    style: OCTypography.body.copyWith(color: t.mute),
                  ),
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
                style: OCTypography.caption.copyWith(color: context.oc.ink),
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
    final t = context.oc;
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
              Expanded(
                child: Text(
                  entry.name,
                  style: OCTypography.body.copyWith(
                    color: t.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${models.length}',
                style: OCTypography.caption.copyWith(color: t.mute),
              ),
            ],
          ),
        ),
        for (final m in models)
          // 64dp rows instead of a dense ListTile: the model name is the whole
          // content of the row and it was clipping after two words.
          InkWell(
            onTap: () {
              store.setModel(entry.id, m.id);
              showSnack(context, S.modelsSelected(m.name));
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(
                horizontal: OCSpace.screenX,
                vertical: OCSpace.sm,
              ),
              decoration: BoxDecoration(
                color: selected == m.key ? t.accSoft : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: selected == m.key ? t.acc : Colors.transparent,
                    width: 3,
                  ),
                  bottom: BorderSide(color: t.line.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: selected == m.key
                        ? Icon(Icons.check_circle, size: 18, color: t.acc)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.body.copyWith(color: t.ink),
                        ),
                        Row(
                          children: [
                            if (isFreeModel(m.key))
                              _ModelTag(label: S.badgeFree, color: t.acc),
                            if (m.reasoning)
                              _ModelTag(
                                label: S.modelsReasoning,
                                color: t.mute,
                              ),
                            if (m.toolcall)
                              _ModelTag(label: S.modelsTools, color: t.mute),
                            if (m.contextLimit > 0)
                              Text(
                                S.modelsContext(
                                  (m.contextLimit / 1000).round(),
                                ),
                                style: OCTypography.caption.copyWith(
                                  color: t.mute,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Small capability/cost tag on a model row. Subdued by default: these are
/// metadata, not the row's primary content.
class _ModelTag extends StatelessWidget {
  final String label;
  final Color color;
  const _ModelTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: OCSpace.xs),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color == context.oc.acc
          ? context.oc.accSoft
          : context.oc.surfaceElevated,
      borderRadius: BorderRadius.circular(OCRadius.xs),
    ),
    child: Text(label, style: OCTypography.micro.copyWith(color: color)),
  );
}
