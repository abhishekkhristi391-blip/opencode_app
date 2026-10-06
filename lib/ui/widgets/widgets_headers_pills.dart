part of '../widgets.dart';

/// Tiny uppercase section label. All-caps is allowed here and nowhere else.
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      OCSpace.screenX,
      OCSpace.lg,
      OCSpace.screenX,
      OCSpace.sm,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: OCTypography.micro.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: OCColors.textTertiary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class Mono extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final bool wrap;
  const Mono(
    this.text, {
    super.key,
    this.size = 12,
    this.color,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = Text(
      text,
      style: OCTypography.mono(color: color, size: size),
    );
    return wrap
        ? t
        : SingleChildScrollView(scrollDirection: Axis.horizontal, child: t);
  }
}

/// Tinted rounded cell (radius 16) that pairs an icon with a label, so status
/// is never communicated by colour alone.
/// Whether animation should be suppressed: the OS "remove animations"
/// accessibility setting, or the platform asking for reduced motion.
///
/// Every looping or scale animation in the app must route through this. A
/// pulsing dot is decorative; for a motion-sensitive user it is a hazard, and
/// Flutter keeps animating unless something explicitly stops it.
bool ocReduceMotion(BuildContext context) {
  final mq = MediaQuery.maybeOf(context);
  if (mq == null) return false;
  return mq.disableAnimations || mq.accessibleNavigation;
}

/// Connection state for [StatusPill].
enum OcLinkState {
  connected(S.statusConnected),
  reconnecting(S.statusReconnecting),
  offline(S.statusOffline),
  offlineCached(S.statusOfflineCached);

  const OcLinkState(this.label);
  final String label;
}

/// The app's one connection indicator: dot + label, in the header, nowhere else.
///
/// Four states, because "Offline" next to a full list of chats was misleading -
/// the list was real, it came from the local cache, and the header said the
/// server was gone. [offlineCached] says both things.
///
/// The dot pulses only while reconnecting, and only if the OS has animations on.
///
/// No pill chrome: the reference draws a bare 8dp dot next to a small label.
/// All four states stay separable without relying on hue alone - each carries a
/// text label, [offlineCached] and [reconnecting] additionally get a ring, so
/// colour-blind users and greyscale screenshots can still tell them apart.
class StatusPill extends StatefulWidget {
  const StatusPill({
    super.key,
    required this.state,
    this.detail,
    this.cachedCount,
    this.onRetry,
  });

  final OcLinkState state;

  /// Secondary text, e.g. the server version.
  final String? detail;

  /// How many cached sessions are on screen, for the honest offline label.
  final int? cachedCount;

  /// When set, the pill grows a Retry button. Offline is only useful if the
  /// user can do something about it.
  final VoidCallback? onRetry;

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: OCMotion.pulse,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(StatusPill old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _sync();
  }

