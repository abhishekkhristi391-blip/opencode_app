part of '../chat.dart';

/// Reference `.pill`: one accent-tinted chip reading `model · agent` that
/// opens the model / agent / tools sheet. This replaces the old three-chip
/// quick bar; there is no separate tools chip or dropdown anymore.
/// The composer's model/agent pill.
///
/// Was `accSoft` fill with `accInk` text — an accent-coloured control sitting
/// next to the accent send button, so the two competed and the pill looked like
/// the primary action. Now a neutral outlined chip with an explicit chevron,
/// which is what makes it read as "opens a picker".
///
/// It stays in the composer rather than moving under the hero: that hero only
/// exists on an empty chat, so moving it would remove the only way to switch
/// model once a message has been sent.
class _ModelPill extends StatelessWidget {
  final OcStore store;
  const _ModelPill({required this.store});

  @override
  Widget build(BuildContext context) => OutlinedChip(
    icon: LI.tune,
    label: store.modelId.isEmpty
        ? S.chipPickModel
        : S.composerModelAgent(store.modelId, store.agent),
    tooltip: S.composerModelPill,
    onTap: () => showModelSheet(context, store),
  );
}

/// Agent ("mode") picker for the hero's Mode chip. Same list and the same
/// `store.setAgent` call as the More sheet, surfaced where the pairing is
/// visible.
Future<void> showAgentSheet(BuildContext context, OcStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => RadioGroup<String>(
      groupValue: store.agent,
      onChanged: (v) {
        if (v != null) store.setAgent(v);
        Navigator.pop(sheetCtx);
      },
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenGutter,
                0,
                OCSpace.screenGutter,
                OCSpace.sm,
              ),
              child: Text(
                S.moreAgent,
                style: OCTypography.bodyStrong.copyWith(
                  color: sheetCtx.oc.mute,
                ),
              ),
            ),
            for (final a in store.agents)
              RadioListTile<String>(
                value: a.name,
                dense: true,
                title: Text(a.name, style: OCTypography.body),
                subtitle: a.description.isEmpty
                    ? null
                    : Text(
                        a.description,
                        maxLines: 2,
                        style: OCTypography.meta,
                      ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Model / agent / tools, as the reference `.sheet` panel.
Future<void> showModelSheet(BuildContext context, OcStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetOption(
            label: S.moreModel,
            value: store.modelId.isEmpty ? S.chipPickModel : store.modelId,
            onTap: () async {
              Navigator.pop(sheetCtx);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelsPage()),
              );
            },
          ),
          _SheetOption(
            label: S.moreAgent,
            value: store.agent,
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickAgentSheet(context, store);
            },
          ),
          _SheetOption(
            label: S.moreTools,
            value: S.moreToolsCount(store.toolsEnabled.length),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickToolsSheet(context, store);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// `.opt` line: label on the left, muted value plus chevron on the right.
class _SheetOption extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SheetOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Text(label, style: OCTypography.body.copyWith(color: t.ink)),
            const Spacer(),
            Text(value, style: OCTypography.body.copyWith(color: t.mute)),
            const SizedBox(width: 8),
            LIcon(LI.chevronRight, size: 16, color: t.mute),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAgentSheet(BuildContext context, OcStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => RadioGroup<String>(
      groupValue: store.agent,
      onChanged: (v) {
        if (v != null) store.setAgent(v);
        Navigator.pop(sheetCtx);
      },
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                S.moreAgent,
                style: OCTypography.bodyStrong.copyWith(color: context.oc.mute),
              ),
            ),
            for (final a in store.agents)
              RadioListTile<String>(
                value: a.name,
                dense: true,
                title: Text(a.name, style: OCTypography.body),
                subtitle: a.description.isEmpty
                    ? null
                    : Text(
                        a.description,
                        maxLines: 2,
                        style: OCTypography.micro,
                      ),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickToolsSheet(BuildContext context, OcStore store) async {
  List<String> ids;
  try {
    ids = await store.api.toolIds();
  } catch (e) {
    if (context.mounted) showSnack(context, '$e', error: true);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (c, setSheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(S.moreTools, style: OCTypography.bodyStrong),
                  ),
                  TextButton(
                    onPressed: () {
                      store.toolsEnabled.clear();
                      setSheet(() {});
                    },
                    child: Text(S.toolsEnableAll),
                  ),
                ],
              ),
            ),
            Text(
              S.toolsSheetHint,
              style: OCTypography.micro.copyWith(color: context.oc.mute),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final id in ids)
                    CheckboxListTile(
                      dense: true,
                      value: store.toolsEnabled.contains(id),
                      title: Text(id, style: OCTypography.mono(size: 12.5)),
                      onChanged: (v) {
                        store.toggleTool(id, v ?? false);
                        setSheet(() {});
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
