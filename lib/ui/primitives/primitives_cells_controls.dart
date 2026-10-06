part of '../primitives.dart';

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