  void _sync() {
    if (widget.state == OcLinkState.reconnecting && !ocReduceMotion(context)) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = switch (widget.state) {
      OcLinkState.connected => t.ok,
      OcLinkState.reconnecting => t.warn,
      OcLinkState.offline || OcLinkState.offlineCached => t.err,
    };
    // Two of the four states get a ring as well as a hue, so the state does not
    // depend on colour alone.
    final ringed = widget.state == OcLinkState.offlineCached ||
        widget.state == OcLinkState.reconnecting;
    final label =
        widget.state == OcLinkState.offlineCached && widget.cachedCount != null
        ? S.statusCached(widget.cachedCount!)
        : widget.state.label;

    return Semantics(
      liveRegion: widget.state != OcLinkState.connected,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: widget.state == OcLinkState.reconnecting
                  ? _pulse.drive(Tween(begin: 0.3, end: 1.0))
                  : const AlwaysStoppedAnimation(1),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: ringed
                      ? Border.all(color: color.withValues(alpha: 0.45))
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Ellipsis, never wrap: this sits in a header row next to up to
            // three 48px buttons, and at 1.3x text scale a long status would
            // otherwise take the buttons off-screen.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OCTypography.caption.copyWith(
                  color: t.mute,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.detail != null && widget.detail!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OCTypography.micro.copyWith(color: t.mute),
                ),
              ),
            ],
            if (widget.onRetry != null) ...[
              const SizedBox(width: OCSpace.xs),
              Semantics(
                button: true,
                label: S.statusRetryTooltip,
                excludeSemantics: true,
                child: InkWell(
                  onTap: widget.onRetry,
                  borderRadius: BorderRadius.circular(OCRadius.pill),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: OCSpace.tapTarget,
                    ),
                    child: Center(
                      child: Text(
                        S.statusRetry,
                        style: OCTypography.meta.copyWith(
                          color: t.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header status from the store's three flags.
///
/// Offline with cached sessions is its own state: the screen still has real
/// content, so saying only "Offline" makes the app look broken when it is not.
OcLinkState ocLinkState(OcStore store) {
  if (!store.online) {
    final cached = store.sessions.where(
      (s) => s.title != OcStore.utilSessionTitle,
    );
    return cached.isEmpty ? OcLinkState.offline : OcLinkState.offlineCached;
  }
  return store.reconnecting ? OcLinkState.reconnecting : OcLinkState.connected;
}

/// One header button. [label] is the tooltip AND the semantics label, so the
/// two can never drift apart.
///
/// A widget rather than a description of one, so that an action which has to
/// repaint on its own — the todo badge follows `store.todoList` instead of the
/// app-wide notifier — can wrap itself in a `ListenableBuilder` and still sit in
/// the same list as the plain ones.
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.accent = false,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;

  /// Count bubble, e.g. open todos.
  final int badge;

  /// Uses the accent colour. Reserved for the single primary action.
  final bool accent;

  @override
  Widget build(BuildContext context) => HeaderButton(
    icon: icon,
    label: label,
    onTap: onTap,
    badge: badge,
    accent: accent,
  );
}

/// The app bar: [leading], title, one [StatusPill], then [actions] and [avatar].
///
/// Actions are passed in per screen instead of being hard-coded, because the
/// same three icons (Tasks / New chat / More) on Files and Terminal meant
/// Tasks opened on the terminal and New chat discarded the terminal.
///
/// [leading] and [avatar] are the shell's navigation affordances: the drawer
/// handle on the left and the server menu trigger on the right. Both are
/// 48dp even though the reference draws 44.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.status,
    this.actions = const [],
    this.trailing,
    this.leading,
    this.avatar,
  });

  final String title;
  final StatusPill status;

  /// Plain widgets, not only [HeaderAction]s: an action that repaints on its own
  /// signal (the todo badge) wraps itself in a `ListenableBuilder`, and the type
  /// has to allow that without a second parallel list.
  final List<Widget> actions;

  /// Anything that does not fit the icon row, e.g. a search field.
  final Widget? trailing;

  /// Left slot, outside the title block. The drawer handle.
  final Widget? leading;

  /// Right slot after the action row, e.g. the avatar button.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OCColors.bg.withValues(alpha: 0.90),
        // The reference's `shadow-[0_4px_20px_rgba(0,0,0,0.35)]`.
        boxShadow: [
          BoxShadow(
            color: const Color(0x59000000),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: OCSpace.screenX),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: OCSpace.xs),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.title.copyWith(
                              color: t.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          status,
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: OCSpace.sm),
                      trailing!,
                    ],
                    for (final a in actions) a,
                    if (avatar != null) ...[
                      const SizedBox(width: OCSpace.sm),
                      avatar!,
                    ],
                    const SizedBox(width: OCSpace.sm),
                  ],
                ),
              ),
            ),
            // The reference's 1px `bg-outline-variant/30` under the bar.
            Container(
              height: 1,
              color: OCColors.border.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
