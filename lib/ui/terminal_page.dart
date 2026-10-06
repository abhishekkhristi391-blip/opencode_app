import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';
import '../state/store.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => TerminalPageState();
}

class TerminalPageState extends State<TerminalPage> {
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

  /// Called by the shell header. `clear` as a command only works while the
  /// shell has a PTY attached, so clearing the scrollback has to be a local
  /// action.
  void clear() {
    out.clear();
    setState(() {});
  }

  /// Runs `clear` and drops the stale scrollback, so "New session" visibly
  /// resets the view instead of leaving the old output behind it.
  void newSession() {
    out.clear();
    history.clear();
    historyIndex = -1;
    _run('clear');
  }

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
          color: context.oc.card,
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
                  style: OCTypography.caption.copyWith(color: context.oc.mute),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: S.termClearTooltip,
                iconSize: 17,
                color: context.oc.mute,
                icon: const Icon(Icons.backspace_outlined),
                onPressed: clear,
              ),
              IconButton(
                tooltip: S.termWrap,
                iconSize: 17,
                color: context.oc.mute,
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
                    style: OCTypography.micro.copyWith(color: context.oc.mute),
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: running ? null : () => _run(e.value),
                ),
                const SizedBox(width: OCSpace.sm),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: context.oc.line),
        Expanded(
          child: Container(
            width: double.infinity,
            // The reference's `rounded-lg` well, inset from the canvas.
            margin: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
            decoration: BoxDecoration(
              color: context.oc.terminalBg,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: out.text.isEmpty
                ? Center(
                    child: Text(
                      S.terminalEmpty,
                      textAlign: TextAlign.center,
                      style: OCTypography.caption.copyWith(
                        height: 1.6,
                        color: context.oc.mute,
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
          decoration: BoxDecoration(
            // The reference's prompt row is a `container-lowest` pill, not a
            // top-bordered strip: the border made the bar read as a divider
            // between the output and the keyboard rather than as an input.
            color: context.oc.terminalBg,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
          clipBehavior: Clip.antiAlias,
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
                    style: OCTypography.mono(color: context.oc.acc, size: 15),
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
                          color: context.oc.terminalInk,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: S.termPrompt,
                          hintStyle: OCTypography.mono(
                            size: 13.5,
                            color: context.oc.faint,
                          ),
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
                      backgroundColor: context.oc.acc,
                    ),
                    icon: Icon(Icons.send, size: 18, color: context.oc.onAcc),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Always the terminal palette, never the page's ink: a shell transcript that
  /// switches to the app's foreground colour stops reading as a terminal.
  static TextStyle _terminalStyle(BuildContext context) =>
      OCTypography.mono(size: 12, color: context.oc.terminalInk);
}
