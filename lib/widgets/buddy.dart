// lib/widgets/buddy.dart  (EK HI FILE: avatar + logic + permission card)
//
// 1) MaterialApp me:   builder: (context, child) => BuddyOverlay(child: child!),
// 2) Events:           BuddyController.instance.thinking() / toolStart('edit', detail: 'a.dart') / done() / error('..')
// 3) Permission:       final d = await BuddyController.instance.askPermission(id: id, title: 'Run command?', detail: cmd);
//                      -> d == PermissionDecision.allow / always / deny  (isko opencode ko reply me bhejo)
// 4) Test (bina opencode):  BuddyController.instance.runDemo();
//
// lib/widgets/buddy_avatar.dart
// Dev / Sticko / Sara - coding buddies. Pure Flutter (CustomPaint), no assets, no packages.
//
// USAGE:
//   BuddyAvatar(character: BuddyChar.dev, mood: BuddyMood.coding, size: 160)
//
// GLOBAL (kahin se bhi badlo, BuddyBadge apne aap update hoga):
//   buddyChar.value = BuddyChar.sara;
//   buddyMood.value = BuddyMood.thinking;
//   ...UI me kahin:  BuddyBadge(size: 150)
//
// TEST SCREEN:  Navigator.push(context, MaterialPageRoute(builder: (_) => const BuddyDemoPage()));

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BuddyChar { dev, sticko, sara }

enum BuddyMood {
  idle, happy, thinking, focused, coding, running,
  patching, success, error, waiting, sleep, offline,
}

final ValueNotifier<BuddyChar> buddyChar = ValueNotifier(BuddyChar.dev);
final ValueNotifier<BuddyMood> buddyMood = ValueNotifier(BuddyMood.idle);

class BuddyBadge extends StatelessWidget {
  const BuddyBadge({super.key, this.size = 150, this.card = true});
  final double size;
  final bool card;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([buddyChar, buddyMood]),
        builder: (_, __) =>
            BuddyAvatar(character: buddyChar.value, mood: buddyMood.value, size: size, card: card),
      );
}

class BuddyAvatar extends StatefulWidget {
  const BuddyAvatar({
    super.key,
    this.character = BuddyChar.dev,
    this.mood = BuddyMood.idle,
    this.size = 160,
    this.card = true, // light card behind (black lines dark theme me bhi dikhein)
    this.onTap,
  });
  final BuddyChar character;
  final BuddyMood mood;
  final double size;
  final bool card;
  final VoidCallback? onTap;
  @override
  State<BuddyAvatar> createState() => _BuddyAvatarState();
}

class _BuddyAvatarState extends State<BuddyAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _BuddyPainter(_c.value, widget.mood, widget.character, widget.card),
            ),
          ),
        ),
      );
}

class _BuddyPainter extends CustomPainter {
  _BuddyPainter(this.t, this.mood, this.ch, this.card);
  final double t;
  final BuddyMood mood;
  final BuddyChar ch;
  final bool card;

  Color get accent {
    switch (ch) {
      case BuddyChar.dev:
        return const Color(0xFF00E5C8);
      case BuddyChar.sticko:
        return const Color(0xFF34D399);
      case BuddyChar.sara:
        return const Color(0xFFFF6B9D);
    }
  }

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

