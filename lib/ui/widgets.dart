import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
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
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const StatusPill(this.text, this.color, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.sm + 2,
        vertical: OCSpace.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: OCSpace.xs),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: OCSpace.xs + 2),
          ],
          Text(
            text,
            style: OCTypography.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
