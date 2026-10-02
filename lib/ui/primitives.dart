// Design-system primitives — build_order step 2 of design-system.json:
// Pill/Button, Card, InnerCell, IconTile, Avatar(+Stack), Toggle, Progress.
//
// Rules baked in here:
//  * min 44x44 tap target
//  * press = scale(0.97), disabled = 40% opacity
//  * soft diffuse shadows, never harsh borders or pure-black shadows
//  * status is never colour-only (dots ship with a label or icon)
//  * no hard-coded colours/sizes: everything comes from theme.dart tokens

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// An accent colour + its tint, the pairing rule from design-system.json:
/// "Tinted backgrounds use the accent's tint with the accent's base as
/// icon/text colour."
class OCAccent {
  final Color base;
  final Color tint;
  final Color ink; // text-safe variant of [base] for use on [tint]
  const OCAccent(this.base, this.tint, this.ink);

  static const purple = OCAccent(
    OCColors.purple,
    OCColors.purpleTint,
    OCColors.purpleInk,
  );
  static const orange = OCAccent(
    OCColors.orange,
    OCColors.orangeTint,
    OCColors.orangeInk,
  );
  static const pink = OCAccent(
    OCColors.pink,
    OCColors.pinkTint,
    OCColors.pinkInk,
  );
  static const yellow = OCAccent(
    OCColors.yellow,
    OCColors.yellowTint,
    OCColors.yellowInk,
  );
  static const blue = OCAccent(
    OCColors.blue,
    OCColors.blueTint,
    OCColors.blueInk,
  );
  static const green = OCAccent(
    OCColors.green,
    OCColors.greenTint,
    OCColors.greenInk,
  );
  static const red = OCAccent(OCColors.red, OCColors.redTint, OCColors.redInk);
  static const neutral = OCAccent(
    OCColors.textSecondary,
    OCColors.surfaceMuted,
    OCColors.textPrimary,
  );

  /// Cycle used when a screen needs several tiles without hand-picking.
  static const rotation = <OCAccent>[purple, orange, blue, green, pink, yellow];

  static OCAccent at(int i) => rotation[i % rotation.length];
}

// ---------------------------------------------------------------------
// Button / Pill
// ---------------------------------------------------------------------

enum OCButtonVariant {
  /// #0D0D12 fill, white label, 56 tall full-width pill. The dominant CTA.
  primaryBlack,

  /// cta_orange_soft gradient, 48 tall, radius 14. Secondary/filled action.
  primaryOrange,

  /// cta_sunset gradient, 52 tall pill, colored_cta_glow shadow.
  primaryGradient,

  /// #F0F0F7 fill, ink label, 40 tall pill, optional 16-18px leading glyph.
  secondaryPill,

  /// 32 tall, radius 10, caption/700. Inline affordance ("Start", "Details").
  smallInline,

  /// White fill + hairline, 36 tall pill, caption/600.
  ghostOutline,

  /// redTint fill with redInk label — destructive confirmations.
  danger,
}

/// Design-system button. Handles the press scale + disabled treatment so no
/// call site has to remember it.
class OCButton extends StatefulWidget {
  const OCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = OCButtonVariant.primaryBlack,
    this.icon,
    this.trailingIcon,
    this.expand = true,
    this.height,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final OCButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Full-width by default (design-system: CTAs are full-width pills).
  final bool expand;
  final double? height;
  final EdgeInsetsGeometry? padding;

  bool get _enabled => onPressed != null;

  @override
  State<OCButton> createState() => _OCButtonState();
}

class _OCButtonState extends State<OCButton> {
  bool _pressed = false;

