import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'diff_page.dart';
import 'markdown.dart';
import 'models_page.dart';
import 'parts.dart';
import 'widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final focus = FocusNode();

  int _lastCount = 0;
  final _showJump = false;

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    focus.dispose();
    super.dispose();
  }

  void _autoscroll(ChatMessage? last) {
    if (scroll.hasClients) {
      final near = scroll.position.pixels >= scroll.position.maxScrollExtent - 220;
      if (near || last == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scroll.hasClients) {
            scroll.jumpTo(scroll.position.maxScrollExtent);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (store.messages.length != _lastCount) {
      _lastCount = store.messages.length;
      _autoscroll(store.messages.isEmpty ? null : store.messages.last);
    }

    return Column(
      children: [
        if (store.sessionError != null) _ErrorBar(store.sessionError!, () => store.openSession(store.current!.id)),
        if (store.busy) _BusyBar(store.busyStatus),
        Expanded(
          child: store.messagesLoading
              ? const LoadingView(label: 'Messages load ho rahe hain')
              : store.messages.isEmpty
                  ? _Welcome(store, onPick: (s) {
                      input.text = s;
                      input.selection = TextSelection.collapsed(offset: s.length);
                      focus.requestFocus();
                    })
                  : Stack(
                      children: [
                        ListView.builder(
                          controller: scroll,
                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                          itemCount: store.messages.length,
                          itemBuilder: (_, i) {
                            final m = store.messages[i];
                            final next = i + 1 < store.messages.length ? store.messages[i + 1] : null;
                            return _MessageTile(
                              key: ValueKey(m.info.id),
                              msg: m,
                              isLast: next == null,
                              onChanged: () => _autoscroll(m),
                            );
                          },
                        ),
                        if (_showJump)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: FloatingActionButton.small(
                              heroTag: 'jump',
                              onPressed: () => scroll.animateTo(scroll.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                              child: const Icon(Icons.arrow_downward),
                            ),
                          ),
                      ],
                    ),
        ),
        _Composer(store: store, controller: input, focus: focus, onSend: _send, onStop: store.abortSession),
      ],
    );
  }

  Future<void> _send() async {
    final store = AppScope.read(context);
    final text = input.text;
    if (text.trim().isEmpty && store.attachments.isEmpty) return;

    final trimmed = text.trim();
    if (trimmed.startsWith('/')) {
      final sp = trimmed.indexOf(' ');
      final cmd = (sp < 0 ? trimmed : trimmed.substring(0, sp)).substring(1);
      final args = sp < 0 ? '' : trimmed.substring(sp + 1);
      final match = store.commands.where((c) => c.name == cmd).firstOrNull;
      if (match != null) {
        input.clear();
        focus.requestFocus();
        await store.runCommand(cmd, args);
        return;
      }
    }

    if (store.providerId.isEmpty || store.modelId.isEmpty) {
      if (mounted) showSnack(context, 'Pehle model choose karo', error: true);
      return;
    }

    input.clear();
    focus.requestFocus();

    try {
      await store.send(text);
    } catch (e) {
      input.text = text;
      input.selection = TextSelection.collapsed(offset: text.length);
      if (mounted) showSnack(context, '$e', error: true);
    }
    if (mounted) setState(() {});
  }
}

// ---------------------------------------------------------------------

class _ErrorBar extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorBar(this.msg, this.onRetry);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.errorContainer,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 17, color: cs.onErrorContainer),
          const SizedBox(width: 9),
          Expanded(
            child: Text(msg,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: cs.onErrorContainer)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 17,
            color: cs.onErrorContainer,
            icon: const Icon(Icons.close),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _BusyBar extends StatelessWidget {
  final String status;
  const _BusyBar(this.status);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
}

class _Welcome extends StatelessWidget {
  final OcStore store;
  final void Function(String) onPick;
  const _Welcome(this.store, {required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00C2A8)]),
            ),
            child: const Icon(Icons.bolt, size: 32, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Center(child: Text('Kya karna hai?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        const SizedBox(height: 6),
        Center(
          child: Text('Model ${store.providerId}/${store.modelId} · agent ${store.agent}',
              style: TextStyle(fontSize: 12, color: cs.outline)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in const [
              'Is project ka structure samjha aur short me bata',
              'Tests chala kar failures explain kar',
              'Sabse bada TODO file find kar',
              'Ek naya feature plan bana',
            ])
              ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                onPressed: () => onPick(s),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// message bubble
// ---------------------------------------------------------------------

class _MessageTile extends StatefulWidget {
  final ChatMessage msg;
  final bool isLast;
  final VoidCallback onChanged;
  const _MessageTile({super.key, required this.msg, required this.isLast, required this.onChanged});

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile> {
  @override
  Widget build(BuildContext context) {
    final m = widget.msg;
    final cs = Theme.of(context).colorScheme;
    final user = m.info.isUser;

    final text = m.parts.where((p) => p.type == 'text').map((p) => p.text).join('\n').trim();
    final files = m.parts.where((p) => p.type == 'file').toList();
    final others = m.parts.where((p) => p.type != 'text' && p.type != 'file' && p.type != 'step-start' && p.type != 'step-finish').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user)
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final f in files) _IncomingFileChip(f),
                      if (text.isNotEmpty)
                        Markdown(text, base: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontSize: 14.5,
                              height: 1.45,
                            )),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in others) PartTile(p),
                  if (text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Markdown(text, base: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5)),
                    ),
                  if (m.streaming && text.isEmpty && others.isEmpty)
                    const _TypingDots(),
                  if (m.errorText != null) _InlineError(m.errorText!),
                  _MessageFooter(msg: m),
                ],
              ),
            ),
          if (!user) _MessageActions(msg: m),
        ],
      ),
    );
  }
}

