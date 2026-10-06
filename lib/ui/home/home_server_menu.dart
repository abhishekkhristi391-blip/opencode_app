part of '../home.dart';

/// The server menu, anchored under the avatar.
///
/// The reference shows a latency pill, a TLS session id and a Resource Usage
/// row. This client measures none of them, so the rows that need real numbers
/// are absent rather than showing placeholders.
class _ServerMenu extends StatelessWidget {
  const _ServerMenu({
    required this.host,
    required this.version,
    required this.state,
    required this.onClose,
    required this.onOpen,
    required this.onServer,
    required this.onReview,
    this.pending = 0,
  });

  final String host;
  final String version;
  final OcLinkState state;
  final VoidCallback onClose;
  final void Function(Widget Function() page, String title) onOpen;
  final VoidCallback onServer;

  /// Opens the oldest pending prompt without leaving the current screen.
  final VoidCallback onReview;

  /// Pending approvals/questions across all sessions. Zero hides the row.
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OCSpace.md,
          0,
          OCSpace.md,
          0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Material(
            color: OCColors.surfaceElevated,
            borderRadius: BorderRadius.circular(OCRadius.lg),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shadowColor: const Color(0xB3000000),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ServerMenuHeader(
                  host: host,
                  version: version,
                  state: state,
                  onClose: onClose,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: OCSpace.xs,
                  ),
                  child: Column(
                    children: [
                      if (pending > 0)
                        _MenuRow(
                          icon: LI.shield,
                          label: S.menuWaitingForYou(pending),
                          accent: true,
                          showChevron: true,
                          onTap: onReview,
                        ),
                      _MenuRow(
                        icon: LI.server,
                        label: S.menuSwitchServer,
                        value: host,
                        onTap: onServer,
                      ),
                      _MenuRow(
                        icon: LI.key,
                        label: S.menuProviders,
                        value: S.moreModel,
                        onTap: () => onOpen(
                          () => const SettingsPage(),
                          S.menuProviders,
                        ),
                      ),
                      _MenuRow(
                        icon: LI.settings,
                        label: S.menuSettings,
                        onTap: () => onOpen(
                          () => const SettingsPage(),
                          S.navSettings,
                        ),
                      ),
                      _MenuRow(
                        icon: LI.info,
                        label: S.menuAbout,
                        value: version.isEmpty ? S.appVersion : version,
                        onTap: () => onOpen(
                          () => const AboutPage(),
                          S.navAbout,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OCSpace.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Identity, server version and the connection state at the top of the menu.
class _ServerMenuHeader extends StatelessWidget {
  const _ServerMenuHeader({
    required this.host,
    required this.version,
    required this.state,
    required this.onClose,
  });

  final String host;
  final String version;
  final OcLinkState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = switch (state) {
      OcLinkState.connected => t.ok,
      OcLinkState.reconnecting => t.warn,
      OcLinkState.offline || OcLinkState.offlineCached => t.err,
    };
    return Container(
      width: double.infinity,
      color: OCColors.surfaceHigh.withValues(alpha: 0.60),
      padding: const EdgeInsets.all(OCSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    OCAvatar(
                      label: host,
                      size: 48,
                      accent: OCAccent.orange,
                      status: switch (state) {
                        OcLinkState.connected => OCStatus.online,
                        OcLinkState.reconnecting => OCStatus.busy,
                        OcLinkState.offline ||
                        OcLinkState.offlineCached => OCStatus.offline,
                      },
                    ),
                    const SizedBox(width: OCSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            host,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.meta.copyWith(color: t.ink),
                          ),
                          Text(
                            version.isEmpty
                                ? S.appVersion
                                : S.menuServerVersion(version),
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
              _DrawerIconButton(
                icon: LI.close,
                label: S.menuCloseTooltip,
                onTap: onClose,
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          // The state is spelled out, never left to the dot colour alone.
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: Text(
                  state.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.micro.copyWith(
                    color: t.mute,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A menu row: 36dp icon tile on `surface-container-highest`, label, optional
/// value, chevron.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.accent = false,
    this.showChevron = true,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  /// The pending-approvals row: accent-filled icon tile, because this is the
  /// one row in the menu that resolves a blocked run rather than navigating.
  final bool accent;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OCRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OCSpace.md,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent ? t.accSoft : OCColors.surfaceHighest,
                    borderRadius: BorderRadius.circular(OCRadius.xs),
                  ),
                  child: Center(
                    child: LIcon(
                      icon,
                      size: 20,
                      color: accent ? t.acc : t.mute,
                    ),
                  ),
                ),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.meta.copyWith(color: t.ink),
                      ),
                      if (value != null && value!.isNotEmpty)
                        Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OCTypography.micro.copyWith(color: t.mute),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: OCSpace.sm),
                if (showChevron)
                  LIcon(
                    LI.chevronRight,
                    size: 18,
                    color: accent ? t.acc : OCColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A sheet row: 56dp, leading icon, label left, muted value right, chevron.
///
/// The value column is optional. Rows that only navigate had a value that
/// repeated the label ("Settings and token usage / Settings and token usage"),
/// which reads as a rendering bug rather than information.
class _SheetOption extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
            child: Row(
              children: [
                LIcon(icon, size: 20, color: t.mute, strokeWidth: 1.9),
                const SizedBox(width: OCSpace.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.body.copyWith(color: t.ink),
                  ),
                ),
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(width: OCSpace.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: OCTypography.caption.copyWith(color: t.mute),
                    ),
                  ),
                ],
                const SizedBox(width: OCSpace.sm),
                LIcon(LI.chevronRight, size: 16, color: t.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sheet section heading. `Session` / `Agent` / `App`.
class _SheetGroup extends StatelessWidget {
  final String label;
  const _SheetGroup(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      OCSpace.screenX,
      OCSpace.lg,
      OCSpace.screenX,
      OCSpace.sm,
    ),
    child: Text(
      label.toUpperCase(),
      style: OCTypography.caption.copyWith(
        color: context.oc.mute,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),
  );
}
