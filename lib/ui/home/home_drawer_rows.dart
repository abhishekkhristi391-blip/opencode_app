part of '../home.dart';

/// A 56dp drawer destination. Selected = `surface-container-high` with white
/// text and a terracotta dot on the right, never colour alone.
class _DrawerNavRow extends StatelessWidget {
  const _DrawerNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.value,
    this.valueAccent = false,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? value;
  final bool valueAccent;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Padding(
      padding: const EdgeInsets.only(bottom: OCSpace.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.sm),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
            decoration: BoxDecoration(
              color: selected ? OCColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(OCRadius.sm),
            ),
            child: Row(
              children: [
                LIcon(
                  icon,
                  size: 22,
                  color: selected ? OCColors.orange : t.mute,
                ),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.meta.copyWith(
                      color: selected ? OCColors.cta : t.mute,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(width: OCSpace.sm),
                  _DrawerBadge(value!, accent: valueAccent, pill: valueAccent),
                ] else if (selected) ...[
                  const SizedBox(width: OCSpace.sm),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: OCColors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A recent-chat row. Active session gets `surface-container-high` plus a
/// terracotta bar on the leading edge.
class _DrawerRecentRow extends StatelessWidget {
  const _DrawerRecentRow({
    required this.session,
    required this.active,
    required this.onTap,
  });

  final Session session;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final where = session.directory.trim();
    final age = fmtAge(session.updated);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.sm),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.sm + 2,
              10,
              OCSpace.sm + 2,
              10,
            ),
            decoration: BoxDecoration(
              color: active ? OCColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(OCRadius.sm),
            ),
            child: Row(
              children: [
                if (active)
                  Container(
                    width: 6,
                    height: 24,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: OCColors.orange,
                      borderRadius: BorderRadius.circular(OCRadius.full),
                    ),
                  ),
                LIcon(
                  LI.chat,
                  size: 19,
                  color: active ? OCColors.orange : OCColors.textTertiary,
                ),
                const SizedBox(width: OCSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.body.copyWith(
                          color: active ? OCColors.cta : t.mute,
                        ),
                      ),
                      if (where.isNotEmpty || age.isNotEmpty)
                        Text(
                          [baseName(where), age]
                              .where((e) => e.isNotEmpty)
                              .join(' \u2022 '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.micro.copyWith(color: t.mute),
                        ),
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

/// Drawer footer: identity, the white New chat pill, and the connection line.
class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({
    required this.host,
    required this.state,
    required this.onNewChat,
  });

  final String host;
  final OcLinkState state;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = switch (state) {
      OcLinkState.connected => t.ok,
      OcLinkState.reconnecting => t.warn,
      OcLinkState.offline || OcLinkState.offlineCached => t.err,
    };
    return Container(
      color: OCColors.surfaceElevated,
      padding: const EdgeInsets.fromLTRB(
        OCSpace.screenX,
        OCSpace.md,
        OCSpace.screenX,
        0,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OCAvatar(label: host, size: 40, accent: OCAccent.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.meta.copyWith(
                          color: OCColors.cta,
                        ),
                      ),
                      Text(
                        S.drawerIdentity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.micro.copyWith(
                          color: OCColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: OCSpace.sm),
                Semantics(
                  button: true,
                  label: S.drawerNewChat,
                  excludeSemantics: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onNewChat,
                      borderRadius: BorderRadius.circular(OCRadius.full),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: OCSpace.tapTarget,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: OCSpace.cardPad,
                        ),
                        decoration: BoxDecoration(
                          color: OCColors.cta,
                          borderRadius: BorderRadius.circular(OCRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LIcon(
                              LI.plus,
                              size: 18,
                              color: OCColors.onCta,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              S.drawerNewChat,
                              style: OCTypography.meta.copyWith(
                                color: OCColors.onCta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OCSpace.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: OCSpace.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: OCColors.surface,
                borderRadius: BorderRadius.circular(OCRadius.xs),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  const SizedBox(width: OCSpace.sm),
                  Expanded(
                    child: Text(
                      S.drawerConnectedTo(host),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OCTypography.micro.copyWith(color: t.mute),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OCSpace.md),
          ],
        ),
      ),
    );
  }
}

/// A round icon button: `surface-container` fill, 48dp target.
class _DrawerIconButton extends StatelessWidget {
  const _DrawerIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: OCSpace.tapTarget,
              height: OCSpace.tapTarget,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: OCColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: LIcon(icon, size: 20, color: context.oc.mute),
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