class _IncomingFileChip extends StatelessWidget {
  final Part part;
  const _IncomingFileChip(this.part);

  @override
  Widget build(BuildContext context) {
    final isImg = part.mime.startsWith('image/');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isImg ? Icons.image_outlined : Icons.attach_file, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(part.filename.isEmpty ? baseName(part.url) : part.filename,
                style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  const _InlineError(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(Icons.warning_amber, size: 15, color: cs.onErrorContainer),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: cs.onErrorContainer), maxLines: 6, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Opacity(
                  opacity: 0.35 + 0.65 * ((c.value * 3 - i).clamp(0.0, 1.0)),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageFooter extends StatelessWidget {
  final ChatMessage msg;
  const _MessageFooter({required this.msg});

  @override
  Widget build(BuildContext context) {
    final i = msg.info;
    final bits = <String>[
      if (i.providerId.isNotEmpty) '${i.providerId}/${i.modelId}',
      if (i.tokens.total > 0) i.tokens.pretty,
      if (i.cost > 0) '\$${i.cost.toStringAsFixed(4)}',
      if (i.finishReason.isNotEmpty && i.finishReason != 'stop') i.finishReason,
    ];
    if (bits.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Text(bits.join(' · '),
          style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.outline)),
    );
  }
}

class _MessageActions extends StatelessWidget {
  final ChatMessage msg;
  const _MessageActions({required this.msg});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final text = msg.parts.where((p) => p.type == 'text').map((p) => p.text).join('\n');
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 2),
      child: Row(
        children: [
          _TinyBtn(Icons.copy_all_outlined, 'Copy', () => copyToClipboard(context, text)),
          _TinyBtn(Icons.call_split, 'Fork yahan se', () async {
            final s = await store.forkSession(store.current!.id, messageId: msg.info.id);
            if (s != null && context.mounted) {
              await store.openSession(s.id);
              showSnack(context, 'Fork ban gaya');
            }
          }),
          _TinyBtn(Icons.undo, 'Revert', () => store.revert(msg.info.id)),
          _TinyBtn(Icons.delete_outline, 'Delete', () async {
            final ok = await confirmDialog(context,
                title: 'Message delete karein?',
                message: 'Ye message aur uske saare parts hata jayenge.',
                confirm: 'Delete',
                danger: true);
            if (!ok) return;
            try {
              await store.api.deleteMessage(store.current!.id, msg.info.id);
              await store.openSession(store.current!.id);
            } catch (e) {
              if (context.mounted) showSnack(context, '$e', error: true);
            }
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _TinyBtn extends StatelessWidget {
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  const _TinyBtn(this.icon, this.tip, this.onTap);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: 15, color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
}

// ---------------------------------------------------------------------
// composer
// ---------------------------------------------------------------------

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
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (store.attachments.isNotEmpty) _AttachmentStrip(store),
            _QuickBar(store),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Attach / slash command',
                    onPressed: () => _showAttachSheet(context),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SlashTextField(
                        controller: controller,
                        focusNode: focus,
                        store: store,
                        onSubmit: onSend,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (store.busy)
                    IconButton.filled(
                      onPressed: onStop,
                      style: IconButton.styleFrom(backgroundColor: cs.error),
                      icon: const Icon(Icons.stop_rounded),
                    )
                  else
                    IconButton.filled(
                      onPressed: onSend,
                      icon: const Icon(Icons.arrow_upward),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttachSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Image attach karo'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present_outlined),
              title: const Text('File ka content bhejo'),
              subtitle: const Text('Project ke andar se ek file chuno'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickProjectFile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Slash command'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCommands(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final b64 = base64Encode(bytes);
    store.addAttachment(PendingAttachment(
      path: x.path,
      mime: x.mimeType ?? 'image/jpeg',
      name: x.name,
      size: bytes.length,
      dataUrl: 'data:${x.mimeType ?? 'image/jpeg'};base64,$b64',
    ));
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
      store.addAttachment(PendingAttachment(
        path: picked.path,
        mime: _mimeFor(picked.name),
        name: picked.name,
        size: content.length,
        dataUrl: 'data:${_mimeFor(picked.name)};base64,${base64Encode(utf8.encode(content))}',
      ));
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
    final names = {...store.commands.map((c) => c.name), ...builtins}.toList()..sort();
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('COMMANDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            for (final n in names) ListTile(dense: true, leading: const Icon(Icons.code, size: 18), title: Text('/$n', style: const TextStyle(fontSize: 13.5))),
          ],
        ),
      ),
    );
    if (picked != null) {
      final t = controller.text;
      controller.text = t.isEmpty ? '/$picked ' : '$t /$picked ';
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
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
            avatar: Icon(a.mime.startsWith('image/') ? Icons.image_outlined : Icons.description_outlined, size: 17),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text('${a.name} · ${fmtBytes(a.size)}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
            ),
            backgroundColor: cs.surfaceContainerHighest,
            onDeleted: () => store.removeAttachment(i),
          );
        },
      ),
    );
  }
}

class _QuickBar extends StatelessWidget {
  final OcStore store;
  const _QuickBar(this.store);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
        children: [
          ActionChip(
            avatar: Icon(Icons.psychology, size: 15, color: cs.primary),
            label: Text(store.modelId.isEmpty ? 'Model chuno' : store.modelId, style: const TextStyle(fontSize: 11.5)),
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModelsPage())),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: Icon(Icons.smart_toy_outlined, size: 15, color: cs.tertiary),
            label: Text(store.agent, style: const TextStyle(fontSize: 11.5)),
            visualDensity: VisualDensity.compact,
            onPressed: () => _pickAgent(context),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.checklist, size: 15),
            label: Text(
              store.todos.isEmpty
                  ? 'Tasks'
                  : '${store.todos.where((t) => t.done).length}/${store.todos.length}',
              style: const TextStyle(fontSize: 11.5),
            ),
            visualDensity: VisualDensity.compact,
            onPressed: () => store.refreshTodos(),
          ),
          if (store.liveDiff.isNotEmpty) ...[
            const SizedBox(width: 6),
            ActionChip(
              avatar: const Icon(Icons.difference_outlined, size: 15),
              label: Text('${store.liveDiff.length} files', style: const TextStyle(fontSize: 11.5)),
              visualDensity: VisualDensity.compact,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiffPage())),
            ),
          ],
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.build_outlined, size: 15),
            label: Text('Tools (${store.toolsEnabled.length})', style: const TextStyle(fontSize: 11.5)),
            visualDensity: VisualDensity.compact,
            onPressed: () => _pickTools(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAgent(BuildContext context) async {
    final store = AppScope.read(context);
    final agents = store.agents;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('AGENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              for (final a in agents)
                RadioListTile<String>(
                  value: a.name,
                  dense: true,
                  title: Text(a.name, style: const TextStyle(fontSize: 14)),
                  subtitle:
                      a.description.isEmpty ? null : Text(a.description, maxLines: 2, style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTools(BuildContext context) async {
    final store = AppScope.read(context);
    List<String> ids;
    try {
      ids = await store.api.toolIds();
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
      return;
    }
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (c, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    const Expanded(child: Text('TOOLS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    TextButton(
                      onPressed: () {
                        store.toolsEnabled.clear();
                        setSheet(() {});
                      },
                      child: const Text('Sab on'),
                    ),
                  ],
                ),
              ),
              Text('Koi select nahi = sab tools on (default)',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final id in ids)
                      CheckboxListTile(
                        dense: true,
                        value: store.toolsEnabled.contains(id),
                        title: Text(id, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
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
}

/// TextField with inline autocomplete for `/commands` and `@files`.
class SlashTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final OcStore store;
  final VoidCallback onSubmit;
  const SlashTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.store,
    required this.onSubmit,
  });

  @override
  State<SlashTextField> createState() => _SlashTextFieldState();
}

class _SlashTextFieldState extends State<SlashTextField> {
  List<String> _suggestions = [];
  String _mode = '';
  List<String> _files = [];
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusListener = () {
      if (widget.focusNode.hasFocus) _onChanged();
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid || !sel.isCollapsed) return _set([]);

    final upto = text.substring(0, sel.baseOffset);
    final slash = RegExp(r'(?:^|\s)/([\w-]*)$').firstMatch(upto);
    if (slash != null) {
      final q = slash.group(1)!.toLowerCase();
      final names = widget.store.commands.map((c) => c.name).toSet()
        ..addAll(const ['init', 'compact', 'undo', 'redo', 'share', 'clear']);
      return _set(names.where((n) => n.startsWith(q)).take(8).toList(), mode: '/');
    }
    final at = RegExp(r'(?:^|\s)@([\w./-]*)$').firstMatch(upto);
    if (at != null) {
      final q = at.group(1)!.toLowerCase();
      _mode = '@';
      _searchFiles(q);
      return;
    }
    _set([]);
  }

  void _searchFiles(String q) async {
    try {
      final list = await widget.store.api.findFiles(q.isEmpty ? ' ' : q, limit: 8);
      if (!mounted || _mode != '@') return;
      setState(() => _files = list);
    } catch (_) {/* ignore */}
  }

  void _set(List<String> s, {String mode = ''}) {
    if (!mounted) return;
    if (s.length == _suggestions.length && mode == _mode && s.join() == _suggestions.join()) return;
    setState(() {
      _suggestions = s;
      _mode = mode;
    });
  }

  void _apply(String token) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid) return;
    final upto = text.substring(0, sel.baseOffset);
    final pattern = _mode == '@' ? RegExp(r'(?:^|\s)@[\w./-]*$') : RegExp(r'(?:^|\s)/[\w-]*$');
    final m = pattern.firstMatch(upto);
    if (m == null) return;
    final start = sel.baseOffset - m.group(0)!.length;
    final prefix = _mode == '@' ? '' : (m.group(0)!.startsWith(' ') ? '' : '');
    final insert = '$_mode$token ';
    final next = text.replaceRange(start, sel.baseOffset, '$prefix$insert');
    widget.controller.text = next;
    widget.controller.selection = TextSelection.collapsed(offset: start + insert.length);
    _set([]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showList = _suggestions.isNotEmpty || (_mode == '@' && _files.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          minLines: 1,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          onSubmitted: (_) => widget.onSubmit(),
          style: const TextStyle(fontSize: 14.5, height: 1.4),
          decoration: InputDecoration(
            hintText: 'Message likho…  (/command  @file)',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            suffixIcon: widget.controller.text.isEmpty
                ? null
                : IconButton(
                    iconSize: 17,
                    icon: const Icon(Icons.close),
                    onPressed: widget.controller.clear,
                  ),
          ),
        ),
        if (showList)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 190),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final s in _suggestions)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(Icons.code, size: 15),
                    title: Text(s, style: const TextStyle(fontSize: 12.5)),
                    subtitle: widget.store.commands
                            .where((c) => c.name == s)
                            .map((c) => c.description)
                            .firstOrNull
                            ?.let((d) => Text(d, style: const TextStyle(fontSize: 10.5))),
                    onTap: () => _apply(s),
                  ),
                for (final f in _files)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(Icons.insert_drive_file_outlined, size: 15),
                    title: Text(baseName(f), style: const TextStyle(fontSize: 12.5)),
                    subtitle: Text(f, style: TextStyle(fontSize: 10.5, color: cs.outline), overflow: TextOverflow.ellipsis),
                    onTap: () => _apply(f),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