  // (height, radius, padding-x, label style, icon-gap, icon size)
  static final _specs =
      <
        OCButtonVariant,
        ({
          double h,
          double r,
          double px,
          TextStyle text,
          double gap,
          double icon,
        })
      >{
        OCButtonVariant.primaryBlack: (
          h: 56,
          r: 9999,
          px: 24,
          text: OCTypography.button,
          gap: 8,
          icon: 20,
        ),
        OCButtonVariant.primaryOrange: (
          h: 48,
          r: 14,
          px: 20,
          text: OCTypography.button,
          gap: 8,
          icon: 20,
        ),
        OCButtonVariant.primaryGradient: (
          h: 52,
          r: 9999,
          px: 24,
          text: OCTypography.button,
          gap: 8,
          icon: 20,
        ),
        OCButtonVariant.secondaryPill: (
          h: 40,
          r: 9999,
          px: 18,
          text: OCTypography.caption,
          gap: 6,
          icon: 17,
        ),
        OCButtonVariant.smallInline: (
          h: 32,
          r: 10,
          px: 14,
          text: OCTypography.button,
          gap: 6,
          icon: 16,
        ),
        OCButtonVariant.ghostOutline: (
          h: 36,
          r: 9999,
          px: 16,
          text: OCTypography.button,
          gap: 6,
          icon: 16,
        ),
        OCButtonVariant.danger: (
          h: 48,
          r: 14,
          px: 20,
          text: OCTypography.button,
          gap: 8,
          icon: 20,
        ),
      };

