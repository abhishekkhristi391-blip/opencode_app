// Hand-rolled line icons.
//
// The visual reference (design/clean-chat-ui.html) uses outline glyphs with a
// 1.8 stroke and round caps, not Material's filled icons. Flutter has no font
// of its own that matches, so the handful of glyphs the redesign needs are
// drawn here on a 24x24 grid.
//
// Add a glyph by extending [LI] and adding one `case` to [LLinePainter].
// Prefer keeping the shape to straight lines, quadratics and `addArc` on a
// circle whose start point matches the current point.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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

  /// Overflow.
  more,

  /// Voice input (5 bars).
  mic,

  /// Up arrow: send.
  send,

  /// Square: stop a running turn.
  stop,

  /// Accordion affordances, pickers.
  chevronDown,
  chevronRight,

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
}

class LIcon extends StatelessWidget {
  const LIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 1.8,
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

/// A tappable line icon. Sets the 44px minimum tap target the platform
/// guidelines want without changing the glyph size.
class LIconButton extends StatelessWidget {
  const LIconButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.label,
    this.size = 22,
    this.color,
    this.strokeWidth = 1.8,
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
    if (!enabled) return Padding(padding: padding, child: glyph);
    return InkResponse(
      onTap: onTap,
      radius: size * 1.1,
      containedInkWell: false,
      child: Padding(padding: padding, child: glyph),
    );
  }
}

class LLinePainter extends CustomPainter {
  LLinePainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final LI icon;
  final Color color;
  final double strokeWidth;