  @override
  void paint(Canvas c, Size size) {
    final s = size.shortestSide;
    Offset P(double x, double y) => Offset(x * s, y * s);
    final ink = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (card) {
      c.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.12)),
          Paint()..color = const Color(0xFFF3F5F7));
    }
    // ground
    c.drawLine(P(0.12, 0.91), P(0.92, 0.91), ink..strokeWidth = s * 0.008);
    ink.strokeWidth = s * 0.022;

    if (mood == BuddyMood.running) {
      _running(c, s, P, ink);
    } else {
      _seated(c, s, P, ink);
    }
    _effects(c, s, P);
  }

  // ---------- SEATED ----------
  void _seated(Canvas c, double s, Offset Function(double, double) P, Paint ink) {
    double hb = _w(1) * 0.006;
    if (mood == BuddyMood.success) hb = -_w(2).abs() * 0.04;
    if (mood == BuddyMood.error) hb = 0.025;
    final sleep = mood == BuddyMood.sleep;
    final hx = sleep ? 0.42 : 0.38;
    final hy = sleep ? 0.64 : 0.36 + hb;
    final hc = P(hx, hy);

    // laptop
    final dim = mood == BuddyMood.offline || mood == BuddyMood.error || mood == BuddyMood.waiting;
    final scr = Path()
      ..moveTo(s * 0.6, s * 0.86)
      ..lineTo(s * 0.64, s * 0.6)
      ..lineTo(s * 0.9, s * 0.57)
      ..lineTo(s * 0.9, s * 0.86)
      ..close();
    c.drawPath(scr, Paint()..color = dim ? const Color(0xFF555B63) : const Color(0xFF26292E));
    c.drawLine(P(0.5, 0.875), P(0.92, 0.875),
        Paint()..color = const Color(0xFF26292E)..strokeWidth = s * 0.02..strokeCap = StrokeCap.round);
    _text(c, '</>', P(0.77, 0.72), s * 0.075, dim ? Colors.white24 : accent);

    // mug
    if (ch != BuddyChar.sticko) {
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.1, s * 0.8, s * 0.09, s * 0.1), Radius.circular(s * 0.01)),
          Paint()..color = const Color(0xFF26292E));
      _text(c, ch == BuddyChar.sara ? '\u2665' : '\u26A1', P(0.145, 0.85), s * 0.05, accent);
    }

    if (!sleep) {
      // torso + legs
      final top = P(0.38, 0.56 + hb);
      final hip = P(0.36, 0.78);
      c.drawLine(top, hip, ink);
      c.drawLine(hip, P(0.28, 0.9), ink);
      c.drawPath(Path()..moveTo(hip.dx, hip.dy)..quadraticBezierTo(s * 0.46, s * 0.8, s * 0.52, s * 0.9), ink);
    }

    // arms
    final sh = P(0.38, 0.6 + hb);
    final typing = (mood == BuddyMood.coding || mood == BuddyMood.focused);
    final ty = typing ? _w(8).abs() * 0.015 : 0.0;
    void arm(Offset to, [double cx = 0.46, double cy = 0.76]) =>
        c.drawPath(Path()..moveTo(sh.dx, sh.dy)..quadraticBezierTo(s * cx, s * cy, to.dx, to.dy), ink);

    if (sleep) {
      c.drawLine(P(0.28, 0.8), P(0.6, 0.8), ink..strokeWidth = s * 0.03);
      ink.strokeWidth = s * 0.022;
    } else if (mood == BuddyMood.success) {
      final wv = _w(3) * 0.03;
      arm(P(0.16, 0.3 + wv), 0.22, 0.5);
      arm(P(0.62, 0.28 - wv), 0.6, 0.5);
    } else if (mood == BuddyMood.thinking || mood == BuddyMood.waiting) {
      arm(P(hx + 0.08, hy + 0.19), 0.5, 0.68);
      arm(P(0.66, 0.8), 0.46, 0.8);
    } else if (mood == BuddyMood.patching) {
      final wp = P(0.64, 0.62);
      arm(wp, 0.5, 0.62);
      _text(c, '\u{1F527}', wp + Offset(s * 0.03, -s * 0.03), s * 0.14, Colors.black, rot: _w(3) * 0.5);
      arm(P(0.66, 0.8), 0.46, 0.8);
    } else {
      arm(P(0.6, 0.8 - ty));
      arm(P(0.68, 0.8 - (typing ? _w(8 + 0.5).abs() * 0.015 : 0)), 0.48, 0.74);
    }

    _head(c, s, hc, s * 0.2, ink);
  }

  // ---------- RUNNING ----------
  void _running(Canvas c, double s, Offset Function(double, double) P, Paint ink) {
    final bob = _w(4).abs() * -0.015;
    final hc = P(0.55, 0.3 + bob);
    final top = P(0.5, 0.48 + bob);
    final hip = P(0.4, 0.7 + bob);
    c.drawLine(top, hip, ink);
    final ph = _w(2);
    for (final sg in [1.0, -1.0]) {
      final p = ph * sg;
      final foot = P(0.4 + 0.2 * p, 0.9 - 0.07 * math.max(0, -p));
      c.drawPath(
          Path()..moveTo(hip.dx, hip.dy)..quadraticBezierTo((hip.dx + foot.dx) / 2 + s * 0.06, s * 0.8, foot.dx, foot.dy), ink);
    }
    final sh = P(0.5, 0.52 + bob);
    c.drawPath(Path()..moveTo(sh.dx, sh.dy)..quadraticBezierTo(s * 0.6, s * 0.62, s * 0.68, s * 0.58), ink);
    c.drawPath(Path()..moveTo(sh.dx, sh.dy)..quadraticBezierTo(s * 0.4, s * 0.55, s * (0.34 + _w(2) * 0.05), s * 0.62), ink);
    c.save();
    c.translate(s * 0.74, s * 0.55);
    c.rotate(-0.25);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: s * 0.17, height: s * 0.11), Radius.circular(s * 0.01)),
        Paint()..color = const Color(0xFF26292E));
    _text(c, '</>', Offset.zero, s * 0.045, accent);
    c.restore();
    for (var i = 0; i < 4; i++) {
      final x = 0.05 + ((t * 4 + i * 0.25) % 1) * 0.2;
      c.drawLine(P(x, 0.4 + i * 0.1), P(x + 0.12, 0.4 + i * 0.1),
          Paint()..color = accent.withOpacity(0.7)..strokeWidth = s * 0.012..strokeCap = StrokeCap.round);
    }
    _head(c, s, hc, s * 0.17, ink);
  }

  // ---------- HEAD (hair, headphones, face) ----------
  void _head(Canvas c, double s, Offset hc, double rr, Paint ink) {
    final k = rr / (0.2 * s);
    Offset o(double dx, double dy) => Offset(hc.dx + dx * k * s, hc.dy + dy * k * s);
    final offline = mood == BuddyMood.offline;

    c.drawCircle(hc, rr, Paint()..color = offline ? Colors.black : Colors.white);
    c.drawCircle(hc, rr, ink);

    // hair
    if (ch == BuddyChar.dev) {
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + (i - 2) * 0.38;
        final len = (i == 2 ? 0.075 : 0.055) * s * k;
        final b = hc + Offset(math.cos(a), math.sin(a)) * rr;
        c.drawLine(b, hc + Offset(math.cos(a - 0.12), math.sin(a - 0.12)) * (rr + len), ink);
      }
    }
    if (ch == BuddyChar.sara) {
      c.drawCircle(o(-0.09, -0.24), rr * 0.3, Paint()..color = Colors.black);
      c.drawLine(o(-0.12, -0.17), o(-0.2, -0.06), ink);
      c.drawLine(o(0.0, -0.2), o(0.1, -0.15), ink);
    }

    // headphones (dev & sara)
    if (ch != BuddyChar.sticko) {
      c.drawArc(Rect.fromCircle(center: hc, radius: rr * 1.04), math.pi, math.pi * 0.7, false,
          ink..strokeWidth = s * 0.026);
      ink.strokeWidth = s * 0.022;
      final cup = RRect.fromRectAndRadius(
          Rect.fromCenter(center: o(-0.2, 0.02), width: rr * 0.5, height: rr * 0.8), Radius.circular(rr * 0.2));
      c.drawRRect(cup, Paint()..color = Colors.black);
      _text(c, ch == BuddyChar.sara ? '\u2665' : '\u26A1', o(-0.2, 0.02), rr * 0.4, accent);
    }
    if (offline) return;

    // cheeks
    if (ch == BuddyChar.sara) {
      final cp = Paint()..color = const Color(0x55FF6B9D);
      c.drawCircle(o(0.05, 0.08), rr * 0.1, cp);
      c.drawCircle(o(0.2, 0.08), rr * 0.1, cp);
    }

    // eyes
    final fillP = Paint()..color = Colors.black;
    final thinking = mood == BuddyMood.thinking;
    final look = thinking ? Offset(rr * 0.05, -rr * 0.08) : Offset.zero;
    double open = 1;
    if (t > 0.90 && t < 0.96) open = ((t - 0.93).abs() / 0.03).clamp(0.1, 1.0);
    if (mood == BuddyMood.waiting) open = 0.6;
    final happyEyes = mood == BuddyMood.happy || mood == BuddyMood.success;
    final closed = mood == BuddyMood.sleep;
    for (final i in [0, 1]) {
      final e = o(0.05 + i * 0.12, -0.02) + look;
      if (happyEyes || closed) {
        final p = Path()..moveTo(e.dx - rr * 0.1, e.dy + rr * 0.03);
        p.quadraticBezierTo(e.dx, e.dy + (happyEyes ? -rr * 0.2 : rr * 0.14), e.dx + rr * 0.1, e.dy + rr * 0.03);
        c.drawPath(p, ink..strokeWidth = s * 0.016);
        ink.strokeWidth = s * 0.022;
      } else {
        final big = mood == BuddyMood.error ? 1.2 : 1.0;
        c.drawOval(Rect.fromCenter(center: e, width: rr * 0.12 * big, height: rr * 0.26 * open * big), fillP);
        final foc = mood == BuddyMood.focused || mood == BuddyMood.coding || mood == BuddyMood.patching || mood == BuddyMood.running;
        if (foc || (thinking && i == 1)) {
          final dir = i == 0 ? 1.0 : -1.0;
          final lift = thinking ? rr * 0.1 : 0.0;
          c.drawLine(Offset(e.dx - rr * 0.1 * dir, e.dy - rr * 0.2 - lift),
              Offset(e.dx + rr * 0.1 * dir, e.dy - rr * 0.14 - lift),
              ink..strokeWidth = s * 0.014);
          ink.strokeWidth = s * 0.022;
        }
      }
    }

    // mouth
    final m = o(0.115, 0.1);
    final mp = ink..strokeWidth = s * 0.014;
    switch (mood) {
      case BuddyMood.happy:
      case BuddyMood.idle:
        c.drawPath(Path()..moveTo(m.dx - rr * 0.12, m.dy)..quadraticBezierTo(m.dx, m.dy + rr * 0.14, m.dx + rr * 0.12, m.dy), mp);
        break;
      case BuddyMood.success:
      case BuddyMood.running:
        c.drawPath(
            Path()..moveTo(m.dx - rr * 0.13, m.dy)..quadraticBezierTo(m.dx, m.dy + rr * 0.3, m.dx + rr * 0.13, m.dy)..close(),
            Paint()..color = Colors.black);
        break;
      case BuddyMood.error:
        c.drawPath(Path()..moveTo(m.dx - rr * 0.1, m.dy + rr * 0.06)..quadraticBezierTo(m.dx, m.dy - rr * 0.06, m.dx + rr * 0.1, m.dy + rr * 0.06), mp);
        break;
      case BuddyMood.thinking:
        c.drawCircle(m, rr * 0.05, mp);
        break;
      default:
        c.drawLine(m - Offset(rr * 0.09, 0), m + Offset(rr * 0.09, 0), mp);
    }
    ink.strokeWidth = s * 0.022;
  }

  // ---------- EFFECTS ----------
  void _effects(Canvas c, double s, Offset Function(double, double) P) {
    final line = Paint()
      ..color = accent
      ..strokeWidth = s * 0.014
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case BuddyMood.idle:
        final a = 0.4 + 0.6 * (0.5 + 0.5 * _w(1));
        for (var i = 0; i < 3; i++) {
          c.drawLine(P(0.66 + i * 0.03, 0.14 + i * 0.04), P(0.7 + i * 0.03, 0.12 + i * 0.04), line..color = accent.withOpacity(a));
        }
        break;
      case BuddyMood.happy:
        _text(c, '\u2665', P(0.72, 0.16 + _w(1) * 0.015), s * 0.09, accent);
        break;
      case BuddyMood.thinking:
        _text(c, '?', P(0.74, 0.14 + _w(1) * 0.015), s * 0.16, accent);
        break;
      case BuddyMood.coding:
        for (var i = 0; i < 3; i++) {
          final x = 0.66 + ((t * 3 + i * 0.33) % 1) * 0.18;
          c.drawLine(P(x, 0.2 + i * 0.07), P(x + 0.1, 0.2 + i * 0.07), line..color = accent.withOpacity(0.8));
        }
        _text(c, '</>', P(0.74, 0.1 + _w(1) * 0.01), s * 0.07, accent);
        break;
      case BuddyMood.patching:
        for (var i = 0; i < 3; i++) {
          c.drawLine(P(0.78 + i * 0.03, 0.38 - i * 0.04), P(0.83 + i * 0.03, 0.36 - i * 0.05), line..color = accent.withOpacity(0.5 + 0.5 * _w(4).abs()));
        }
        break;
      case BuddyMood.success:
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3 + t * 2 * math.pi * 0.5;
          _text(c, '\u2726', P(0.5 + math.cos(a) * 0.42, 0.42 + math.sin(a) * 0.3), s * 0.06, accent);
        }
        break;
      case BuddyMood.error:
        final tri = Path()
          ..moveTo(s * 0.8, s * 0.08)
          ..lineTo(s * 0.88, s * 0.22)
          ..lineTo(s * 0.72, s * 0.22)
          ..close();
        c.drawPath(tri, Paint()..color = const Color(0xFFE53935));
        _text(c, '!', P(0.8, 0.17), s * 0.08, Colors.white);
        break;
      case BuddyMood.waiting:
        for (var i = 0; i < 3; i++) {
          final on = ((t * 3) % 3).floor() >= i;
          c.drawCircle(P(0.66 + i * 0.07, 0.14), s * 0.012, Paint()..color = Colors.black.withOpacity(on ? 0.9 : 0.2));
        }
        break;
      case BuddyMood.sleep:
        for (var i = 0; i < 3; i++) {
          final p = (t * 2 + i / 3) % 1;
          _text(c, 'z', P(0.62 + p * 0.1, 0.4 - p * 0.2), s * (0.06 + i * 0.02), accent.withOpacity(1 - p));
        }
        break;
      case BuddyMood.offline:
        c.drawCircle(P(0.8, 0.2), s * 0.05, Paint()..color = Colors.black54);
        _text(c, '\u00D7', P(0.8, 0.2), s * 0.08, Colors.white);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter old) => old.t != t || old.mood != mood || old.ch != ch;
}

