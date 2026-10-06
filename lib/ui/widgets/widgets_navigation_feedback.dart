part of '../widgets.dart';

/// Pushes a plain content screen with a token title bar. Used by every
/// secondary screen so they share one title style and one back button.
///
/// [actions] are the screen's own title-bar actions (a refresh, say). They are
/// passed in per screen rather than hard-coded, for the same reason the shell's
/// header actions are: one screen's refresh button must not appear on another.
Future<void> pushScreen(
  BuildContext context, {
  required String title,
  required Widget child,
  List<Widget> actions = const [],
}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
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
