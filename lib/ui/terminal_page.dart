import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => TerminalPageState();
}

class TerminalPageState extends State<TerminalPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final history = <String>[];

  /// The scrollback, one entry per line. Kept as a list rather than one giant
  /// string so it can be capped and paged without rebuilding the whole buffer.
  final _lines = <String>[];

  /// Hard ceiling on retained lines; oldest are dropped past this, like a real
  /// terminal's scrollback limit.
  static const _scrollbackLimit = 5000;

  /// Lines painted at once before the rest fold behind "Show more".
  static const _visibleLines = 500;

  bool _showAll = false;
  int historyIndex = -1;

  bool running = false;
  bool wrap = true;

  /// Last failed command, kept so the error bar can offer a one-tap re-run.
  String? _lastError;
  String? _lastErrorCommand;

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
    _lines.clear();
    _showAll = false;
    setState(() {});
  }

  /// Runs `clear` and drops the stale scrollback, so "New session" visibly
  /// resets the view instead of leaving the old output behind it.
  void newSession() {
    _lines.clear();
    _showAll = false;
    history.clear();
    historyIndex = -1;
    _run('clear');
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _append(String s) {
    // Split multi-line output so the cap is line-accurate, and drop any trailing
    // newline rather than storing a blank line for it.
    final text = s.endsWith('\n') ? s.substring(0, s.length - 1) : s;
    _lines.addAll(text.split('\n'));
    if (_lines.length > _scrollbackLimit) {
      _lines.removeRange(0, _lines.length - _scrollbackLimit);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
    setState(() {});
  }

  Future<void> _run([String? cmd]) async {
    final command = (cmd ?? input.text).trim();
    if (command.isEmpty || running) return;
    if (command == 'clear') {
      _lines.clear();
      _showAll = false;
      input.clear();
      setState(() {});
      return;
    }
    setState(() {
      running = true;
      _lastError = null;
      _lastErrorCommand = null;
    });
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
      if (mounted) {
        setState(() {
          _lastError = '$e';
          _lastErrorCommand = command;
        });
      }
    }
    if (mounted) setState(() => running = false);
  }

  /// The scrollback well, capped to the newest [_visibleLines] until the user
  /// asks for the rest. Building a single Text from the whole buffer made a
  /// long-running shell progressively slower to paint.
  Widget _buildOutput(BuildContext context) {
    final total = _lines.length;
    final truncated = total > _visibleLines;
    final start = (!truncated || _showAll) ? 0 : total - _visibleLines;
    final visible = _lines.sublist(start).join('\n');
    return Column(
      children: [
        if (truncated)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.xs),
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              icon: Icon(
                _showAll ? Icons.expand_less : Icons.expand_more,
                size: 15,
              ),
              label: Text(
                _showAll ? S.showLess : S.showMore,
                style: OCTypography.micro,
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.all(OCSpace.md),
            child: wrap
                ? Text(visible, style: _terminalStyle(context))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(visible, style: _terminalStyle(context)),
                  ),
          ),
        ),
      ],
    );
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
            child: _lines.isEmpty
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
                : _buildOutput(context),
          ),
        ),
        if (_lastError != null)
          Container(
            margin: const EdgeInsets.fromLTRB(
              OCSpace.sm,
              0,
              OCSpace.sm,
              OCSpace.xs,
            ),
            padding: const EdgeInsets.fromLTRB(
              OCSpace.md,
              OCSpace.xs,
              OCSpace.sm,
              OCSpace.xs,
            ),
            decoration: BoxDecoration(
              color: context.oc.errSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 15, color: context.oc.err),
                const SizedBox(width: OCSpace.sm),
                Expanded(
                  child: Text(
                    _lastError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.micro.copyWith(color: context.oc.err),
                  ),
                ),
                TextButton(
                  onPressed: running
                      ? null
                      : () => _run(_lastErrorCommand ?? ''),
                  child: Text(
                    S.retry,
                    style: OCTypography.micro.copyWith(color: context.oc.err),
                  ),
                ),
              ],
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