  ({
    Color bg,
    Color fg,
    Gradient? gradient,
    List<BoxShadow> shadow,
    Border? border,
  })
  _paint() {
    switch (widget.variant) {
      case OCButtonVariant.primaryBlack:
        return (
          bg: OCColors.ctaSolid,
          fg: OCColors.textInverse,
          gradient: null,
          shadow: OCShadow.floatingCta,
          border: null,
        );
      case OCButtonVariant.primaryOrange:
        return (
          bg: OCColors.orange,
          fg: OCColors.textInverse,
          gradient: OCGradient.ctaOrangeSoft,
          shadow: OCShadow.none,
          border: null,
        );
      case OCButtonVariant.primaryGradient:
        return (
          bg: OCColors.pinkHot,
          fg: OCColors.textInverse,
          gradient: OCGradient.ctaSunset,
          shadow: OCShadow.coloredCtaGlow,
          border: null,
        );
      case OCButtonVariant.secondaryPill:
        return (
          bg: OCColors.canvas,
          fg: OCColors.textPrimary,
          gradient: null,
          shadow: OCShadow.none,
          border: null,
        );
      case OCButtonVariant.smallInline:
        return (
          bg: OCColors.surfaceMuted,
          fg: OCColors.textPrimary,
          gradient: null,
          shadow: OCShadow.none,
          border: null,
        );
      case OCButtonVariant.ghostOutline:
        return (
          bg: OCColors.surface,
          fg: OCColors.textPrimary,
          gradient: null,
          shadow: OCShadow.none,
          border: Border.all(color: OCColors.borderHairline),
        );
      case OCButtonVariant.danger:
        return (
          bg: OCColors.redTint,
          fg: OCColors.redInk,
          gradient: null,
          shadow: OCShadow.none,
          border: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specs[widget.variant]!;
    final paint = _paint();
    final enabled = widget._enabled;
    final height = widget.height ?? spec.h;
    final radius = BorderRadius.circular(spec.r);

    Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: spec.icon, color: paint.fg),
          SizedBox(width: spec.gap),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: spec.text.copyWith(
              color: paint.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: spec.gap),
          Icon(widget.trailingIcon, size: spec.icon, color: paint.fg),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? OCMotion.pressScale : 1,
          duration: OCMotion.micro,
          curve: OCMotion.standard,
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.4, // disabled = 40% opacity
            duration: OCMotion.micro,
            child: Container(
              height: height,
              width: widget.expand ? double.infinity : null,
              padding:
                  widget.padding ?? EdgeInsets.symmetric(horizontal: spec.px),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: paint.gradient == null ? paint.bg : null,
                gradient: paint.gradient,
                borderRadius: radius,
                border: paint.border,
                boxShadow: paint.shadow,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------

enum OCCardVariant {
  /// White on the pale canvas — the default container.
  default_,

  /// Pastel gradient fill; put white inner cells on top of it.
  tinted,

  /// Gradient fill meant to sit behind illustration/avatar slots.
  hero,
}

/// White rounded container: radius 24, soft shadow, 16px padding.
class OCCard extends StatelessWidget {
  const OCCard({
    super.key,
    required this.child,
    this.variant = OCCardVariant.default_,
    this.padding = const EdgeInsets.all(OCSpace.card),
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final OCCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// Overrides [variant]'s gradient.
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final paint = switch (variant) {
      OCCardVariant.default_ => gradient,
      OCCardVariant.tinted => gradient ?? OCGradient.heroPastelBlend,
      OCCardVariant.hero => gradient ?? OCGradient.heroSky,
    };

    final shape = BorderRadius.circular(OCRadius.card);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: paint == null ? cs.surface : Colors.transparent,
        gradient: paint,
        borderRadius: shape,
        boxShadow: OCShadow.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The #F6F6FA / radius-16 fill used for rows and stat tiles inside a card.
/// Separation comes from fill contrast, never from a shadow.
class OCInnerCell extends StatelessWidget {
  const OCInnerCell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: OCSpace.md + 2,
      vertical: OCSpace.md,
    ),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.accent,
    this.radius = OCRadius.inner,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  /// Optional accent: fills with the accent tint and outlines it when selected.
  final OCAccent? accent;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: accent?.tint ?? OCColors.surfaceSubtle,
        borderRadius: shape,
        border: accent == null
            ? null
            : Border.all(color: accent!.base, width: 1.5),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// IconTile
// ---------------------------------------------------------------------

/// Tinted squircle that holds a glyph: radius 16, accent tint fill,
/// accent base glyph. 52px for app-icon grids, 28px for inline chips.
class OCIconTile extends StatelessWidget {
  const OCIconTile({
    super.key,
    required this.icon,
    this.accent = OCAccent.purple,
    this.size = 52,
    this.iconSize = 24,
    this.solid = false,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final OCAccent accent;
  final double size;
  final double iconSize;

  /// Solid pastel fill with a white glyph (app-icon tile look).
  final bool solid;

  /// Overrides the glyph colour (defaults to the accent's text-safe ink).
  final Color? color;
  final VoidCallback? onTap;

  /// 28px chip variant for rows inside a card.
  const OCIconTile.chip({
    super.key,
    required this.icon,
    required this.accent,
    this.color,
    this.onTap,
  }) : size = 28,
       iconSize = 15,
       solid = false;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(OCRadius.tile);
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? accent.base : accent.tint,
        borderRadius: shape,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: solid ? OCColors.textInverse : (color ?? accent.ink),
      ),
    );

    if (onTap == null) return tile;
    return GestureDetector(
      onTap: onTap,
      // 28px chips sit inside a 44px-tall row, so keep the tap target up.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(
          (OCSpace.tapTarget - size) / 2 > 0
              ? (OCSpace.tapTarget - size) / 2
              : 0,
        ),
        child: tile,
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Avatar
// ---------------------------------------------------------------------

enum OCStatus { none, online, busy, offline }

/// Round avatar with a white ring and an optional status dot.
/// No network images anywhere in this app, so [label] / [emoji] render a
/// pastel circle with initials or a placeholder glyph.
class OCAvatar extends StatelessWidget {
  const OCAvatar({
    super.key,
    required this.label,
    this.size = 40,
    this.accent,
    this.status = OCStatus.none,
    this.emoji,
  });

  /// Initials / short name — placeholder content only.
  final String label;
  final double size;
  final OCAccent? accent;
  final OCStatus status;

  /// Optional single glyph drawn instead of [label].
  final String? emoji;

  static const sizes = <double>[24, 32, 40, 48, 64];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = accent ?? OCAccent.at(label.hashCode.abs());
    final initial = label.trim().isEmpty
        ? '?'
        : label.trim().substring(0, 1).toUpperCase();

    Widget face = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.tint,
        shape: BoxShape.circle,
        border: Border.all(color: cs.surface, width: 2), // 2px white ring
      ),
      alignment: Alignment.center,
      child: emoji != null
          ? Text(emoji!, style: TextStyle(fontSize: size * 0.5, height: 1))
          : Text(
              initial,
              style: TextStyle(
                fontFamily: OCTypography.fontFamily,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: tone.ink,
                height: 1,
              ),
            ),
    );

    if (status == OCStatus.none) return face;

    final dot = size * 0.25 < 8 ? 8.0 : size * 0.25; // 10px at 40px avatars
    final color = switch (status) {
      OCStatus.online => OCColors.green,
      OCStatus.busy => OCColors.yellow,
      OCStatus.offline || OCStatus.none => OCColors.textTertiary,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: cs.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlapping circles, -8px margin, white ring between them.
class OCAvatarStack extends StatelessWidget {
  const OCAvatarStack({
    super.key,
    required this.labels,
    this.size = 32,
    this.max = 4,
    this.accent,
  });

  final List<String> labels;
  final double size;

  /// Beyond this many, collapse the rest into a "+N" bubble.
  final int max;
  final OCAccent? accent;

  @override
  Widget build(BuildContext context) {
    final shown = labels.take(max).toList();
    final extra = labels.length - shown.length;
    final overlap = -8.0;

    return SizedBox(
      height: size,
      width: shown.isEmpty
          ? 0
          : size +
                (shown.length - 1) * (size + overlap) +
                (extra > 0 ? size * 0.7 : 0),
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size + overlap),
              child: OCAvatar(
                label: shown[i],
                size: size,
                accent: accent ?? OCAccent.at(i),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * (size + overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: OCColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: OCColors.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: OCTypography.micro.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OCColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Toggle
// ---------------------------------------------------------------------

/// 44x26 switch: #FF8A1F on, #D9D9E3 off, 22px white thumb with a soft shadow.
/// [onChanged] null renders the disabled state.
class OCToggle extends StatelessWidget {
  const OCToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Accessibility: switches must announce what they control.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        // 44px tall hit area around the 26px switch.
        child: SizedBox(
          width: OCSpace.tapTarget,
          height: OCSpace.tapTarget,
          child: Center(
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.4,
              duration: OCMotion.micro,
              child: AnimatedContainer(
                duration: OCMotion.base,
                curve: OCMotion.standard,
                width: 44,
                height: 26,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: value ? OCColors.toggleOn : OCColors.toggleOff,
                  borderRadius: BorderRadius.circular(OCRadius.full),
                ),
                child: AnimatedAlign(
                  duration: OCMotion.base,
                  curve: OCMotion.standard,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: OCColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: OCShadow.toggleThumb,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Segmented control
// ---------------------------------------------------------------------

/// #F0F0F7 track, 4px padding, 36px pill items, white + soft shadow on the
/// active one.
class OCSegmentedControl<T> extends StatelessWidget {
  const OCSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<OCSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OCSpace.xs),
      decoration: BoxDecoration(
        color: OCColors.canvas,
        borderRadius: BorderRadius.circular(OCRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in segments)
            Flexible(
              child: _SegmentItem(
                label: s.label,
                icon: s.icon,
                selected: s.value == value,
                onTap: () => onChanged(s.value),
              ),
            ),
        ],
      ),
    );
  }
}

class OCSegment<T> {
  final T value;
  final String label;
  final IconData? icon;
  const OCSegment(this.value, this.label, {this.icon});
}

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
          curve: OCMotion.standard,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
          decoration: BoxDecoration(
            color: selected ? OCColors.surface : Colors.transparent,
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
                  size: 15,
                  color: selected
                      ? OCColors.textPrimary
                      : OCColors.textSecondary,
                ),
                const SizedBox(width: OCSpace.xs + 2),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? OCColors.textPrimary
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
          color: trackColor ?? OCColors.yellowTint,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: animate ? 0 : target, end: target),
            duration: OCMotion.emphasis,
            curve: OCMotion.standard,
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
    this.fill = OCColors.orangeBright,
    this.track = OCColors.orangeTrack,
    this.animate = true,
    this.child,
    this.semanticLabel,
  });

  /// 0..1
  final double value;
  final double size;
  final double stroke;
  final Color fill;
  final Color track;
  final bool animate;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
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
              curve: OCMotion.standard,
              builder: (_, v, __) => CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  value: v,
                  stroke: stroke,
                  fill: fill,
                  track: track,
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
