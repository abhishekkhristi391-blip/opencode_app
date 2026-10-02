import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final input = TextEditingController();
  final out = TextEditingController();
  final scroll = ScrollController();
  final history = <String>[];
  int historyIndex = -1;

  bool running = false;
  bool wrap = true;

  final shortcuts = <String, String>{
    'pwd': 'pwd',
    'ls': 'ls -la',
    'git status': 'git status',
    'git log': 'git log --oneline -20',
    'git diff': 'git diff',
    'disk': 'df -h .',
    'node version': 'node -v; bun --version 2>/dev/null; python3 -V',
    'opencode': 'opencode --version',
    'tree': 'find . -maxdepth 2 -not -path "*/.git/*" | head -80',
    'clear': 'clear',
  };

  @override
  void dispose() {
    input.dispose();
    out.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _append(String s) {
    out.text += s.endsWith('\n') ? s : '$s\n';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
    setState(() {});
  }

  Future<void> _run([String? cmd]) async {
    final command = (cmd ?? input.text).trim();
    if (command.isEmpty || running) return;
    if (command == 'clear') {
      out.clear();
      input.clear();
      return;
    }
    setState(() => running = true);
    if (input.text.isNotEmpty) {
      history.insert(0, command);
      historyIndex = -1;
    }
    _append(r'$ $command');
    input.clear();
    try {
      final r = await AppScope.read(context).runShell(command);
      if (r.output.trim().isNotEmpty) _append(r.output.trimRight());
      _append('[exit ${r.exit}]');
    } catch (e) {
      _append('error: $e');
    }
    if (mounted) setState(() => running = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = AppScope.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          color: cs.surfaceContainerHigh,
          child: Row(
            children: [
              Icon(Icons.terminal, size: 16, color: cs.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(store.paths?.directory ?? store.baseUrl,
                    style: TextStyle(fontSize: 11, color: cs.outline),
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                tooltip: 'Output clear',
                iconSize: 17,
                icon: const Icon(Icons.backspace_outlined),
                onPressed: out.clear,
              ),
              IconButton(
                tooltip: 'Wrap',
                iconSize: 17,
                icon: Icon(wrap ? Icons.wrap_text : Icons.horizontal_rule),
                onPressed: () => setState(() => wrap = !wrap),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              for (final e in shortcuts.entries) ...[
                ActionChip(
                  label: Text(e.key, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  onPressed: running ? null : () => _run(e.value),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
Expanded(
          child: Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: out.text.isEmpty
                ? Center(
                    child: Text('Command likho aur Enter dabao.\nShortcut upar diye hain.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7), fontSize: 12.5, height: 1.6)),
                  )
                : SingleChildScrollView(
                    controller: scroll,
                    padding: const EdgeInsets.all(12),
                    child: wrap
                        ? Text(out.text, style: _terminalStyle(context))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(out.text, style: _terminalStyle(context)),
                          ),
                  ),
        ),
        ),
        if (running)
          const LinearProgressIndicator(minHeight: 2),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Text('\$', style: TextStyle(color: cs.primary, fontFamily: 'monospace', fontSize: 15)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is! KeyDownEvent) return KeyEventResult.ignored;
                        if (event.logicalKey != LogicalKeyboardKey.arrowUp &&
                            event.logicalKey != LogicalKeyboardKey.arrowDown) {
                          return KeyEventResult.ignored;
                        }
                        if (history.isEmpty) return KeyEventResult.ignored;
                        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          setState(() => historyIndex = (historyIndex + 1).clamp(0, history.length - 1));
                        } else {
                          setState(() => historyIndex = (historyIndex - 1).clamp(-1, history.length - 1));
                        }
                        final v = historyIndex < 0 ? '' : history[historyIndex];
                        input.text = v;
                        input.selection = TextSelection.collapsed(offset: v.length);
                        return KeyEventResult.handled;
                      },
                      child: TextField(
                        controller: input,
                        enabled: !running,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'command',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _run(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: running ? null : () => _run(),
                    icon: const Icon(Icons.send, size: 19),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static TextStyle _terminalStyle(BuildContext context) => TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['monospace'],
    fontSize: 12,
    height: 1.45,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