  static const double _grid = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    if (scale <= 0) return;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      // Dividing by the scale keeps the on-screen stroke exactly strokeWidth
      // regardless of the glyph size.
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    _draw(canvas, stroke, fill);
    canvas.restore();
  }

  // Small builder so the `case` bodies stay readable.
  Path _path(void Function(Path p) build) {
    final p = Path();
    build(p);
    return p;
  }

  void _draw(Canvas canvas, Paint stroke, Paint fill) {
    switch (icon) {
      case LI.chat:
        // Rounded square bubble with a tail on the lower left.
        canvas.drawPath(
          _path((p) {
            p.moveTo(6, 4.5);
            p.lineTo(18, 4.5);
            p.quadraticBezierTo(21, 4.5, 21, 7.5);
            p.lineTo(21, 15.5);
            p.quadraticBezierTo(21, 18.5, 18, 18.5);
            p.lineTo(11, 18.5);
            p.lineTo(6.5, 21.5);
            p.quadraticBezierTo(5.2, 22.2, 5.5, 20.6);
            p.lineTo(6.2, 18.6);
            p.quadraticBezierTo(3, 18.4, 3, 15.5);
            p.lineTo(3, 7.5);
            p.quadraticBezierTo(3, 4.5, 6, 4.5);
          }),
          stroke,
        );

      case LI.history:
        canvas.drawCircle(const Offset(12, 12), 8.5, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 7.5);
            p.lineTo(12, 12);
            p.lineTo(15.2, 14.2);
          }),
          stroke,
        );

      case LI.folder:
        canvas.drawPath(
          _path((p) {
            p.moveTo(3.5, 6.5);
            p.lineTo(9.5, 6.5);
            p.lineTo(11.5, 8.8);
            p.lineTo(20.5, 8.8);
            p.lineTo(20.5, 18.5);
            p.lineTo(3.5, 18.5);
            p.close();
          }),
          stroke,
        );

      case LI.terminal:
        canvas.drawPath(
          _path((p) {
            p.moveTo(5.5, 7.5);
            p.lineTo(10, 12);
            p.lineTo(5.5, 16.5);
            p.moveTo(12.5, 16.8);
            p.lineTo(19, 16.8);
          }),
          stroke,
        );

      case LI.tasks:
        canvas.drawPath(
          _path((p) {
            p.moveTo(3.5, 6.6);
            p.lineTo(5.4, 8.5);
            p.lineTo(8.6, 4.8);
            p.moveTo(3.5, 16.6);
            p.lineTo(5.4, 18.5);
            p.lineTo(8.6, 14.8);
            p.moveTo(12, 6.6);
            p.lineTo(20.5, 6.6);
            p.moveTo(12, 16.6);
            p.lineTo(20.5, 16.6);
          }),
          stroke,
        );

      case LI.plus:
      case LI.attach:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 4.5);
            p.lineTo(12, 19.5);
            p.moveTo(4.5, 12);
            p.lineTo(19.5, 12);
          }),
          stroke,
        );

      case LI.more:
        for (final cx in const [6.0, 12.0, 18.0]) {
          canvas.drawCircle(Offset(cx, 12), 1.25, fill);
        }

      case LI.mic:
        // Five vertical bars, tallest in the middle: the reference's voice icon.
        const bars = <double, double>{
          4: 2.6,
          8: 6.4,
          12: 9.4,
          16: 5.4,
          20: 2.6,
        };
        bars.forEach((x, h) {
          canvas.drawPath(
            _path((p) {
              p.moveTo(x, 12 - h / 2);
              p.lineTo(x, 12 + h / 2);
            }),
            stroke,
          );
        });

      case LI.send:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 19.5);
            p.lineTo(12, 4.5);
            p.moveTo(4.8, 11.7);
            p.lineTo(12, 4.5);
            p.lineTo(19.2, 11.7);
          }),
          stroke,
        );

      case LI.stop:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(7.5, 7.5, 9, 9),
            const Radius.circular(2.2),
          ),
          fill,
        );

      case LI.chevronDown:
        canvas.drawPath(
          _path((p) {
            p.moveTo(5.5, 9);
            p.lineTo(12, 15.5);
            p.lineTo(18.5, 9);
          }),
          stroke,
        );

      case LI.chevronRight:
        canvas.drawPath(
          _path((p) {
            p.moveTo(9, 5.5);
            p.lineTo(15.5, 12);
            p.lineTo(9, 18.5);
          }),
          stroke,
        );

      case LI.copy:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9.5, 9.5, 11, 11),
            const Radius.circular(2.2),
          ),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(5.5, 15.5);
            p.lineTo(5.5, 6);
            p.quadraticBezierTo(5.5, 4.5, 7, 4.5);
            p.lineTo(15.5, 4.5);
          }),
          stroke,
        );

      case LI.undo:
        // Arrow curving back over a semicircle.
        canvas.drawPath(
          _path((p) {
            p.moveTo(9.5, 14.5);
            p.lineTo(4, 9);
            p.lineTo(9.5, 3.5);
            p.moveTo(4, 9);
            p.lineTo(14, 9);
            p.addArc(
              Rect.fromCircle(center: const Offset(14, 15), radius: 6),
              -math.pi / 2,
              math.pi,
            );
          }),
          stroke,
        );

      case LI.trash:
        canvas.drawPath(
          _path((p) {
            p.moveTo(4, 7);
            p.lineTo(20, 7);
            p.moveTo(9.5, 7);
            p.lineTo(9.5, 4.5);
            p.lineTo(14.5, 4.5);
            p.lineTo(14.5, 7);
            p.moveTo(6.5, 7);
            p.lineTo(7.6, 20);
            p.lineTo(16.4, 20);
            p.lineTo(17.5, 7);
          }),
          stroke,
        );

      case LI.arrowDown:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 4.5);
            p.lineTo(12, 19.5);
            p.moveTo(4.8, 12.3);
            p.lineTo(12, 19.5);
            p.lineTo(19.2, 12.3);
          }),
          stroke,
        );

      case LI.close:
        canvas.drawPath(
          _path((p) {
            p.moveTo(6, 6);
            p.lineTo(18, 18);
            p.moveTo(18, 6);
            p.lineTo(6, 18);
          }),
          stroke,
        );

      case LI.search:
        canvas.drawCircle(const Offset(10.8, 10.8), 6.8, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(15.8, 15.8);
            p.lineTo(20, 20);
          }),
          stroke,
        );

      case LI.tune:
        canvas.drawCircle(const Offset(12, 12), 3.1, stroke);
        for (final (start, sweep) in const [
          (-math.pi / 2, 0.0),
          (math.pi / 2, 0.0),
          (math.pi, 0.0),
          (0.0, 0.0),
        ]) {
          canvas.drawPath(
            _path((p) {
              p.addArc(
                Rect.fromCircle(center: const Offset(12, 12), radius: 5.6),
                start,
                sweep,
              );
            }),
            stroke,
          );
        }
        for (final offset in const [
          Offset(12, 2.6),
          Offset(12, 21.4),
          Offset(2.6, 12),
          Offset(21.4, 12),
        ]) {
          canvas.drawPath(
            _path((p) {
              p.moveTo(offset.dx, offset.dy);
              p.lineTo(
                offset.dx + (12 - offset.dx) * 0.34,
                offset.dy + (12 - offset.dy) * 0.34,
              );
            }),
            stroke,
          );
        }

      case LI.check:
        canvas.drawPath(
          _path((p) {
            p.moveTo(4.5, 12.8);
            p.lineTo(9.6, 17.8);
            p.lineTo(19.5, 6.5);
          }),
          stroke,
        );

      case LI.fork:
        canvas.drawPath(
          _path((p) {
            p.moveTo(7, 3.5);
            p.lineTo(7, 10);
            p.lineTo(17, 10);
            p.lineTo(17, 3.5);
            p.moveTo(12, 10);
            p.lineTo(12, 15.5);
          }),
          stroke,
        );

      case LI.dot:
        canvas.drawCircle(const Offset(12, 12), 3.6, fill);

      case LI.spark:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 3);
            p.lineTo(13.9, 10.1);
            p.lineTo(21, 12);
            p.lineTo(13.9, 13.9);
            p.lineTo(12, 21);
            p.lineTo(10.1, 13.9);
            p.lineTo(3, 12);
            p.lineTo(10.1, 10.1);
            p.close();
          }),
          stroke,
        );

      case LI.warning:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 4);
            p.lineTo(21, 19.5);
            p.lineTo(3, 19.5);
            p.close();
            p.moveTo(12, 10);
            p.lineTo(12, 14);
          }),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 16.7), 0.95, fill);

      case LI.refresh:
        canvas.drawPath(
          _path((p) {
            p.addArc(
              Rect.fromCircle(center: const Offset(12, 12), radius: 8.2),
              -math.pi * 0.75,
              math.pi * 1.4,
            );
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(15.6, 2.6);
            p.lineTo(18.6, 6.4);
            p.lineTo(13.8, 7);
          }),
          stroke,
        );

      case LI.download:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 3.5);
            p.lineTo(12, 14.5);
            p.moveTo(7.5, 10);
            p.lineTo(12, 14.5);
            p.lineTo(16.5, 10);
            p.moveTo(4.5, 19.5);
            p.lineTo(19.5, 19.5);
          }),
          stroke,
        );

      case LI.keyboard:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2.8, 6, 18.4, 12),
            const Radius.circular(2.2),
          ),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(7, 17);
            p.lineTo(17, 17);
            p.moveTo(6.4, 10);
            p.lineTo(6.5, 10);
            p.moveTo(10.2, 10);
            p.lineTo(10.3, 10);
            p.moveTo(14, 10);
            p.lineTo(14.1, 10);
            p.moveTo(17.8, 10);
            p.lineTo(17.9, 10);
          }),
          stroke,
        );

      case LI.settings:
        // Gear: circle plus eight teeth, matching the reference's
        // circle-in-circle-with-ticks treatment.
        canvas.drawCircle(const Offset(12, 12), 3.4, stroke);
        canvas.drawCircle(const Offset(12, 12), 7.2, stroke);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawPath(
            _path((p) {
              p.moveTo(12 + d.dx * 7.2, 12 + d.dy * 7.2);
              p.lineTo(12 + d.dx * 9.4, 12 + d.dy * 9.4);
            }),
            stroke,
          );
        }

      case LI.done:
        canvas.drawCircle(const Offset(12, 12), 8.6, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(8, 12.3);
            p.lineTo(11, 15.2);
            p.lineTo(16.3, 9);
          }),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant LLinePainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}
