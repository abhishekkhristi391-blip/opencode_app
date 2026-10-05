part of '../chat.dart';

/// Gap between the composer's pinned controls.
const double _tapGap = OCSpace.xs;

/// Narrowest the model pill may get before its label stops being readable: the
/// icon, the chevron and about 50dp of truncated model name.
const double _pillMin = 96;

/// What the row needs with only the pinned controls: attach + gap + pill + gap
/// + send. 48 + 4 + 96 + 4 + 48 = 200.
const double _rowPinned = OCSpace.tapTarget * 2 + _pillMin + _tapGap * 2;

/// The same plus the hands-free button and its gap: 252.
///
/// This is the breakpoint that decides where hands-free lives. A 320dp phone
/// leaves the row 260dp after the screen gutter and the composer's own padding,
/// so it keeps the button; a narrow split-screen pane does not, and gets it in
/// the attach sheet instead. Derived, not guessed per screen.
const double _rowHandsFree = _rowPinned + OCSpace.tapTarget + _tapGap;

/// Width the optional dictation action adds beside the primary one: a tap
/// target and the gap that separates it.
const double _micSlot = OCSpace.tapTarget + _tapGap;

/// Rebuilds only when attachments/busy/modelId/agent/toolsEnabled changes
class _ComposerWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;

  const _ComposerWidget({
    required this.controller,
    required this.focus,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        return _Composer(
          store: store,
          controller: controller,
          focus: focus,
          onSend: onSend,
          onStop: store.abortSession,
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final OcStore store;
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;
  final VoidCallback onStop;
  const _Composer({
    required this.store,
    required this.controller,
    required this.focus,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      // The composer insets by the same gutter as the header, hero and cards, so
      // all four share one left edge. It was 12px against their 18px.
      padding: const EdgeInsets.fromLTRB(
        OCSpace.screenGutter,
        OCSpace.sm,
        OCSpace.screenGutter,
        OCSpace.sm,
      ),
      child: Container(
        // The reference's `p-3.5`.
        padding: const EdgeInsets.all(OCSpace.md),
        decoration: BoxDecoration(
          // surfaceElevated, not card: the input box used to share its fill with
          // the suggestion cards, so the bottom of the screen read as one slab.
          color: t.surfaceElevated,
          borderRadius: BorderRadius.circular(OCRadius.composer),
          // The reference lifts the composer with `shadow-2xl` and no outline.
          // A 1dp border plus a 0-blur shadow made it look like a text field
          // rather than a card floating over the transcript.
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (store.attachments.isNotEmpty) _AttachmentStrip(store),
            // One field, then one tools row — the reference stacks the two
            // inside a single container instead of using separate bars.
            SlashTextField(
              controller: controller,
              focusNode: focus,
              store: store,
              onSubmit: onSend,
              // The placeholder used to always read "Ask Codex...", so an active
              // conversation looked identical to a cold start.
              placeholder: store.messages.isEmpty
                  ? S.composerPlaceholderStart
                  : S.composerPlaceholderReply,
            ),
            if (store.busy) _WorkingStrip(agent: store.agent, onStop: onStop),
            if (store.hasQueued) _QueuedStrip(store: store),
            // Voice sits between the field and the tools row, the same slot the
            // working strip uses. A strip is used instead of a button tint
            // because "the microphone is open" has to be readable at a glance
            // from across a desk, not inferred from a coloured circle. The strip
            // returns `SizedBox.shrink()` when nothing is live, so the gap below
            // the field is unchanged for a user who never touches voice.
            const _VoiceStrip(),
            // One row: attach, model pill, hands-free, send.
            //
            // The pill is the only Flexible child, so the width goes to the text
            // that can ellipsize and never to the controls, which are pinned at
            // the 48dp tap target. [Flexible] alone still let the pill take 220dp
            // and push Send off the edge, because nothing bounded it; the widths
            // below are derived once from the width this row actually gets, so a
            // narrow phone loses a control instead of overflowing.
            LayoutBuilder(
              builder: (context, row) {
                final showHandsFree = row.maxWidth >= _rowHandsFree;
                // The optional second action (dictate while the text stays) only
                // appears if the pinned controls plus one more tap target and its
                // gap still fit, so it can never be the thing that overflows.
                final micFits =
                    row.maxWidth >=
                    (showHandsFree ? _rowHandsFree : _rowPinned) + _micSlot;
                return Row(
                  children: [
                    _CircleButton(
                      // The reference draws `add` on a `container-highest` disc,
                      // not a bare paperclip: the glyph is "add", the sheet that
                      // opens is the attachments picker.
                      icon: LI.plus,
                      bg: OCColors.surfaceHighest,
                      fg: t.ink,
                      semanticLabel: S.composerAttachTooltip,
                      // When the row is too narrow for hands-free, it moves into
                      // this sheet instead of being dropped.
                      onTap: () => _showAttachSheet(
                        context,
                        withHandsFree: !showHandsFree,
                      ),
                      diameter: OCSpace.tapTarget,
                      glyph: 22,
                    ),
                    const SizedBox(width: _tapGap),
                    Flexible(child: _ModelPill(store: store)),
                    if (showHandsFree) ...[
                      const SizedBox(width: _tapGap),
                      const _HandsFreeButton(),
                    ],
                    const SizedBox(width: _tapGap),
                    _SendButton(
                      store: store,
                      controller: controller,
                      onSend: onSend,
                      onStop: onStop,
                      micSlot: micFits,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// [withHandsFree] adds the hands-free row. It is passed in rather than
  /// measured here because the sheet is opened by the attach button, which is
  /// the only place that knows how much width the row had.
  Future<void> _showAttachSheet(
    BuildContext context, {
    bool withHandsFree = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titled, so the bare rows below are not read as page content.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.screenGutter,
                0,
                OCSpace.screenGutter,
                OCSpace.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  S.attachSheetTitle,
                  style: OCTypography.bodyStrong.copyWith(
                    color: sheetCtx.oc.mute,
                  ),
                ),
              ),
            ),
            _SheetRow(
              icon: LI.attach,
              label: S.attachImage,
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(context);
              },
            ),
            _SheetRow(
              icon: LI.folder,
              label: S.attachFile,
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickProjectFile(context);
              },
            ),
            if (withHandsFree) const _HandsFreeSheetRow(),
            _SheetRow(
              icon: LI.terminal,
              label: S.attachSlash,
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCommands(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final b64 = base64Encode(bytes);
    store.addAttachment(
      PendingAttachment(
        path: x.path,
        mime: x.mimeType ?? 'image/jpeg',
        name: x.name,
        size: bytes.length,
        dataUrl: 'data:${x.mimeType ?? 'image/jpeg'};base64,$b64',
      ),
    );
  }

  Future<void> _pickProjectFile(BuildContext context) async {
    final picked = await showModalBottomSheet<FileNode>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _FilePickerSheet(),
    );
    if (picked == null) return;
    try {
      final content = await store.api.readFile(picked.path);
      store.addAttachment(
        PendingAttachment(
          path: picked.path,
          mime: _mimeFor(picked.name),
          name: picked.name,
          size: content.length,
          dataUrl:
              'data:${_mimeFor(picked.name)};base64,${base64Encode(utf8.encode(content))}',
        ),
      );
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
    }
  }

  static String _mimeFor(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => 'text/x-dart',
      'py' => 'text/x-python',
      'js' || 'mjs' => 'text/javascript',
      'ts' => 'text/typescript',
      'json' => 'application/json',
      'md' => 'text/markdown',
      'yaml' || 'yml' => 'text/yaml',
      'sh' => 'text/x-sh',
      _ => 'text/plain',
    };
  }

  Future<void> _showCommands(BuildContext context) async {
    final builtins = const ['init', 'compact', 'undo', 'redo', 'share'];
    final names = {...store.commands.map((c) => c.name), ...builtins}.toList()
      ..sort();
    // Tappable: picking a command inserts it, which keeps the existing
    // insert-into-the-field behaviour instead of silently doing nothing.
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                S.pickerCommandsTitle,
                style: OCTypography.bodyStrong.copyWith(color: context.oc.mute),
              ),
            ),
            for (final n in names)
              ListTile(
                dense: true,
                leading: LIcon(LI.terminal, size: 18, color: context.oc.mute),
                title: Text(
                  S.slashCommand(n),
                  style: OCTypography.mono(size: 13),
                ),
                onTap: () => Navigator.pop(context, n),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      final t = controller.text;
      controller.text = t.isEmpty ? '/$picked ' : '$t /$picked ';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }
}

class _AttachmentStrip extends StatelessWidget {
  final OcStore store;
  const _AttachmentStrip(this.store);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        itemCount: store.attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final a = store.attachments[i];
          return InputChip(
            avatar: Icon(
              a.mime.startsWith('image/')
                  ? Icons.image_outlined
                  : Icons.description_outlined,
              size: 17,
            ),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                '${a.name} · ${fmtBytes(a.size)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            backgroundColor: cs.surfaceContainerHighest,
            onDeleted: () => store.removeAttachment(i),
          );
        },
      ),
    );
  }
}
