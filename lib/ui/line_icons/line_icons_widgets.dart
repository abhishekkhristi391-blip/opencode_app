part of '../line_icons.dart';

/// The glyphs the redesign draws. Names mirror the reference's icons.
enum LI {
  /// Speech bubble: header, bottom nav.
  chat,

  /// Clock: History tab.
  history,

  /// Folder: Files tab.
  folder,

  /// `>_`: Terminal tab.
  terminal,

  /// Checklist: Tasks / Todos.
  tasks,

  /// New chat.
  plus,

  /// Overflow. Three VERTICAL dots - the designs' `more_vert`, 16 uses.
  more,

  /// `more_horiz`, 3 uses.
  moreHoriz,


  /// Up arrow: send.
  send,

  /// Square: stop a running turn.
  stop,

  /// Accordion affordances, pickers.
  chevronDown,
  chevronRight,

  /// `expand_less`.
  chevronUp,

  /// Composer attachment.
  attach,

  /// Row actions.
  copy,
  undo,
  trash,

  /// Jump to latest.
  arrowDown,

  /// Dismiss: error bar, inline editor clear.
  close,

  /// Search.
  search,

  /// Model pill.
  tune,

  /// Session rows.
  check,

  /// Fork a message / branch a session.
  fork,

  /// Header status.
  dot,

  /// Empty / error states.
  spark,
  warning,

  /// Footer nav extras.
  refresh,
  download,

  /// Keyboard shortcuts.
  keyboard,

  /// Settings.
  settings,

  /// Mark read.
  done,

  // --- added for the redesign ---------------------------------------------

  /// `menu`: hamburger, 16 uses across every screen header.
  menu,

  /// `person`: the avatar popup trigger, 15 uses.
  person,

  /// `add_comment`: the new-chat FAB, 15 uses.
  newComment,

  /// `arrow_outward` / `north_east`: share, open-in-editor, diff links.
  externalLink,

  /// `bolt`: a running or active agent.
  bolt,

  /// `hourglass_top`: waiting on the server.
  hourglass,

  /// `keyboard_return`: the composer's return hint.
  enter,

  /// `logout`: sign out.
  logout,

  /// `shield`: permission requests.
  shield,

  /// `key`: provider API keys.
  key,

  /// `lock`: an authenticated server.
  lock,

  /// `info`: informational rows (MCP, LSP, colour mode).
  info,

  /// `dns`: a host / server row in the avatar menu.
  server,

  /// `code` / `code_blocks`: code file kinds, terminal.
  code,

  /// `save`: the file editor.
  save,

  /// `description`: a file row.
  doc,

  /// `psychology`: agents.
  brain,

  /// `smart_toy`: MCP servers.
  robot,

  /// `arrow_back`: sheets and sub-screens.
  arrowBack,

  /// `difference`: the diff viewer.
  diff,

  /// `mic`: dictation in the composer, and the voice settings row.
  mic,

  /// `volume_up`: read aloud under a reply, and while it is playing.
  volume,
}

class LIcon extends StatelessWidget {
  const LIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = _stroke,
  });

  final LI icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: LLinePainter(
            icon: icon,
            color: resolved,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

/// A tappable line icon. The glyph keeps its own size; the hit area is grown to
/// the 48dp minimum with [OCSpace.tapTarget] rather than by padding arithmetic,
/// so shrinking the glyph can never shrink the target.
class LIconButton extends StatelessWidget {
  const LIconButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.label,
    this.size = 22,
    this.color,
    this.strokeWidth = _stroke,
    this.padding = const EdgeInsets.all(10),
    this.semanticLabel,
  });

  final LI icon;
  final VoidCallback? onTap;
  final String? label;
  final double size;
  final Color? color;
  final double strokeWidth;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    final enabled = onTap != null;
    final glyph = Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: LIcon(
          icon,
          size: size,
          color: resolved,
          strokeWidth: strokeWidth,
        ),
      ),
    );
    final target = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: OCSpace.tapTarget,
        minHeight: OCSpace.tapTarget,
      ),
      child: Padding(padding: padding, child: Center(child: glyph)),
    );
    if (!enabled) return target;
    return InkResponse(
      onTap: onTap,
      radius: size * 1.1,
      containedInkWell: false,
      child: target,
    );
  }
}

/// The designs' stroke. Every glyph defaults to it.
const double _stroke = 1.5;
