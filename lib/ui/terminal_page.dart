import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';

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
    final store = AppScope.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.md,
            OCSpace.sm,
            OCSpace.md,
            OCSpace.sm,
          ),
          color: OCColors.surfaceMuted,
          child: Row(
            children: [
              const OCIconTile(
                icon: Icons.terminal,
                accent: OCAccent.neutral,
                size: 26,
                iconSize: 15,
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: Text(
                  store.paths?.directory ?? store.baseUrl,
                  style: OCTypography.micro,
                  overflow: TextOverflow.ellipsis,
                ),
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
          height: OCSpace.tapTarget,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
            children: [
              for (final e in shortcuts.entries) ...[
                ActionChip(
                  label: Text(
                    e.key,
                    style: OCTypography.micro.copyWith(
                      color: OCColors.textSecondary,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: running ? null : () => _run(e.value),
                ),
                const SizedBox(width: OCSpace.sm),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: OCColors.borderHairline),
        Expanded(
          child: Container(
            width: double.infinity,
            color: OCColors.surfaceSubtle,
            child: out.text.isEmpty
                ? Center(
                    child: Text(
                      'Command likho aur Enter dabao.\nShortcut upar diye hain.',
                      textAlign: TextAlign.center,
                      style: OCTypography.caption.copyWith(
                        height: 1.6,
                        color: OCColors.textTertiary,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    controller: scroll,
                    padding: const EdgeInsets.all(OCSpace.md),
                    child: wrap
                        ? Text(out.text, style: _terminalStyle(context))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              out.text,
                              style: _terminalStyle(context),
                            ),
                          ),
                  ),
          ),
        ),
        if (running) const OCProgressBar(value: 1, height: 4, animate: false),
        Container(
          decoration: const BoxDecoration(
            color: OCColors.surface,
            border: Border(top: BorderSide(color: OCColors.borderHairline)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                OCSpace.md,
                OCSpace.sm,
                OCSpace.sm,
                OCSpace.sm,
              ),
              child: Row(
                children: [
                  Text(
                    '\$',
                    style: OCTypography.mono(color: OCColors.orange, size: 15),
                  ),
                  Expanded(
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is! KeyDownEvent)
                          return KeyEventResult.ignored;
                        if (event.logicalKey != LogicalKeyboardKey.arrowUp &&
                            event.logicalKey != LogicalKeyboardKey.arrowDown) {
                          return KeyEventResult.ignored;
                        }
                        if (history.isEmpty) return KeyEventResult.ignored;
                        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          setState(
                            () => historyIndex = (historyIndex + 1).clamp(
                              0,
                              history.length - 1,
                            ),
                          );
                        } else {
                          setState(
                            () => historyIndex = (historyIndex - 1).clamp(
                              -1,
                              history.length - 1,
                            ),
                          );
                        }
                        final v = historyIndex < 0 ? '' : history[historyIndex];
                        input.text = v;
                        input.selection = TextSelection.collapsed(
                          offset: v.length,
                        );
                        return KeyEventResult.handled;
                      },
                      child: TextField(
                        controller: input,
                        enabled: !running,
                        style: OCTypography.mono(
                          size: 13.5,
                          color: OCColors.textPrimary,
                        ),
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
                  IconButton.filled(
                    onPressed: running ? null : () => _run(),
                    style: IconButton.styleFrom(
                      backgroundColor: OCColors.orange,
                    ),
                    icon: const Icon(
                      Icons.send,
                      size: 18,
                      color: OCColors.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static TextStyle _terminalStyle(BuildContext context) => OCTypography.mono(
    size: 12,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
