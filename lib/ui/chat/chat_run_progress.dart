part of '../chat.dart';

/// The strip under the composer: "Codex is working…" while a run is in
/// flight, with a slow-run hint and a tap target that interrupts.
///
/// The busy bar used to sit *above* the transcript, so it scrolled away exactly
/// when a long run most needed an escape hatch.
///
/// It is also the one honest report of *why* the agent is quiet. A pending
/// permission or question means the run cannot advance at all until the user
/// acts, which is a different situation from "thinking" — so the spinner is
/// replaced by a static glyph, the slow warning is suppressed (a request that
/// sits for a minute has not become slower, it has become blocked), and a chip
/// opens the sheet that answers it.
class _WorkingStrip extends StatefulWidget {
  final String agent;
  final VoidCallback onStop;
  const _WorkingStrip({required this.agent, required this.onStop});

  @override
  State<_WorkingStrip> createState() => _WorkingStripState();
}

class _WorkingStripState extends State<_WorkingStrip> {
  static const _slowAfter = Duration(seconds: 8);
  Timer? _timer;
  bool _slow = false;

  /// Which prompt the strip was last showing, so clearing a block restarts the
  /// slow timer exactly once. The run genuinely begins again the moment the
  /// block clears, and the old countdown belonged to the wait, not the work.
  String? _blockedOn;

