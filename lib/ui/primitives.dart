// Design-system primitives: Button, Card, InnerCell, IconTile, Avatar(+Stack),
// Toggle, SegmentedControl, Progress, Chip, ListRow, Breadcrumbs, Skeleton.
//
// Rules baked in here:
//  * min 48x48 tap target (the design draws 44; 48 wins)
//  * press = scale(0.97), disabled = 40% opacity
//  * two action colours only: white `cta` for the primary action, terracotta
//    `accent` for secondary/selected. No third hue is a button.
//  * surfaces come from the container ladder in theme.dart, never from a border
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
  static const rotation = <OCAccent>[
    orange,
    blue,
    green,
    purple,
    pink,
    yellow,
  ];

  static OCAccent at(int i) => rotation[i % rotation.length];
}

// ---------------------------------------------------------------------
// Button / Pill
// ---------------------------------------------------------------------

enum OCButtonVariant {
  /// White fill, dark label — M3 `bg-primary text-on-primary`. 56 tall,
  /// radius 16. The dominant CTA.
  primaryBlack,

  /// Terracotta fill, dark label — M3 `bg-secondary text-on-secondary`.
  /// 48 tall, radius 16.
  primaryOrange,

  /// Terracotta ramp fill with a soft glow. 52 tall pill.
  primaryGradient,

  /// `surface-container` fill, ink label, 40 tall pill.
  secondaryPill,

  /// `surface-container-high` fill, 32 tall, radius 12. Inline affordance
  /// ("Start", "Details").
  smallInline,

  /// Transparent fill + hairline outline, 36 tall pill.
  ghostOutline,

  /// errorSoft fill with errorInk label — destructive confirmations.
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
          r: 16,
          px: 24,
          text: OCTypography.button,
          gap: 8,
          icon: 20,
        ),
        OCButtonVariant.primaryOrange: (
          h: 48,
          r: 16,
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
          r: 12,
          px: 14,
          text: OCTypography.metaStrong,
          gap: 6,
          icon: 16,
        ),
        OCButtonVariant.ghostOutline: (
          h: 36,
          r: 9999,
          px: 16,
          text: OCTypography.metaStrong,
          gap: 6,
          icon: 16,
        ),
        OCButtonVariant.danger: (
          h: 48,
          r: 16,
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
          bg: OCColors.cta,
          fg: OCColors.onCta,
          gradient: null,
          shadow: OCShadow.floatingCta,
          border: null,
        );
      case OCButtonVariant.primaryOrange:
        return (
          bg: OCColors.secondary,
          fg: OCColors.onSecondary,
          gradient: null,
          shadow: OCShadow.none,
          border: null,
        );
      case OCButtonVariant.primaryGradient:
        return (
          bg: OCColors.secondary,
          fg: OCColors.onSecondary,
          gradient: OCGradient.ctaSunset,
          shadow: OCShadow.coloredCtaGlow,
          border: null,
        );
      case OCButtonVariant.secondaryPill:
        return (
          bg: OCColors.surfaceElevated,
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
            style: spec.text.copyWith(color: paint.fg),
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
          curve: OCMotion.curve,
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
  /// `surface-container-low` on the `surface` canvas — the default container.
  default_,

  /// Warm container gradient; put inner cells on top of it.
  tinted,

  /// Container gradient meant to sit behind illustration/avatar slots.
  hero,
}

