part of '../primitives.dart';

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