  /// Guards against queueing several post-frame callbacks if the store notifies
  /// repeatedly before the frame ends.
  bool _resyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _armSlowTimer();
  }

  /// Restart the eight-second countdown. Passing `blocked` cancels it outright:
  /// while a request is out there is no thinking to report on.
  void _armSlowTimer({bool blocked = false}) {
    _timer?.cancel();
    _timer = null;
    if (blocked) return;
    _timer = Timer(_slowAfter, () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final t = context.oc;
    final n = store.pendingPromptCount;
    // The same queue the sheet opens, so the strip can never describe a
    // different request than the one a tap will show.
    final next = store.oldestPendingPrompt;
    final perm = next?.permission;
    final blocked = n > 0;

    // Transition detection, not state mutation: the slow warning is only ever
    // about *thinking*, and while a prompt is out the run is not slow, it is
    // stopped. Going blocked, or clearing a block, restarts the countdown so
    // the eight seconds measure the work rather than the wait.
    final blockId = blocked ? (next?.id ?? '') : null;
    if (_blockedOn != blockId && !_resyncScheduled) {
      _resyncScheduled = true;
      // Derived state, so it is committed after the frame rather than during
      // it: build must stay free of timer side effects.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resyncScheduled = false;
        if (!mounted || _blockedOn == blockId) return;
        setState(() {
          _blockedOn = blockId;
          _slow = false;
        });
        _armSlowTimer(blocked: blocked);
      });
    }
    // One stale frame of “still slow” right after a block clears is
    // preferable to a rebuild loop; the callback above clears it immediately.
    final showSlow = _slow && !blocked;

    final String headline = blocked
        ? (next?.isPermission == true ? S.waitingApproval : S.waitingAnswer)
        : S.composerWorking(widget.agent);

    final String status = blocked
        ? (n > 1 ? S.waitingYou(n) : S.promptTapToReview)
        : (showSlow ? S.composerWorkingSlow : S.composerStopHint);

    // Tool or path, so the tap target says what is actually being approved
    // rather than just "something".
    final String? subtitle = perm != null ? perm.subject : null;

    return Padding(
      padding: const EdgeInsets.only(top: OCSpace.xs),
      child: Semantics(
        button: true,
        label: blocked ? '$headline. $status' : status,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // Blocked: the useful action is answering, not interrupting. The
            // stop target is still reachable from the composer's own control.
            onTap: blocked ? () => showPendingPrompt(context) : widget.onStop,
            borderRadius: BorderRadius.circular(OCRadius.pill),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OCSpace.sm,
                  vertical: OCSpace.xs,
                ),
                child: Row(
                  children: [
                    if (blocked)
                      Icon(
                        Icons.pause_rounded,
                        size: 16,
                        color: t.acc,
                      )
                    else
                      OCProgressRing(
                        value: 0.7,
                        size: 12,
                        stroke: 1.6,
                        color: t.acc,
                      ),
                    const SizedBox(width: OCSpace.sm),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.caption.copyWith(
                              color: blocked ? t.ink : t.mute,
                              fontWeight: blocked
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          Text(
                            subtitle ?? status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OCTypography.micro.copyWith(
                              color: blocked
                                  ? t.acc
                                  : (showSlow ? t.warn : t.mute),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (blocked) ...[
                      const SizedBox(width: OCSpace.xs),
                      _PromptChip(
                        label: next?.isPermission == true
                            ? S.promptReview
                            : S.promptAnswer,
                        onTap: () => showPendingPrompt(context),
                      ),
                    ],
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

/// The Review / Answer chip on the working strip. Separate from the strip's own
/// tap so the affordance that answers is findable without knowing that tapping
/// the background works too.
class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: t.accSoft,
        borderRadius: BorderRadius.circular(OCRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OCRadius.pill),
          child: Container(
            // 48dp tall, not 32: the whole point of the chip is that it is the
            // obvious thing to press, and a 32dp target is not pressable by
            // anyone with a normal thumb.
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: OCSpace.md),
            alignment: Alignment.center,
            child: Text(
              label,
              style: OCTypography.micro.copyWith(
                color: t.acc,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Prompts held while a run is in flight, with a one-tap release.
class _QueuedStrip extends StatelessWidget {
  final OcStore store;
  const _QueuedStrip({required this.store});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Padding(
      padding: const EdgeInsets.only(top: OCSpace.xs),
      child: Row(
        children: [
          LIcon(LI.history, size: 12, color: t.mute),
          const SizedBox(width: OCSpace.sm),
          Expanded(
            child: Text(
              S.composerQueued(store.queued.length),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OCTypography.caption.copyWith(color: t.mute),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether a model id/name advertises itself as free.
///
/// There is no cost field on the server's model list, so this is a label
/// heuristic and nothing more: it never claims a price, only surfaces a "free"
/// tier when the provider says so in the name. Anything uncertain stays
/// unbadged rather than being wrong.
bool isFreeModel(String id) {
  final s = id.toLowerCase();
  return s.contains(':free') ||
      s.contains('-free') ||
      s.endsWith(' free') ||
      s.startsWith('free/') ||
      s.contains('/free');
}

/// 2dp accent hairline that animates while a run is in flight.
///
/// It sits between the header and the transcript instead of taking a strip of
/// vertical space, so following the tail is not interrupted by its own progress
/// indicator.
class _RunProgressLine extends StatelessWidget {
  const _RunProgressLine();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final t = context.oc;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.busy) return const SizedBox(height: 2);
        return Semantics(
          label: S.composerWorking(store.agent),
          liveRegion: true,
          child: SizedBox(
            height: 2,
            width: double.infinity,
            child: _IndeterminateBar(color: t.acc),
          ),
        );
      },
    );
  }
}

/// Left-to-right sweep on an infinite-ish loop. Skipped entirely when the user
/// has asked for reduced motion.
class _IndeterminateBar extends StatefulWidget {
  final Color color;
  const _IndeterminateBar({required this.color});

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: OCMotion.progress,
  );

  @override
  void initState() {
    super.initState();
    if (!ocReduceMotion(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) => CustomPaint(
      painter: _BarPainter(_c.value, widget.color),
      size: Size.infinite,
    ),
  );
}

class _BarPainter extends CustomPainter {
  final double t;
  final Color color;
  _BarPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: 0.14),
    );
    final w = size.width * 0.32;
    final x = (size.width + w) * t - w;
    canvas.drawRect(
      Rect.fromLTWH(x, 0, w, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.t != t || old.color != color;
}
