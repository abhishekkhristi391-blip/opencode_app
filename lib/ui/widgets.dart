import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'line_icons.dart';
import 'primitives.dart';
import 'theme.dart';

/// Pushes a plain content screen with a token title bar. Used by every
/// secondary screen so they share one title style and one back button.
Future<void> pushScreen(
  BuildContext context, {
  required String title,
  required Widget child,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: child),
    ),
  ),
);

/// Lightweight toast that doesn't steal focus like SnackBar.
/// Uses an OverlayEntry so it works anywhere (dialogs, sheets, etc.)
void showToast(BuildContext context, String msg, {bool error = false}) {
  if (!context.mounted) return;
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ToastWidget(
      message: msg,
      error: error,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool error;
  final VoidCallback onDismiss;
  const _ToastWidget({
    required this.message,
    required this.error,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: OCMotion.base,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = widget.error ? OCAccent.red : OCAccent.green;
    return Positioned(
      bottom: OCSpace.ctaBottom,
      left: OCSpace.screenX,
      right: OCSpace.screenX,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, 20 * (1 - _c.value)),
          child: Opacity(
            opacity: _c.value,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.lg,
                  vertical: OCSpace.md,
                ),
                decoration: BoxDecoration(
                  color: widget.error ? accent.tint : cs.surface,
                  borderRadius: BorderRadius.circular(OCRadius.inner),
                  boxShadow: OCShadow.cardHover,
                ),
                child: Row(
                  children: [
                    // Status is icon + colour, never colour alone.
                    OCIconTile(
                      icon: widget.error
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      accent: accent,
                      size: 28,
                      iconSize: 16,
                    ),
                    const SizedBox(width: OCSpace.md),
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.body.copyWith(
                          color: widget.error
                              ? accent.ink
                              : OCColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Back-compat: uses toast instead of SnackBar
void showSnack(BuildContext context, String msg, {bool error = false}) {
  showToast(context, msg, error: error);
}

/// Undo bar for destructive-but-reversible actions. A real [SnackBar] rather
/// than the toast, because it needs the action slot.
void showUndoSnack(BuildContext context, String msg, VoidCallback onUndo) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(label: S.historyUndo, onPressed: onUndo),
      ),
    );
}

void copyToClipboard(
  BuildContext context,
  String text, [
  String label = S.copied,
]) {
  Clipboard.setData(ClipboardData(text: text));
  showToast(context, label);
}

/// Empty / error state: big tinted squircle, bold headline, grey support text,
/// optional single action. Everything centred, per the design system.
class EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const EmptyHint({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OCSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: OCColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(OCRadius.xl),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 30, color: OCColors.textTertiary),
            ),
            const SizedBox(height: OCSpace.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: OCTypography.h3.copyWith(color: OCColors.textPrimary),
            ),
            const SizedBox(height: OCSpace.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: OCTypography.caption.copyWith(
                color: OCColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: OCSpace.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: action!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String? label;
  const LoadingView({super.key, this.label});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OCProgressRing(value: 0.7, size: 32, animate: true),
        if (label != null) ...[
          const SizedBox(height: OCSpace.md),
          Text(
            label!,
            style: OCTypography.caption.copyWith(color: OCColors.textSecondary),
          ),
        ],
      ],
    ),
  );
}

class ConnectionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ConnectionErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(OCSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: OCSpace.xl),
            const OCIconTile(
              icon: Icons.cloud_off,
              accent: OCAccent.red,
              size: 72,
              iconSize: 30,
            ),
            const SizedBox(height: OCSpace.lg),
            Text(
              S.connectionFailedTitle,
              textAlign: TextAlign.center,
              style: OCTypography.h3.copyWith(color: OCColors.textPrimary),
            ),
            const SizedBox(height: OCSpace.sm),
            SelectableText(
              message,
              textAlign: TextAlign.center,
              style: OCTypography.caption.copyWith(
                color: OCColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: OCSpace.xl),
            OCButton(
              label: S.retry,
              icon: Icons.refresh,
              variant: OCButtonVariant.primaryOrange,
              expand: false,
              onPressed: onRetry,
            ),
            const SizedBox(height: OCSpace.xxl),
            OCCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.serverSetupTitle, style: OCTypography.h3),
                  const SizedBox(height: OCSpace.md),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(OCRadius.inner),
                      border: Border.all(color: const Color(0xFF3A3A3A)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: OCSpace.md + 2,
                      vertical: OCSpace.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Mono(
                            S.serverSetupCommand,
                            size: 12,
                            color: const Color(0xFFE8E8E6),
                          ),
                        ),
                        const SizedBox(width: OCSpace.sm),
                        InkWell(
                          onTap: () =>
                              copyToClipboard(context, S.serverSetupCommand),
                          borderRadius: BorderRadius.circular(OCRadius.inner),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Color(0xFFB0B0AE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: OCSpace.md),
                  Text(S.serverSetupNote, style: OCTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  int maxLines = 1,
  String confirm = S.save,
}) async {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        OCButton(
          label: S.cancel,
          variant: OCButtonVariant.ghostOutline,
          expand: false,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: OCSpace.sm),
        OCButton(
          label: confirm,
          variant: OCButtonVariant.primaryOrange,
          expand: false,
          onPressed: () => Navigator.pop(context, c.text),
        ),
      ],
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = S.yes,
  bool danger = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        OCButton(
          label: S.cancel,
          variant: OCButtonVariant.ghostOutline,
          expand: false,
          onPressed: () => Navigator.pop(context, false),
        ),
        const SizedBox(width: OCSpace.sm),
        OCButton(
          label: confirm,
          variant: danger
              ? OCButtonVariant.danger
              : OCButtonVariant.primaryOrange,
          expand: false,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
  return r ?? false;
}

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
class HeaderAction {
  const HeaderAction({
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
  final List<HeaderAction> actions;

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
                    for (final a in actions)
                      HeaderButton(
                        icon: a.icon,
                        label: a.label,
                        onTap: a.onTap,
                        badge: a.badge,
                        accent: a.accent,
                      ),
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

/// A header icon button. Exactly 48x48, with a tooltip and a semantics label.
class HeaderButton extends StatelessWidget {
  const HeaderButton({
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
  final int badge;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tooltip(
          message: label,
          child: Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: OCSpace.tapTarget,
                  height: OCSpace.tapTarget,
                  child: Center(
                    child: LIcon(icon, size: 22, color: accent ? t.acc : t.ink),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(right: 2, top: 2, child: CountBadge(n: badge)),
      ],
    );
  }
}

/// Small count bubble, e.g. 4 open todos.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.n});
  final int n;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      label: '$n',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.acc,
          borderRadius: BorderRadius.circular(OCRadius.pill),
          border: Border.all(color: t.bg, width: 1.5),
        ),
        child: Text(
          n > 99 ? '99+' : '$n',
          style: OCTypography.caption.copyWith(
            color: t.onAcc,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  final Widget? trailing;
  const InfoRow(
    this.label,
    this.value, {
    super.key,
    this.mono = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: OCSpace.screenX,
      vertical: OCSpace.sm,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 108, child: Text(label, style: OCTypography.caption)),
        Expanded(
          child: mono
              ? Mono(value)
              : SelectableText(
                  value,
                  style: OCTypography.body.copyWith(
                    color: OCColors.textPrimary,
                  ),
                ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

IconData toolIcon(String name) => switch (name) {
  'bash' || 'shell' => Icons.terminal,
  'read' => Icons.menu_book_outlined,
  'write' || 'edit' || 'patch' || 'multiedit' => Icons.edit_note,
  'grep' || 'search' => Icons.manage_search,
  'glob' || 'list' => Icons.folder_outlined,
  'webfetch' => Icons.cloud_download_outlined,
  'websearch' => Icons.travel_explore,
  'task' || 'agent' => Icons.smart_toy_outlined,
  'todowrite' || 'todoread' => Icons.checklist,
  'invalid' => Icons.block,
  _ => Icons.build_outlined,
};

Color toolColor(ToolStatus s, ColorScheme cs) => switch (s) {
  ToolStatus.completed => OCColors.green,
  ToolStatus.error => cs.error,
  ToolStatus.running => OCColors.warning,
  ToolStatus.pending => cs.outline,
  ToolStatus.unknown => cs.outline,
};
