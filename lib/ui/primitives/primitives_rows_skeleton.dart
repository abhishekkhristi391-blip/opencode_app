part of '../primitives.dart';

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