/// Quick test page: character aur mood badal ke dekho.
class BuddyDemoPage extends StatefulWidget {
  const BuddyDemoPage({super.key});
  @override
  State<BuddyDemoPage> createState() => _BuddyDemoPageState();
}

class _BuddyDemoPageState extends State<BuddyDemoPage> {
  BuddyChar ch = BuddyChar.dev;
  BuddyMood mood = BuddyMood.idle;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Buddy demo')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: BuddyAvatar(character: ch, mood: mood, size: 260)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            for (final x in BuddyChar.values)
              ChoiceChip(label: Text(x.name), selected: ch == x, onSelected: (_) => setState(() => ch = x)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final x in BuddyMood.values)
              ChoiceChip(label: Text(x.name), selected: mood == x, onSelected: (_) => setState(() => mood = x)),
          ]),
        ]),
      );
}

// =====================================================================
//  LOGIC: state machine + permission flow + overlay UI
// =====================================================================

enum PermissionDecision { allow, deny, always }

class PermissionRequest {
  PermissionRequest({required this.id, required this.title, this.detail = ''});
  final String id;
  final String title;
  final String detail;
  final Completer<PermissionDecision> _c = Completer<PermissionDecision>();
  Future<PermissionDecision> get decision => _c.future;
}

/// Singleton. App ke events isko batao, baaki sab (mood, ticker, permission card) ye sambhalta hai.
class BuddyController extends ChangeNotifier {
  BuddyController._();
  static final BuddyController instance = BuddyController._();