class _FilePickerSheet extends StatefulWidget {
  const _FilePickerSheet();

  @override
  State<_FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends State<_FilePickerSheet> {
  String dir = '.';
  List<FileNode> nodes = [];
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? d]) async {
    setState(() {
      loading = true;
      err = null;
      if (d != null) dir = d;
    });
    try {
      final list = await AppScope.read(context).api.files(dir);
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        return a.name.compareTo(b.name);
      });
      if (!mounted) return;
      setState(() {
        nodes = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        err = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(
              children: [
                if (dir != '.')
                  IconButton(
                    iconSize: 19,
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => _load(dir == '.' ? '.' : dirName(dir)),
                  ),
                Expanded(child: Mono(dir == '.' ? 'project root' : dir, size: 12)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const LoadingView()
                : err != null
                    ? EmptyHint(icon: Icons.error_outline, title: 'Load nahi hua', message: err!)
                    : nodes.isEmpty
                        ? const EmptyHint(icon: Icons.folder_off_outlined, title: 'Khaali', message: 'Yahan koi file nahi.')
                        : ListView.builder(
                            itemCount: nodes.length,
                            itemBuilder: (_, i) {
                              final n = nodes[i];
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  n.isDir ? Icons.folder_outlined : _iconFor(n.name),
                                  size: 19,
                                  color: n.isDir ? Theme.of(context).colorScheme.primary : null,
                                ),
                                title: Text(n.name, style: const TextStyle(fontSize: 13)),
                                onTap: () => n.isDir ? _load(n.path) : Navigator.pop(context, n),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => Icons.code,
      'js' || 'ts' || 'jsx' || 'tsx' => Icons.javascript,
      'py' => Icons.code,
      'json' => Icons.data_object,
      'md' => Icons.article_outlined,
      'yaml' || 'yml' => Icons.settings_input_component,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => Icons.image_outlined,
      'sh' => Icons.terminal,
      'lock' => Icons.lock_outline,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}
