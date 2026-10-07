// Velo - your coding companion. Pure Flutter (CustomPaint), no assets, no packages.
//
// USAGE:
//   VeloAvatar(mood: VeloMood.thinking, size: 160)
//
// OR global (kahin se bhi badlo):
//   veloMood.value = VeloMood.running;   // script chali
//   veloMood.value = VeloMood.patching;  // code patch
//   veloMood.value = VeloMood.success;   // done
//   ...and put  VeloBadge(size: 140)  anywhere in your UI.

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum VeloMood {
  idle, listening, thinking, coding, running,
  patching, success, error, waiting, sleep,
}

/// Global mood. App ke events se isko set karo.
final ValueNotifier<VeloMood> veloMood = ValueNotifier(VeloMood.idle);

class VeloBadge extends StatelessWidget {
  const VeloBadge({super.key, this.size = 140});
  final double size;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<VeloMood>(
        valueListenable: veloMood,
        builder: (_, m, __) => VeloAvatar(mood: m, size: size),
      );
}

class VeloAvatar extends StatefulWidget {
  const VeloAvatar({super.key, this.mood = VeloMood.idle, this.size = 160, this.onTap});
  final VeloMood mood;
  final double size;
  final VoidCallback? onTap;
  @override
  State<VeloAvatar> createState() => _VeloAvatarState();
}

class _VeloAvatarState extends State<VeloAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(painter: _VeloPainter(_c.value, widget.mood)),
        ),
      ),
    );
  }
}

class _VeloPainter extends CustomPainter {
  _VeloPainter(this.t, this.mood);
  final double t;
  final VeloMood mood;

  static const _blue = Color(0xFF3B82F6);
  static const _teal = Color(0xFF06D6A0);
  static const _ink = Color(0xFF3B4C8A);

  double _w(double n) => math.sin(2 * math.pi * t * n);

  void _text(Canvas c, String s, Offset o, double fs, Color col, {double rot = 0}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: fs, color: col, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(rot);
    tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
    c.restore();
  }