  BuddyMood _mood = BuddyMood.idle;
  String? _ticker;
  PermissionRequest? _pending;
  Timer? _hold;
  Timer? _sleepTimer;

  BuddyMood get mood => _mood;
  String? get ticker => _ticker;
  PermissionRequest? get pending => _pending;
  BuddyChar get character => buddyChar.value;
  set character(BuddyChar c) {
    buddyChar.value = c;
    notifyListeners();
  }

  void _set(BuddyMood m, {String? ticker, Duration? thenIdleAfter}) {
    _hold?.cancel();
    _mood = m;
    _ticker = ticker;
    buddyMood.value = m;
    notifyListeners();
    if (thenIdleAfter != null) {
      _hold = Timer(thenIdleAfter, () {
        if (_pending == null) _set(BuddyMood.idle);
      });
    }
    _sleepTimer?.cancel();
    if (m == BuddyMood.idle) {
      _sleepTimer = Timer(const Duration(seconds: 60), () {
        if (_mood == BuddyMood.idle && _pending == null) _set(BuddyMood.sleep);
      });
    }
  }

  // ---- connection ----
  void connecting() => _set(BuddyMood.waiting, ticker: 'connecting...');
  void connected() => _set(BuddyMood.idle);
  void disconnected() => _set(BuddyMood.offline, ticker: 'offline');

