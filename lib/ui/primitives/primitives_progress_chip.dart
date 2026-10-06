part of '../primitives.dart';

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: OCMotion.base,
          curve: OCMotion.curve,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
          decoration: BoxDecoration(
            color: selected ? OCColors.cta : Colors.transparent,
            borderRadius: BorderRadius.circular(OCRadius.full),
            boxShadow: selected ? OCShadow.segmentedActive : OCShadow.none,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? OCColors.onCta
                      : OCColors.textSecondary,
                ),
                const SizedBox(width: OCSpace.xs + 2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.meta.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? OCColors.onCta
                        : OCColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------

/// 10px pill bar, warm gradient fill, #FFF1D6 track. Animates on mount and on
/// every value change (no controller juggling, so parent rebuilds are safe).
class OCProgressBar extends StatelessWidget {
  const OCProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.gradient,
    this.trackColor,
    this.animate = true,
    this.semanticLabel,
  });

  /// 0..1
  final double value;
  final double height;
  final Gradient? gradient;
  final Color? trackColor;
  final bool animate;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(target * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OCRadius.full),
        child: Container(
          height: height,
          color: trackColor ?? OCColors.surfaceHighest,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: animate ? 0 : target, end: target),
            duration: OCMotion.emphasis,
            curve: OCMotion.curve,
            builder: (_, v, __) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: gradient ?? OCGradient.progressWarm,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 28px ring, 4px stroke, round caps, warm fill. Optional centre child.
class OCProgressRing extends StatelessWidget {
  const OCProgressRing({
    super.key,
    required this.value,
    this.size = 28,
    this.stroke = 4,
    this.fill,
    this.track,
    this.color,
    this.animate = true,
    this.child,
    this.semanticLabel,
  });

  /// 0..1
  final double value;
  final double size;
  final double stroke;
  final Color? fill;
  final Color? track;

  /// Single-colour ring. [fill]/[track] stay for the two-tone variant.
  final Color? color;
  final bool animate;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    // The design's progress colour is `primary`, not the accent.
    final ring = color ?? context.oc.cta;
    return Semantics(
      label: semanticLabel,
      value: '${(target * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: animate ? 0 : target, end: target),
              duration: OCMotion.emphasis,
              curve: OCMotion.curve,
              builder: (_, v, __) => CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  value: v,
                  stroke: stroke,
                  // A single-colour ring uses a muted track; the two-tone
                  // variant keeps its own.
                  fill: fill ?? ring,
                  track: track ?? ring.withValues(alpha: 0.22),
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.fill,
    required this.track,
  });

  final double value;
  final double stroke;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;
    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start at 12 o'clock
      2 * math.pi * value,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
      old.fill != fill ||
      old.track != track ||
      old.stroke != stroke;
}

// ---------------------------------------------------------------------
// Chip
// ---------------------------------------------------------------------

/// Tappable chip used for the composer's model / agent / tools row and for
/// suggested prompts. One language of chips across the app:
/// tint fill, ink glyph, 48dp hit area, pill radius.
class OCChip extends StatelessWidget {
  const OCChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.accent = OCAccent.orange,
    this.selected = false,
    this.semanticLabel,
    this.maxWidth,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final OCAccent accent;
  final bool selected;
  final String? semanticLabel;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = selected ? OCColors.textPrimary : OCColors.textSecondary;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.4,
          duration: OCMotion.micro,
          child: Container(
            constraints: const BoxConstraints(minHeight: OCSpace.tapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: OCSpace.md,
              vertical: OCSpace.xs + 2,
            ),
            // Unselected = `container-low`, selected = `container-high`. No
            // border: the design's chips are separated by fill alone.
            decoration: BoxDecoration(
              color: selected ? OCColors.surfaceHigh : OCColors.surface,
              borderRadius: BorderRadius.circular(OCRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: selected ? accent.ink : fg),
                  const SizedBox(width: OCSpace.xs + 2),
                ],
                if (maxWidth != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth!),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.metaStrong.copyWith(color: fg),
                    ),
                  )
                else
                  Text(
                    label,
                    style: OCTypography.metaStrong.copyWith(color: fg),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