/// `surface-container-low` container: radius 16, soft shadow, 16px padding.
class OCCard extends StatelessWidget {
  const OCCard({
    super.key,
    required this.child,
    this.variant = OCCardVariant.default_,
    this.padding = const EdgeInsets.all(OCSpace.cardPad),
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
    final paint = switch (variant) {
      OCCardVariant.default_ => gradient,
      OCCardVariant.tinted => gradient ?? OCGradient.heroPastelBlend,
      OCCardVariant.hero => gradient ?? OCGradient.heroSky,
    };

    final shape = BorderRadius.circular(OCRadius.card);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        // A card is one container step above the canvas the page sits on.
        color: paint == null ? OCColors.surface : Colors.transparent,
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

/// The `surface-container` / radius-12 fill used for rows and stat tiles inside
/// a card. Separation comes from fill contrast, never from a shadow or a border.
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
    this.radius = OCRadius.sm,
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

/// Tinted squircle that holds a glyph: radius 12, container fill, accent glyph.
/// 48dp for grids, 28dp for inline chips.
class OCIconTile extends StatelessWidget {
  const OCIconTile({
    super.key,
    required this.icon,
    this.accent = OCAccent.orange,
    this.size = 48,
    this.iconSize = 22,
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
        color: solid ? OCColors.onCta : (color ?? accent.ink),
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
    // The design separates avatars from the canvas with a 2px
    // `ring-surface-container-lowest`, not a white ring.
    const ringColor = OCColors.surfaceLowest;
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
        border: Border.all(color: ringColor, width: 2),
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
              border: Border.all(color: ringColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlapping circles, -8px margin, deepest-container ring between them.
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

/// M3 switch: 52x32, white track with a dark thumb when on, `container-high`
/// track when off. 48dp hit area. [onChanged] null renders the disabled state.
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
                curve: OCMotion.curve,
                width: 52,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: value ? OCColors.cta : OCColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(OCRadius.full),
                ),
                child: AnimatedAlign(
                  duration: OCMotion.base,
                  curve: OCMotion.curve,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: value ? OCColors.onCta : OCColors.textSecondary,
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

/// `surface-container-low` track, 4px padding, 40px pill items; the active one
/// is `bg-primary` white with a dark label — the design's segmented control.
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
        color: OCColors.surface,
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

// ---------------------------------------------------------------------
// List row
// ---------------------------------------------------------------------

/// The single row style for every list in the app: 40dp accent icon tile,
/// title + optional subtitle, trailing slot. Rows are never denser than the
/// 48dp tap target and always sit 8dp apart.
class OCListRow extends StatelessWidget {
  const OCListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.accent = OCAccent.neutral,
    this.iconTileSize = 40,
    this.iconSize = 20,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.background,
    this.titleMaxLines = 1,
    this.titleStyle,
    this.subtitleStyle,
    this.margin = const EdgeInsets.symmetric(
      horizontal: OCSpace.screenX,
      vertical: OCSpace.tapGap / 2,
    ),
    this.minHeight,
  });

  final String title;
  final Widget? subtitle;
  final IconData? leadingIcon;
  final OCAccent accent;
  final double iconTileSize;
  final double iconSize;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final Color? background;
  final int titleMaxLines;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry margin;

  /// Row height floor. Rows are denser than the 48dp touch minimum, which is
  /// correct for a list but was too cramped to read titles in.
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(OCRadius.inner);
    return Padding(
      padding: margin,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: shape,
          child: Container(
            constraints: BoxConstraints(
              minHeight: minHeight ?? OCSpace.tapTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: OCSpace.md,
              vertical: OCSpace.sm,
            ),
            decoration: BoxDecoration(
              // A selected row is a container step up, not an accent wash.
              color:
                  background ??
                  (selected ? OCColors.surfaceHigh : Colors.transparent),
              borderRadius: shape,
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  OCIconTile(
                    icon: leadingIcon!,
                    accent: accent,
                    size: iconTileSize,
                    iconSize: iconSize,
                  ),
                  const SizedBox(width: OCSpace.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style:
                            titleStyle ??
                            OCTypography.title.copyWith(color: context.oc.ink),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: OCSpace.xxs),
                        DefaultTextStyle.merge(
                          style: OCTypography.caption.copyWith(
                            color: context.oc.mute,
                          ),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: OCSpace.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Breadcrumbs
// ---------------------------------------------------------------------

/// One tappable row that shows the current path and replaces both the
/// breadcrumb strip and the raw path field. Every crumb is a 48dp target and
/// the trailing edit glyph opens the path editor.
class OCBreadcrumbs extends StatelessWidget {
  const OCBreadcrumbs({
    super.key,
    required this.crumbs,
    required this.onOpen,
    required this.onEdit,
    this.leadingIcon = Icons.folder_outlined,
    this.editTooltip = 'Enter a path',
  });

  /// Ordered root-first list of `(label, absolute path)` segments.
  final List<({String label, String path})> crumbs;
  final ValueChanged<String> onOpen;
  final VoidCallback onEdit;
  final IconData leadingIcon;
  final String editTooltip;

  @override
  Widget build(BuildContext context) {
    final last = crumbs.isEmpty ? 0 : crumbs.length - 1;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.tapGap / 2,
      ),
      decoration: BoxDecoration(
        color: OCColors.surface,
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: OCSpace.md),
            child: OCIconTile(
              icon: leadingIcon,
              accent: OCAccent.orange,
              size: 32,
              iconSize: 17,
            ),
          ),
          const SizedBox(width: OCSpace.sm),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 0),
              itemCount: crumbs.length,
              itemBuilder: (_, i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0)
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: OCColors.textTertiary,
                    ),
                  Semantics(
                    button: true,
                    label: crumbs[i].label,
                    child: InkWell(
                      onTap: () => onOpen(crumbs[i].path),
                      borderRadius: BorderRadius.circular(OCRadius.xs),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: OCSpace.tapTarget,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OCSpace.sm,
                          ),
                          child: Center(
                            child: Text(
                              crumbs[i].label,
                              style: OCTypography.caption.copyWith(
                                color: i == last
                                    ? OCColors.orangeInk
                                    : OCColors.textPrimary,
                                fontWeight: i == last
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tooltip(
            message: editTooltip,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: OCColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Filter button
// ---------------------------------------------------------------------

/// 48dp filter affordance. [active] paints the tonal tint so the header
/// never hides a filter that is currently on.
class OCFilterButton extends StatelessWidget {
  const OCFilterButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.icon = Icons.tune,
    this.active = false,
    this.trailing,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool active;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: OCSpace.tapTarget,
          height: OCSpace.tapTarget,
          child: Material(
            color: active ? OCColors.orangeTint : OCColors.surface,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: active ? OCColors.orangeInk : OCColors.textPrimary,
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: OCSpace.xs),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------

/// Pulsing placeholder block. Used instead of a bare spinner when a list is
/// still loading, so the layout does not jump when the data arrives.
class OCSkeleton extends StatefulWidget {
  const OCSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = OCRadius.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<OCSkeleton> createState() => _OCSkeletonState();
}

class _OCSkeletonState extends State<OCSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: OCColors.surfaceMuted.withValues(
            alpha: 0.45 + 0.55 * _c.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A few skeleton rows shaped like [OCListRow].
class OCSkeletonList extends StatelessWidget {
  const OCSkeletonList({
    super.key,
    this.rows = 6,
    this.rowHeight = OCSpace.tapTarget + OCSpace.sm,
    this.semanticLabel,
  });

  final int rows;
  final double rowHeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: OCSpace.sm),
        itemCount: rows,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OCSpace.screenX,
            vertical: OCSpace.tapGap / 2,
          ),
          child: Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: OCColors.surface,
              borderRadius: BorderRadius.circular(OCRadius.inner),
            ),
            padding: const EdgeInsets.all(OCSpace.md),
            child: Row(
              children: [
                const OCSkeleton(width: 40, height: 40, radius: OCRadius.tile),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OCSkeleton(width: math.max(72, 180 - i * 12), height: 13),
                      const SizedBox(height: OCSpace.sm),
                      OCSkeleton(width: 96, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