  // ---- conversation flow ----
  /// User ne message bheja.
  void userSent() => _set(BuddyMood.focused, ticker: 'got it');

  /// Model soch raha hai ("Thought for 1s").
  void thinking() => _set(BuddyMood.thinking, ticker: 'thinking...');

  /// Model jawab / code stream kar raha hai.
  void writing() => _set(BuddyMood.coding, ticker: 'writing...');

  /// Tool chala. [tool] = tool ka naam (edit, write, bash, read, grep...), [detail] = file ya command.
  void toolStart(String tool, {String? detail}) {
    final t = tool.toLowerCase();
    final d = (detail == null || detail.isEmpty) ? '' : ' $detail';
    if (RegExp(r'edit|write|patch|apply|replace|create').hasMatch(t)) {
      _set(BuddyMood.patching, ticker: 'editing$d');
    } else if (RegExp(r'bash|shell|run|exec|command|test|build').hasMatch(t)) {
      _set(BuddyMood.running, ticker: 'running$d');
    } else {
      _set(BuddyMood.focused, ticker: 'reading$d');
    }
  }

  void toolEnd() => thinking();

  /// Kaam poora ho gaya.
  void done() => _set(BuddyMood.success, ticker: 'done!', thenIdleAfter: const Duration(milliseconds: 2500));

