part of '../line_icons.dart';

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

        break;
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

        break;
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

        break;
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

        break;
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

        break;
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

        break;
      case LI.more:
        // Vertical dots: the designs' `more_vert` is the overflow affordance on
        // rows and in the header.
        for (final cy in const [6.0, 12.0, 18.0]) {
          canvas.drawCircle(Offset(12, cy), 1.25, fill);
        }

        break;
      case LI.moreHoriz:
        for (final cx in const [6.0, 12.0, 18.0]) {
          canvas.drawCircle(Offset(cx, 12), 1.25, fill);
        }

        break;
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

        break;
      case LI.stop:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(7.5, 7.5, 9, 9),
            const Radius.circular(2.2),
          ),
          fill,
        );

        break;
      case LI.chevronDown:
        canvas.drawPath(
          _path((p) {
            p.moveTo(5.5, 9);
            p.lineTo(12, 15.5);
            p.lineTo(18.5, 9);
          }),
          stroke,
        );

        break;
      case LI.chevronRight:
        canvas.drawPath(
          _path((p) {
            p.moveTo(9, 5.5);
            p.lineTo(15.5, 12);
            p.lineTo(9, 18.5);
          }),
          stroke,
        );

        break;
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

        break;
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

        break;
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

        break;
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

        break;
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

        break;
      case LI.search:
        canvas.drawCircle(const Offset(10.8, 10.8), 6.8, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(15.8, 15.8);
            p.lineTo(20, 20);
          }),
          stroke,
        );

        break;
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

        break;
      case LI.check:
        canvas.drawPath(
          _path((p) {
            p.moveTo(4.5, 12.8);
            p.lineTo(9.6, 17.8);
            p.lineTo(19.5, 6.5);
          }),
          stroke,
        );

        break;
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

        break;
      case LI.dot:
        canvas.drawCircle(const Offset(12, 12), 3.6, fill);

        break;
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

        break;
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

        break;
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

        break;
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

        break;
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

        break;
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

        break;
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

      // --- added for the redesign -------------------------------------------

        break;
      case LI.menu:
        for (final y in const [7.0, 12.0, 17.0]) {
          canvas.drawPath(
            _path((p) {
              p.moveTo(4, y);
              p.lineTo(20, y);
            }),
            stroke,
          );
        }

        break;
      case LI.person:
        canvas.drawCircle(const Offset(12, 8.2), 3.6, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(4.8, 20.2);
            p.quadraticBezierTo(6.6, 14.8, 12, 14.8);
            p.quadraticBezierTo(17.4, 14.8, 19.2, 20.2);
          }),
          stroke,
        );

        break;
      case LI.newComment:
        // Rounded bubble with a plus: the designs' `add_comment`.
        canvas.drawPath(
          _path((p) {
            p.moveTo(7, 4.5);
            p.lineTo(17, 4.5);
            p.quadraticBezierTo(20, 4.5, 20, 7.5);
            p.lineTo(20, 13.5);
            p.quadraticBezierTo(20, 16.5, 17, 16.5);
            p.lineTo(11.5, 16.5);
            p.lineTo(7, 19.5);
            p.lineTo(7, 16.4);
            p.quadraticBezierTo(4, 16.4, 4, 13.4);
            p.lineTo(4, 7.5);
            p.quadraticBezierTo(4, 4.5, 7, 4.5);
            p.close();
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 8.4);
            p.lineTo(12, 12.6);
            p.moveTo(9.9, 10.5);
            p.lineTo(14.1, 10.5);
          }),
          stroke,
        );

        break;
      case LI.chevronUp:
        canvas.drawPath(
          _path((p) {
            p.moveTo(5.5, 15);
            p.lineTo(12, 8.5);
            p.lineTo(18.5, 15);
          }),
          stroke,
        );

        break;
      case LI.externalLink:
        canvas.drawPath(
          _path((p) {
            p.moveTo(19.5, 10.5);
            p.lineTo(19.5, 19.5);
            p.lineTo(4.5, 19.5);
            p.lineTo(4.5, 5);
            p.lineTo(13.5, 5);
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(12.5, 11.5);
            p.lineTo(20, 4);
            p.moveTo(15, 4);
            p.lineTo(20, 4);
            p.lineTo(20, 9);
          }),
          stroke,
        );

        break;
      case LI.bolt:
        canvas.drawPath(
          _path((p) {
            p.moveTo(13.5, 3);
            p.lineTo(6, 13.2);
            p.lineTo(11.2, 13.2);
            p.lineTo(10.5, 21);
            p.lineTo(18, 10.8);
            p.lineTo(12.8, 10.8);
            p.close();
          }),
          stroke,
        );

        break;
      case LI.hourglass:
        canvas.drawPath(
          _path((p) {
            p.moveTo(6.5, 3.5);
            p.lineTo(17.5, 3.5);
            p.lineTo(17.5, 6);
            p.quadraticBezierTo(17.5, 10.2, 13.4, 12);
            p.quadraticBezierTo(17.5, 13.8, 17.5, 18);
            p.lineTo(17.5, 20.5);
            p.lineTo(6.5, 20.5);
            p.lineTo(6.5, 18);
            p.quadraticBezierTo(6.5, 13.8, 10.6, 12);
            p.quadraticBezierTo(6.5, 10.2, 6.5, 6);
            p.close();
          }),
          stroke,
        );

        break;
      case LI.enter:
        canvas.drawPath(
          _path((p) {
            p.moveTo(19, 5);
            p.lineTo(19, 14);
            p.quadraticBezierTo(19, 19, 14, 19);
            p.lineTo(5, 19);
            p.moveTo(9.5, 14);
            p.lineTo(4.5, 19);
            p.lineTo(9.5, 19);
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(4.5, 5);
            p.lineTo(4.5, 19);
          }),
          stroke,
        );

        break;
      case LI.logout:
        canvas.drawPath(
          _path((p) {
            p.moveTo(13.5, 4.5);
            p.lineTo(4.5, 4.5);
            p.lineTo(4.5, 19.5);
            p.lineTo(13.5, 19.5);
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(10, 12);
            p.lineTo(19.5, 12);
            p.moveTo(15.8, 8.3);
            p.lineTo(19.5, 12);
            p.lineTo(15.8, 15.7);
          }),
          stroke,
        );

        break;
      case LI.shield:
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 3);
            p.lineTo(19.5, 6);
            p.lineTo(19.5, 11.5);
            p.quadraticBezierTo(19.5, 17.5, 12, 21);
            p.quadraticBezierTo(4.5, 17.5, 4.5, 11.5);
            p.lineTo(4.5, 6);
            p.close();
          }),
          stroke,
        );

        break;
      case LI.key:
        canvas.drawCircle(const Offset(7.6, 12), 3.5, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(11.1, 12);
            p.lineTo(19.5, 12);
            p.moveTo(16.6, 12);
            p.lineTo(16.6, 14.6);
            p.moveTo(19, 12);
            p.lineTo(19, 14.2);
          }),
          stroke,
        );

        break;
      case LI.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(5, 10.5, 14, 9.5),
            const Radius.circular(2.4),
          ),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(8, 10.5);
            p.lineTo(8, 7.6);
            p.addArc(
              Rect.fromCircle(center: const Offset(12, 7.6), radius: 4),
              math.pi,
              math.pi,
            );
            p.lineTo(16, 10.5);
          }),
          stroke,
        );

        break;
      case LI.server:
        // `dns`: a rack - two uprights on a shelf, two status dots.
        canvas.drawPath(
          _path((p) {
            p.moveTo(4, 4.5);
            p.lineTo(20, 4.5);
            p.lineTo(20, 10.5);
            p.lineTo(4, 10.5);
            p.close();
            p.moveTo(4, 13.5);
            p.lineTo(20, 13.5);
            p.lineTo(20, 19.5);
            p.lineTo(4, 19.5);
            p.close();
          }),
          stroke,
        );
        canvas.drawCircle(const Offset(7.4, 7.5), 1.1, fill);
        canvas.drawCircle(const Offset(7.4, 16.5), 1.1, fill);
        break;

      case LI.info:
        canvas.drawCircle(const Offset(12, 12), 8.6, stroke);
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 11.2);
            p.lineTo(12, 16.4);
          }),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 7.9), 1.0, fill);

        break;
      case LI.code:
        canvas.drawPath(
          _path((p) {
            p.moveTo(8.5, 7.5);
            p.lineTo(3.5, 12);
            p.lineTo(8.5, 16.5);
            p.moveTo(15.5, 7.5);
            p.lineTo(20.5, 12);
            p.lineTo(15.5, 16.5);
            p.moveTo(13.6, 4.5);
            p.lineTo(10.4, 19.5);
          }),
          stroke,
        );

        break;
      case LI.save:
        canvas.drawPath(
          _path((p) {
            p.moveTo(4.5, 5.5);
            p.lineTo(16, 5.5);
            p.lineTo(19.5, 9);
            p.lineTo(19.5, 18.5);
            p.lineTo(4.5, 18.5);
            p.close();
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(8, 5.5);
            p.lineTo(8, 10.5);
            p.lineTo(15, 10.5);
            p.lineTo(15, 5.5);
            p.moveTo(8, 18.5);
            p.lineTo(8, 13.5);
            p.lineTo(16, 13.5);
            p.lineTo(16, 18.5);
          }),
          stroke,
        );

        break;
      case LI.doc:
        canvas.drawPath(
          _path((p) {
            p.moveTo(6, 3.5);
            p.lineTo(14, 3.5);
            p.lineTo(18.5, 8);
            p.lineTo(18.5, 20.5);
            p.lineTo(6, 20.5);
            p.close();
            p.moveTo(14, 3.5);
            p.lineTo(14, 8);
            p.lineTo(18.5, 8);
            p.moveTo(9, 12.5);
            p.lineTo(15.5, 12.5);
            p.moveTo(9, 16);
            p.lineTo(15.5, 16);
          }),
          stroke,
        );

        break;
      case LI.brain:
        // Head profile with two filled nodes: stands in for the designs'
        // `psychology` on the Agents row.
        canvas.drawPath(
          _path((p) {
            p.moveTo(15.5, 20.5);
            p.lineTo(15.5, 18.4);
            p.cubicTo(18.4, 16.8, 19.8, 14.1, 19.8, 10.9);
            p.cubicTo(19.8, 6.4, 16.4, 3.5, 12, 3.5);
            p.cubicTo(7.6, 3.5, 4.2, 6.4, 4.2, 10.9);
            p.cubicTo(4.2, 13.5, 5.5, 15.8, 8.5, 17.3);
            p.lineTo(8.5, 20.5);
          }),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 9.8), 1.05, fill);
        canvas.drawCircle(const Offset(15.4, 13.4), 1.05, fill);

        break;
      case LI.robot:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4.5, 8, 15, 11.5),
            const Radius.circular(3),
          ),
          stroke,
        );
        canvas.drawCircle(const Offset(9.4, 13.6), 1.25, fill);
        canvas.drawCircle(const Offset(14.6, 13.6), 1.25, fill);
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 8);
            p.lineTo(12, 4.8);
            p.moveTo(4.5, 11.8);
            p.lineTo(2.6, 11.8);
            p.moveTo(19.5, 11.8);
            p.lineTo(21.4, 11.8);
          }),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 3.6), 1.35, fill);

        break;
      case LI.arrowBack:
        canvas.drawPath(
          _path((p) {
            p.moveTo(19, 12);
            p.lineTo(5, 12);
            p.moveTo(11, 6);
            p.lineTo(5, 12);
            p.lineTo(11, 18);
          }),
          stroke,
        );

        break;
      case LI.diff:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 4, 11, 11),
            const Radius.circular(2.2),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9, 9, 11, 11),
            const Radius.circular(2.2),
          ),
          stroke,
        );
        break;
      case LI.mic:
        // Capsule plus the cradle under it, which is what makes a 1.5px mic
        // read as a mic rather than a pill.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(9, 2.5, 6, 11),
            const Radius.circular(3),
          ),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.addArc(
              Rect.fromCircle(center: const Offset(12, 11), radius: 6.5),
              0,
              math.pi,
            );
          }),
          stroke,
        );
        canvas.drawPath(
          _path((p) {
            p.moveTo(12, 17.5);
            p.lineTo(12, 21);
          }),
          stroke,
        );

        break;
      case LI.volume:
        // Speaker cone on its own side, then two arcs for the waves. The arcs
        // are open, not closed circles: a full ring at this weight reads as a
        // record next to a speaker.
        canvas.drawPath(
          _path((p) {
            p.moveTo(4, 9.5);
            p.lineTo(7.5, 9.5);
            p.lineTo(12, 5.5);
            p.lineTo(12, 18.5);
            p.lineTo(7.5, 14.5);
            p.lineTo(4, 14.5);
            p.close();
          }),
          stroke,
        );
        for (final radius in const [5.0, 9.0]) {
          canvas.drawPath(
            _path((p) {
              p.addArc(
                Rect.fromCircle(center: const Offset(12, 12), radius: radius),
                -0.85,
                1.7,
              );
            }),
            stroke,
          );
        }

        break;
    }
  }

  @override
  bool shouldRepaint(covariant LLinePainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}
