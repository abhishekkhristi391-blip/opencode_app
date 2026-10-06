part of '../home.dart';

/// The avatar trigger in the header: the reference's `bg-primary` circle with
/// a person glyph in `on-primary`, at 32dp inside a 48dp target.
class _AvatarButton extends StatefulWidget {
  const _AvatarButton({required this.onTap, this.pending = 0});
  final VoidCallback onTap;

  /// Pending permission/question requests across every session. Zero hides the
  /// badge, so it clears the instant the last one is answered — here, or in the
  /// TUI, which reaches us as a `*.replied` event.
  final int pending;

  @override
  State<_AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<_AvatarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: OCMotion.pulse,
  );

  Timer? _settle;

  @override
  void initState() {
    super.initState();
    if (widget.pending > 0) _startPulse();
  }

  /// Three seconds of attention, then still. A badge that breathes forever is
  /// noise once it has been on screen longer than it takes to notice it.
  void _startPulse() {
    _pulse.repeat(reverse: true);
    _settle?.cancel();
    _settle = Timer(const Duration(seconds: 3), () {
      if (mounted) _pulse.stop();
    });
  }

  @override
  void didUpdateWidget(_AvatarButton old) {
    super.didUpdateWidget(old);
    if (widget.pending > old.pending) {
      _startPulse();
    } else if (widget.pending == 0) {
      _settle?.cancel();
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _settle?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final n = widget.pending;
    return Semantics(
      button: true,
      label: n > 0
          ? '${S.menuOpenTooltip}. ${S.promptSemantics(n)}'
          : S.menuOpenTooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: n > 0
            ? '${S.menuOpenTooltip} \u2022 ${S.promptSemantics(n)}'
            : S.menuOpenTooltip,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: widget.onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: OCSpace.tapTarget,
              height: OCSpace.tapTarget,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: OCColors.cta,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: LIcon(LI.person, size: 18, color: OCColors.onCta),
                      ),
                    ),
                  ),
                  if (n > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: _PromptCountBadge(
                        n: n,
                        pulse: _pulse,
                        ring: t.bg,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The terracotta count bubble on the avatar: pending approvals and questions
/// only.
///
/// Deliberately not [CountBadge]: that one means "open tasks" and rides the
/// header action row, so reusing it here would make two different meanings look
/// like one. This rides the avatar corner, fills with the accent, and takes a
/// 2dp ring in the page background so it stays legible over the white circle.
class _PromptCountBadge extends StatelessWidget {
  const _PromptCountBadge({
    required this.n,
    required this.pulse,
    required this.ring,
  });

  final int n;
  final Animation<double> pulse;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      label: S.promptSemantics(n),
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) => Transform.scale(
          // Scale only. A colour flicker would read as a fresh event on every
          // frame, which is exactly the false signal this badge must not send.
          scale: 1 + 0.10 * pulse.value,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.acc,
              borderRadius: BorderRadius.circular(OCRadius.pill),
              border: Border.all(color: ring, width: 2),
            ),
            child: Text(
              n > 9 ? '9+' : '$n',
              style: OCTypography.caption.copyWith(
                color: t.onAcc,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A pill badge used in the drawer: `bg-surface-container-highest` for neutral
/// values, `bg-secondary-container` for the pending-todos count.
class _DrawerBadge extends StatelessWidget {
  const _DrawerBadge(this.label, {this.accent = false, this.pill = false});
  final String label;
  final bool accent;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: EdgeInsets.symmetric(
        horizontal: accent ? OCSpace.sm : 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accent ? OCColors.secondary : OCColors.surfaceHighest,
        borderRadius: BorderRadius.circular(
          pill ? OCRadius.full : OCRadius.xs,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: OCTypography.micro.copyWith(
          color: accent ? OCColors.onSecondary : OCColors.textTertiary,
        ),
      ),
    );
  }
}

/// The navigation drawer. 82% of the width, capped at 340, on
/// `surface-container-low`, with the destinations above a recent-chat feed.
class _Drawer extends StatelessWidget {
  const _Drawer({
    required this.version,
    required this.host,
    required this.index,
    required this.pending,
    required this.pendingPrompts,
    required this.recents,
    required this.currentId,
    required this.state,
    required this.onClose,
    required this.onNewChat,
    required this.onPick,
    required this.onPushTodos,
    required this.onPushCommands,
    required this.onOpenSession,
    required this.onReviewPrompt,
  });

  final String version;
  final String host;
  final int index;

  /// Open todos, for the Todos row.
  final int pending;

  /// Pending approvals and questions. Its own row, at the top of the
  /// destinations: a blocked run is more urgent than any destination, and the
  /// drawer is one of the places a user goes when something seems stuck.
  final int pendingPrompts;
  final List<Session> recents;
  final String? currentId;
  final OcLinkState state;
  final VoidCallback onClose;
  final VoidCallback onNewChat;
  final ValueChanged<int> onPick;
  final VoidCallback onPushTodos;
  final VoidCallback onPushCommands;
  final ValueChanged<Session> onOpenSession;
  final VoidCallback onReviewPrompt;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          width: 340,
          color: OCColors.surface,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OCSpace.screenX,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: OCSpace.md,
                          bottom: OCSpace.lg,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      S.appName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: OCTypography.headline.copyWith(
                                        color: OCColors.cta,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: OCSpace.sm),
                                  _DrawerBadge(
                                    version.isEmpty ? S.appVersion : version,
                                    pill: true,
                                  ),
                                ],
                              ),
                            ),
                            _DrawerIconButton(
                              icon: LI.close,
                              label: S.drawerCloseTooltip,
                              onTap: onClose,
                            ),
                          ],
                        ),
                      ),
                      if (pendingPrompts > 0)
                        _DrawerNavRow(
                          icon: LI.shield,
                          label: S.menuWaitingForYou(pendingPrompts),
                          selected: false,
                          valueAccent: true,
                          onTap: onReviewPrompt,
                        ),
                      _DrawerNavRow(
                        icon: LI.chat,
                        label: S.drawerNavChats,
                        selected: index == 0,
                        onTap: () => onPick(0),
                      ),
                      _DrawerNavRow(
                        icon: LI.history,
                        label: S.drawerNavHistory,
                        selected: index == 1,
                        onTap: () => onPick(1),
                      ),
                      _DrawerNavRow(
                        icon: LI.folder,
                        label: S.drawerNavFiles,
                        selected: index == 2,
                        value: HomeShellState._worktree(
                          AppScope.read(context),
                        ),
                        onTap: () => onPick(2),
                      ),
                      _DrawerNavRow(
                        icon: LI.terminal,
                        label: S.drawerNavTerminal,
                        selected: index == 3,
                        onTap: () => onPick(3),
                      ),
                      _DrawerNavRow(
                        icon: LI.tasks,
                        label: S.drawerNavTodos,
                        value: pending > 0 ? S.drawerPending(pending) : null,
                        valueAccent: true,
                        onTap: onPushTodos,
                      ),
                      _DrawerNavRow(
                        icon: LI.spark,
                        label: S.drawerNavCommands,
                        onTap: onPushCommands,
                      ),
                      const SizedBox(height: OCSpace.lg),
                      const Divider(height: 1, color: OCColors.surfaceVariant),
                      const SizedBox(height: OCSpace.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.drawerRecents.toUpperCase(),
                              style: OCTypography.micro.copyWith(
                                color: OCColors.textTertiary,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OCSpace.sm),
                      if (recents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: OCSpace.md,
                          ),
                          child: Text(
                            S.drawerRecentsEmpty,
                            style: OCTypography.caption.copyWith(
                              color: t.mute,
                            ),
                          ),
                        )
                      else
                        for (final s in recents)
                          _DrawerRecentRow(
                            session: s,
                            active: s.id == currentId,
                            onTap: () => onOpenSession(s),
                          ),
                    ],
                  ),
                ),
              ),
              _DrawerFooter(
                host: host,
                state: state,
                onNewChat: onNewChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