  /// Error aaya.
  void error([String? msg]) =>
      _set(BuddyMood.error, ticker: msg ?? 'error', thenIdleAfter: const Duration(seconds: 5));

  /// Character pe tap.
  void poke() {
    if (_mood == BuddyMood.idle || _mood == BuddyMood.sleep) {
      _set(BuddyMood.happy, thenIdleAfter: const Duration(milliseconds: 1500));
    }
  }

  // ---- permission ----
  /// Permission card dikhao. Tumhare tap tak ruko, phir decision wapas milta hai.
  /// Usko apne opencode reply me bhejo (allow / always / reject).
  Future<PermissionDecision> askPermission({
    required String id,
    required String title,
    String detail = '',
  }) {
    final r = PermissionRequest(id: id, title: title, detail: detail);
    _pending = r;
    _set(BuddyMood.waiting, ticker: 'needs your OK');
    return r.decision;
  }

  void answerPermission(PermissionDecision d) {
    final r = _pending;
    if (r == null) return;
    _pending = null;
    if (!r._c.isCompleted) r._c.complete(d);
    if (d == PermissionDecision.deny) {
      _set(BuddyMood.idle);
    } else {
      _set(BuddyMood.running, ticker: 'continuing...');
    }
  }

  // ---- demo (bina opencode ke test karne ke liye) ----
  Future<void> runDemo() async {
    Future<void> w(int ms) => Future.delayed(Duration(milliseconds: ms));
    userSent();
    await w(900);
    thinking();
    await w(1500);
    toolStart('read', detail: 'lib/main.dart');
    await w(1500);
    toolStart('edit', detail: 'lib/chat_screen.dart');
    await w(1800);
    final d = await askPermission(id: 'demo', title: 'Run command?', detail: 'flutter test');
    if (d == PermissionDecision.deny) {
      error('Denied by you');
      return;
    }
    toolStart('bash', detail: 'flutter test');
    await w(2200);
    done();
  }
}

