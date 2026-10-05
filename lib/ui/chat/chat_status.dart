part of '../chat.dart';

class _BusyBar extends StatelessWidget {
  final String status;
  const _BusyBar(this.status);

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: OCSpace.xs),
    child: OCProgressBar(value: 1, height: 6, animate: false),
  );
}

/// The one error surface in the transcript: a dismissible card on the failing
/// turn, which sits directly above the composer.
///
/// Red is reserved for a failure the user did not ask for. A stop the user
/// pressed is not a fault, so it is drawn in the muted line colour instead of
/// the error pair — the sentence is the same, the blame is not.
class _InlineError extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;
  const _InlineError(this.text, {required this.onDismiss});

  /// A cancellation the user asked for. The only way to stop a turn in this app
  /// is the composer's stop button, so the server's abort wording means "you
  /// did this", not "this went wrong".
  static bool _isCancellation(String text) {
    final lower = text.toLowerCase();
    return lower.contains('abort') || lower.contains('cancel');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final cancelled = _isCancellation(text);
    final fg = cancelled ? t.mute : t.err;
    final bg = cancelled ? t.card : t.errSoft;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: cancelled ? Border.all(color: t.line) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: LIcon(cancelled ? LI.info : LI.warning, size: 15, color: fg),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: OCTypography.caption.copyWith(color: fg),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // × , not a retry: retrying is a decision the user makes from the
          // message's own action row, and a close that silently re-ran the turn
          // would be a surprising thing to tap while clearing a message.
          LIconButton(
            icon: LI.close,
            size: 15,
            color: fg,
            padding: const EdgeInsets.all(8),
            semanticLabel: S.close,
            onTap: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Opacity(
                  opacity: 0.35 + 0.65 * ((c.value * 3 - i).clamp(0.0, 1.0)),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: t.acc,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// composer
// ---------------------------------------------------------------------
