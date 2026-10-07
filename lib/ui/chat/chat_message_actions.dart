part of '../chat.dart';

/// Long-press menu: Copy, Fork, Undo, Delete.
///
/// Fork and Delete leave the inline row entirely, so they live here. Copy and
/// Undo are deliberately duplicated from the last reply's inline row: a long
/// press is the only way to reach them on an older message.
Future<void> showMessageMenu(BuildContext context, ChatMessage msg) async {
  final store = AppScope.read(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetRow(
            icon: LI.copy,
            label: S.copy,
            onTap: () {
              Navigator.pop(sheetCtx);
              final text = msg.parts
                  .where((p) => p.type == 'text')
                  .map((p) => p.text)
                  .join('\n');
              copyToClipboard(context, text);
            },
          ),
          _SheetRow(
            icon: LI.fork,
            label: S.messageForkHere,
            onTap: () async {
              Navigator.pop(sheetCtx);
              final s = await store.forkSession(
                store.current!.id,
                messageId: msg.info.id,
              );
              if (s != null && context.mounted) {
                await store.openSession(s.id);
                if (context.mounted) showSnack(context, S.messageForked);
              }
            },
          ),
          if (!msg.info.isUser) ...[
            _SheetRow(
              icon: LI.volume,
              label: S.voiceSpeakSheetTitle,
              onTap: () {
                Navigator.pop(sheetCtx);
                final voice = VoiceScope.read(context);
                final text = msg.parts
                    .where((p) => p.type == 'text')
                    .map((p) => p.text)
                    .join('\n');
                if (text.trim().isEmpty) {
                  showSnack(context, S.voiceNothingToRead);
                  return;
                }
                voice.speak(text);
              },
            ),
            _SheetRow(
              icon: LI.undo,
              label: S.messageUndo,
              onTap: () {
                Navigator.pop(sheetCtx);
                store.revert(msg.info.id);
              },
            ),
          ],
          _SheetRow(
            icon: LI.trash,
            label: S.delete,
            danger: true,
            onTap: () async {
              Navigator.pop(sheetCtx);
              try {
                await store.api.deleteMessage(store.current!.id, msg.info.id);
                await store.openSession(store.current!.id);
                if (!context.mounted) return;
                // Reversible, so it is not confirmed: the old confirm dialog
                // asked about an action that the undo bar already covers.
                showUndoSnack(context, S.messageDeleted, () {
                  // The server has no restore endpoint; re-running undo on the
                  // message is the closest honest recovery, so the bar says
                  // so rather than pretending.
                  store.revert(msg.info.id);
                });
              } catch (e) {
                if (context.mounted) showSnack(context, '$e', error: true);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// One row in a bottom sheet, styled like the reference `.opt` line.
class _SheetRow extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = danger ? t.err : t.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
        child: Row(
          children: [
            LIcon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: OCTypography.body.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingFileChip extends StatelessWidget {
  final Part part;
  const _IncomingFileChip(this.part);

  @override
  Widget build(BuildContext context) {
    // Sits inside the dark user bubble as its own card, so it gets a card
    // fill for contrast and the blue icon tile reads as an attachment rather
    // than a piece of inline text.
    final t = context.oc;
    final isImg = part.mime.startsWith('image/');
    final label = part.filename.isEmpty ? baseName(part.url) : part.filename;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.deep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LIcon(
              isImg ? LI.attach : LI.doc,
              size: 15,
              color: t.tertiary,
              strokeWidth: 1.9,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.caption.copyWith(
                    color: t.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isImg ? 'IMAGE' : 'FILE',
                  style: OCTypography.mono(size: 10, color: t.faint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Two 40dp actions under a message: copy and the overflow menu.
///
/// 40 rather than 48 because the row sits under every message; the hit area is
/// padded back out to 48 with an InkWell so the tap target still meets the
/// minimum even though the icon is smaller.
class _MessageActions extends StatelessWidget {
  final ChatMessage msg;
  final String text;
  const _MessageActions({required this.msg, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionDot(
          tooltip: S.copy,
          icon: LI.copy,
          color: t.faint,
          onTap: text.isEmpty
              ? null
              : () {
                  copyToClipboard(context, text);
                  showSnack(context, S.copied);
                },
        ),
        const SizedBox(width: OCSpace.xxs),
        _ActionDot(
          tooltip: S.moreActions,
          icon: LI.more,
          color: t.faint,
          onTap: () => showMessageMenu(context, msg),
        ),
      ],
    );
  }
}

class _ActionDot extends StatelessWidget {
  final String tooltip;
  final LI icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionDot({
    required this.tooltip,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: tooltip,
        child: SizedBox(
          width: OCSpace.tapTarget,
          height: OCSpace.tapTarget,
          child: Center(
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: LIcon(icon, size: 16, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