/// MaterialApp me lagao:
///   MaterialApp(builder: (context, child) => BuddyOverlay(child: child!), ...)
class BuddyOverlay extends StatelessWidget {
  const BuddyOverlay({
    super.key,
    required this.child,
    this.alignment = Alignment.topRight,
    this.margin = const EdgeInsets.fromLTRB(8, 56, 8, 8),
    this.size = 76,
    this.autoHide = false, // true: idle/sleep me chhup jaata hai (Coucou jaisa)
  });
  final Widget child;
  final Alignment alignment;
  final EdgeInsets margin;
  final double size;
  final bool autoHide;

  @override
  Widget build(BuildContext context) {
    final b = BuddyController.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([b, buddyChar]),
      builder: (ctx, _) {
        final idle = b.mood == BuddyMood.idle || b.mood == BuddyMood.sleep;
        final show = !autoHide || !idle || b.pending != null;
        final ticker = b.ticker;
        return Stack(children: [
          Positioned.fill(child: child),
          SafeArea(
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: margin,
                child: AnimatedOpacity(
                  opacity: show ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !show,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BuddyAvatar(character: b.character, mood: b.mood, size: size, onTap: b.poke),
                        if (ticker != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxWidth: 190),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xEE1F1F23),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(ticker,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (b.pending != null) ...[
            Positioned.fill(
              child: GestureDetector(onTap: () {}, child: const ColoredBox(color: Colors.black45)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _PermissionCard(req: b.pending!, ctrl: b),
                ),
              ),
            ),
          ],
        ]);
      },
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.req, required this.ctrl});
  final PermissionRequest req;
  final BuddyController ctrl;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF34D399);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(offset: Offset(0, v * 120), child: Opacity(opacity: 1 - v, child: child)),
      child: Material(
        color: const Color(0xFF1F1F23),
        elevation: 12,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BuddyAvatar(character: ctrl.character, mood: BuddyMood.waiting, size: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(req.title,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  if (req.detail.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(req.detail,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace')),
                  ],
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ctrl.answerPermission(PermissionDecision.deny),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF6B6B)),
                  child: const Text('Deny'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ctrl.answerPermission(PermissionDecision.always),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Always'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ctrl.answerPermission(PermissionDecision.allow),
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('Allow'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