  void _ellipse(Canvas c, Offset o, double w, double h, double rot, Paint p) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(rot);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), p);
    c.restore();
  }

  @override
  void paint(Canvas c, Size size) {
    final s = size.shortestSide;
    double bobSpeed = 1;
    if (mood == VeloMood.running) bobSpeed = 4;
    if (mood == VeloMood.patching) bobSpeed = 3;
    if (mood == VeloMood.coding) bobSpeed = 2;
    double amp = s * 0.025;
    if (mood == VeloMood.sleep) amp = s * 0.012;
    if (mood == VeloMood.error) amp = 0;
    final bob = _w(bobSpeed) * amp;
    final shake = mood == VeloMood.error ? _w(20) * s * 0.012 : 0.0;
    final hop = mood == VeloMood.success ? -_w(2).abs() * s * 0.06 : 0.0;
    final lift = bob + hop;

    // shadow
    final k = (1 + lift / s * 3).clamp(0.6, 1.2);
    c.drawOval(
      Rect.fromCenter(center: Offset(s * 0.5, s * 0.95), width: s * 0.5 * k, height: s * 0.05 * k),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    c.save();
    c.translate(shake, lift);

    _extrasBehind(c, s);

    // fins
    double fin = _w(2) * 0.1;
    if (mood == VeloMood.running) fin = _w(6) * 0.2;
    if (mood == VeloMood.listening) fin = 0.25 + _w(2) * 0.05;
    if (mood == VeloMood.sleep) fin = -0.35;
    if (mood == VeloMood.error) fin = -0.25;
    _fin(c, s, true, fin);
    _fin(c, s, false, fin);

    // feet
    final soft = Paint()..color = const Color(0xFFC7D6FF);
    _ellipse(c, Offset(s * 0.42, s * 0.86), s * 0.11, s * 0.07, 0, soft);
    _ellipse(c, Offset(s * 0.58, s * 0.86), s * 0.11, s * 0.07, 0, soft);

    // arms
    final armP = Paint()..color = const Color(0xFFE6EDFF);
    _ellipse(c, Offset(s * 0.19, s * 0.64), s * 0.1, s * 0.15, 0.4, armP);
    final up = (mood == VeloMood.success || mood == VeloMood.listening);
    final wave = mood == VeloMood.success ? _w(3) * 0.3 : 0.0;
    _ellipse(c, Offset(s * 0.81, s * (up ? 0.54 : 0.64)), s * 0.1, s * 0.15,
        -0.4 - (up ? 0.6 : 0) + wave, armP);

    // body
    final center = Offset(s * 0.5, s * 0.55);
    final r = s * 0.3;
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.5),
          radius: 1.0,
          colors: [Color(0xFFFFFFFF), Color(0xFFE3ECFF), Color(0xFFB9CCFF)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    c.drawCircle(center, r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.006
          ..color = const Color(0x553B82F6));

    // bolt
    final bx = s * 0.58, by = s * 0.76;
    final bolt = Path()
      ..moveTo(bx + s * 0.02, by - s * 0.06)
      ..lineTo(bx - s * 0.03, by + s * 0.005)
      ..lineTo(bx, by + s * 0.005)
      ..lineTo(bx - s * 0.02, by + s * 0.06)
      ..lineTo(bx + s * 0.03, by - s * 0.01)
      ..lineTo(bx, by - s * 0.01)
      ..close();
    c.drawPath(bolt, Paint()..color = _blue);

    _face(c, s);
    _extrasFront(c, s);

    c.restore();
  }

  void _fin(Canvas c, double s, bool left, double ang) {
    final rot = (0.7 + ang) * (left ? 1 : -1);
    final o = Offset(s * (left ? 0.26 : 0.74), s * 0.28);
    final rect = Rect.fromCenter(center: Offset.zero, width: s * 0.24, height: s * 0.1);
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(rot);
    c.drawOval(
      rect,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF8FDBFF), Color(0xFF2F7DF6)]).createShader(rect),
    );
    c.restore();
  }

  void _face(Canvas c, double s) {
    final ex = s * 0.115, ey = s * 0.52;
    final penBrow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.014
      ..color = _ink;

    // cheeks
    final cheek = Paint()..color = const Color(0x40FF7FA0);
    c.drawCircle(Offset(s * 0.34, s * 0.62), s * 0.04, cheek);
    c.drawCircle(Offset(s * 0.66, s * 0.62), s * 0.04, cheek);

    final closedHappy = mood == VeloMood.success;
    final closedSleep = mood == VeloMood.sleep;

    // blink
    double open = 1;
    if (t > 0.90 && t < 0.96) open = ((t - 0.93).abs() / 0.03).clamp(0.08, 1.0);
    if (mood == VeloMood.waiting) open = 0.55;
    if (mood == VeloMood.error) open = 1.1;

    Offset look = Offset.zero;
    if (mood == VeloMood.thinking) look = Offset(s * 0.012, -s * 0.016);
    if (mood == VeloMood.coding) look = Offset(0, s * 0.014);
    if (mood == VeloMood.waiting) look = Offset(_w(1) * s * 0.012, 0);

    for (final sign in [-1.0, 1.0]) {
      final cx = s * 0.5 + sign * ex;
      final cy = ey;
      final w = s * 0.11, h = s * 0.15;
      if (closedHappy || closedSleep) {
        final p = Path()..moveTo(cx - w * 0.5, cy + h * 0.05);
        if (closedHappy) {
          p.quadraticBezierTo(cx, cy - h * 0.45, cx + w * 0.5, cy + h * 0.05);
        } else {
          p.quadraticBezierTo(cx, cy + h * 0.3, cx + w * 0.5, cy + h * 0.05);
        }
        c.drawPath(p, penBrow);
      } else {
        final e = Offset(cx, cy);
        c.drawOval(
          Rect.fromCenter(center: e, width: w, height: h * open),
          Paint()..color = const Color(0xFF0B1B4D),
        );
        c.save();
        c.clipRect(Rect.fromCenter(center: e, width: w, height: h * open));
        c.drawOval(
          Rect.fromCenter(center: e + look + Offset(0, h * 0.12), width: w * 0.72, height: h * 0.7),
          Paint()..color = const Color(0xFF2563EB),
        );
        c.drawCircle(e + look + Offset(-w * 0.15, -h * 0.18 * open), w * 0.16, Paint()..color = Colors.white);
        c.drawCircle(e + look + Offset(w * 0.15, h * 0.18), w * 0.07, Paint()..color = const Color(0xCCFFFFFF));
        c.restore();
      }

      // brows
      double tilt = 0, liftB = 0;
      bool brow = false;
      if (mood == VeloMood.error) { brow = true; tilt = 0.02 * -sign; liftB = 0.005; }
      if (mood == VeloMood.patching) { brow = true; tilt = -0.012 * -sign; }
      if (mood == VeloMood.thinking && sign > 0) { brow = true; liftB = 0.02; }
      if (brow) {
        final by = cy - s * 0.1 - liftB * s;
        c.drawLine(Offset(cx - s * 0.045, by + tilt * s), Offset(cx + s * 0.045, by - tilt * s), penBrow);
      }
    }

    // mouth
    final mx = s * 0.5, my = s * 0.64, mw = s * 0.05;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.012
      ..color = _ink;
    switch (mood) {
      case VeloMood.coding:
      case VeloMood.running:
      case VeloMood.patching:
      case VeloMood.success:
        final m = Path()
          ..moveTo(mx - mw, my)
          ..quadraticBezierTo(mx, my + mw * 1.9, mx + mw, my)
          ..close();
        c.drawPath(m, Paint()..color = const Color(0xFF9B1C3F));
        _ellipse(c, Offset(mx, my + mw * 0.85), mw * 1.1, mw * 0.5, 0, Paint()..color = const Color(0xFFFF6B8A));
        break;
      case VeloMood.error:
        c.drawPath(
            Path()
              ..moveTo(mx - mw * 0.7, my + mw * 0.4)
              ..quadraticBezierTo(mx, my - mw * 0.5, mx + mw * 0.7, my + mw * 0.4),
            line);
        break;
      case VeloMood.thinking:
      case VeloMood.waiting:
      case VeloMood.sleep:
        c.drawLine(Offset(mx - mw * 0.4, my), Offset(mx + mw * 0.4, my), line);
        break;
      default:
        c.drawPath(
            Path()
              ..moveTo(mx - mw * 0.7, my)
              ..quadraticBezierTo(mx, my + mw * 0.9, mx + mw * 0.7, my),
            line);
    }
  }

  void _extrasBehind(Canvas c, double s) {
    if (mood == VeloMood.running) {
      for (var i = 0; i < 3; i++) {
        final x = (s * 0.02 + ((t * 5 + i * 0.33) % 1) * s * 0.2);
        c.drawLine(
          Offset(x, s * (0.45 + i * 0.12)),
          Offset(x + s * 0.12, s * (0.45 + i * 0.12)),
          Paint()
            ..strokeWidth = s * 0.016
            ..strokeCap = StrokeCap.round
            ..color = _blue.withOpacity(0.5),
        );
      }
    }
    if (mood == VeloMood.waiting) {
      final rect = Rect.fromCenter(center: Offset(s * 0.5, s * 0.8), width: s * 0.85, height: s * 0.13);
      c.drawOval(rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.008
            ..color = _blue.withOpacity(0.45));
      final a = 2 * math.pi * t * 2;
      c.drawCircle(Offset(s * 0.5 + math.cos(a) * s * 0.425, s * 0.8 + math.sin(a) * s * 0.065), s * 0.014,
          Paint()..color = _teal);
    }
  }

  void _extrasFront(Canvas c, double s) {
    switch (mood) {
      case VeloMood.thinking:
        _text(c, '?', Offset(s * 0.82, s * 0.14 + _w(1) * s * 0.01), s * 0.14, _blue);
        break;
      case VeloMood.coding:
        final r = RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.28, s * 0.78, s * 0.44, s * 0.15), Radius.circular(s * 0.02));
        c.drawRRect(r, Paint()..color = const Color(0xFF3B4C7A));
        _text(c, '</>', Offset(s * 0.5, s * 0.855), s * 0.07, Colors.white);
        break;
      case VeloMood.patching:
        _text(c, '\u{1F527}', Offset(s * 0.8, s * 0.7), s * 0.16, Colors.black, rot: _w(3) * 0.5);
        break;
      case VeloMood.success:
        const cols = [_teal, _blue, Color(0xFFFFC857), Color(0xFFFF7FA0)];
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4 + t * 2;
          final rr = s * (0.42 + 0.03 * math.sin(2 * math.pi * t * 2 + i));
          c.drawCircle(Offset(s * 0.5 + math.cos(a) * rr, s * 0.5 + math.sin(a) * rr), s * 0.014,
              Paint()..color = cols[i % 4]);
        }
        break;
      case VeloMood.error:
        final tri = Path()
          ..moveTo(s * 0.82, s * 0.06)
          ..lineTo(s * 0.9, s * 0.2)
          ..lineTo(s * 0.74, s * 0.2)
          ..close();
        c.drawPath(tri, Paint()..color = const Color(0xFFE53935));
        _text(c, '!', Offset(s * 0.82, s * 0.15), s * 0.08, Colors.white);
        break;
      case VeloMood.sleep:
        for (var i = 0; i < 3; i++) {
          final p = (t * 2 + i / 3) % 1;
          _text(c, 'z', Offset(s * (0.75 + p * 0.08), s * (0.25 - p * 0.15)), s * (0.06 + i * 0.02),
              _blue.withOpacity(1 - p));
        }
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _VeloPainter old) => old.t != t || old.mood != mood;
}
