import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

/// Lightweight toast that doesn't steal focus like SnackBar.
/// Uses an OverlayEntry so it works anywhere (dialogs, sheets, etc.)
void showToast(BuildContext context, String msg, {bool error = false}) {
  if (!context.mounted) return;
  final overlay = Overlay.of(context);
  final cs = Theme.of(context).colorScheme;
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
  const _ToastWidget({required this.message, required this.error, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, 20 * (1 - _c.value)),
          child: Opacity(
            opacity: _c.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.error ? cs.error : cs.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.error ? Icons.error_outline : Icons.check_circle_outline,
                        size: 18, color: widget.error ? cs.onError : cs.onInverseSurface),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5, color: widget.error ? cs.onError : cs.onInverseSurface)),
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

void copyToClipboard(BuildContext context, String text, [String label = 'Copy ho gaya']) {
  Clipboard.setData(ClipboardData(text: text));
  showToast(context, label);
}

class EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const EmptyHint({super.key, required this.icon, required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: cs.outlineVariant),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: cs.outline, fontSize: 13)),
            if (action != null) ...[const SizedBox(height: 18), action!],
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
            const CircularProgressIndicator(),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(label!, style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12)),
            ],
          ],
        ),
      );
}

class ConnectionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ConnectionErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 52, color: cs.error),
            const SizedBox(height: 14),
            const Text('Server se connect nahi ho raha', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SelectableText(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.outline, fontSize: 12.5, height: 1.5)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Termux me server chalu karo:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SelectableText(
                        'cd <project-folder>\nopencode serve --port 4096\n\n# background me:\nnohup opencode serve --port 4096 &',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Server ko usi folder se start karna zaroori hai — file browser aur diff wahi chalti hai.',
                        style: TextStyle(color: cs.outline, fontSize: 11.5)),
                  ],
                ),
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
  String confirm = 'Save',
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text), child: Text(confirm)),
      ],
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Haan',
  bool danger = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return r ?? false;
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.outline,
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
  const Mono(this.text, {super.key, this.size = 12, this.color, this.wrap = true});

  @override
  Widget build(BuildContext context) {
    final t = Text(
      text,
      style: TextStyle(fontFamily: 'monospace', fontFamilyFallback: const ['monospace'], fontSize: size, color: color),
    );
    return wrap ? t : SingleChildScrollView(scrollDirection: Axis.horizontal, child: t);
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const StatusPill(this.text, this.color, {super.key, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
            Text(text, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  final Widget? trailing;
  const InfoRow(this.label, this.value, {super.key, this.mono = false, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 108,
              child: Text(label, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.outline)),
            ),
            Expanded(
              child: mono ? Mono(value) : SelectableText(value, style: const TextStyle(fontSize: 12.5)),
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
      ToolStatus.completed => const Color(0xFF3DDC84),
      ToolStatus.error => cs.error,
      ToolStatus.running => const Color(0xFFFFB020),
      ToolStatus.pending => cs.outline,
      ToolStatus.unknown => cs.outline,
    };
