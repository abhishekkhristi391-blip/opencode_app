part of '../chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// Owns the one and only scroll position of the transcript.
///
/// Everything about follow-the-tail lives here instead of being split across
/// the page and the list, which is what let two independent `_stick` flags
/// disagree before.
class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final focus = FocusNode();

  // ---- follow-the-tail state (TASK A) ----

  /// How close to the bottom still counts as "following". The reference
  /// tolerates a small gap so a token arriving a few pixels after the last
  /// scroll still keeps the tail in view.
  static const double _stickSlop = 80;

  /// How far past the slop the user has to be before the jump button appears.
  /// A little hysteresis keeps it from flickering around the threshold.
  static const double _jumpThreshold = 220;

  /// True while the user has not scrolled away from the tail.
  bool _follow = true;

  /// True while a finger is on the list. Auto-scroll must not touch the
  /// controller at all in this window, otherwise `jumpTo` calls `goIdle()`
  /// and yanks the drag out from under the user.
  bool _dragging = false;

  /// Set while [scroll] is being moved programmatically, so the scroll
  /// listener does not mistake our own jump for the user scrolling away.
  bool _programmatic = false;

  /// A post-frame auto-scroll is already queued. Guarantees at most one
  /// scroll adjustment per frame no matter how many tokens land in it.
  bool _scrollQueued = false;

  bool _showJump = false;

  /// New assistant messages that arrived while the user was scrolled away.
  int _unread = 0;
  int? _lastCount = 0;
  String _lastTailId = '';
  bool _wasLoading = false;

  /// Kept in a field so [dispose] can detach the listener. Looking it up through
  /// the context there is unsafe: the element is already defunct at that point
  /// (and `mounted` is false for a state being disposed), which trips the
  /// dependOnInheritedWidgetOfExactType assert and leaks the listener.
  OcStore? _store;

  /// The voice service is app-wide, so this only holds the subscription to its
  /// utterance stream. Held in a field, like [_store], because a stream
  /// subscription has to be cancelled somewhere safe.
  StreamSubscription<String>? _utterances;

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    // Listen to store changes for follow-the-tail logic (outside of build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _store = AppScope.read(context);
        _store!.addListener(_onStoreChange);
        // Streaming deltas now notify the transcript's own signal instead of the
        // store, so follow-mode has to hear from both or auto-scroll would stop
        // tracking the tail mid-run.
        _store!.messageList.addListener(_onStoreChange);
        // Dictated text arrives here and nowhere else: the service holds the
        // microphone, the page owns the caret.
        _utterances = VoiceScope.read(context).utterances.listen(
              _insertUtterance,
            );
      }
    });
  }

  @override
  void dispose() {
    scroll.removeListener(_onScroll);
    input.dispose();
    scroll.dispose();
    focus.dispose();
    // Remove store listener
    _store?.removeListener(_onStoreChange);
    _store?.messageList.removeListener(_onStoreChange);
    _store = null;
    unawaited(_utterances?.cancel());
    _utterances = null;
    super.dispose();
  }

  /// Put dictated text at the caret.
  ///
  /// Not at the end: somebody editing the second line of a prompt would have
  /// the text jump out from under their cursor mid-sentence. Not in a new field
  /// either - dictation is a keyboard, so it types.
  void _insertUtterance(String text) {
    if (!mounted) return;
    final current = input.text;
    final selection = input.selection;
    // An unselected field has offset -1, which would throw on replaceRange.
    final at = selection.isValid ? selection.start : current.length;
    final next = current.replaceRange(at, at, '$text ');
    input.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: at + text.length + 1),
    );
    focus.requestFocus();
    setState(() {});
  }

  void _onStoreChange() {
    if (!mounted) return;
    // Count the growth while detached, then decide what follow mode should do.
    final before = _lastCount;
    _syncFollow();
    if (_lastCount != null && _lastCount != before) {
      _bumpUnread();
      // The badge lives in the build below, so repaint only when it changed.
      if (_unread != 0) setState(() {});
    }
    _lastCount = _chatMessageCount();
  }

  int? _chatMessageCount() {
    final st = _store;
    if (st == null) return null;
    return st.messages.length;
  }

  double get _gap {
    if (!scroll.hasClients) return 0;
    return scroll.position.maxScrollExtent - scroll.position.pixels;
  }

  void _onScroll() {
    if (!scroll.hasClients) return;
    final show = _gap > _jumpThreshold;
    // Reaching the bottom is the only thing that clears the badge, so it can
    // never disagree with what the user can actually see.
    if (!show) _unread = 0;
    if (show != _showJump || !show) {
      if (mounted) setState(() => _showJump = show);
    }
  }

  /// Counts a message that arrived off-screen. Called from the store listener.
  void _bumpUnread() {
    if (!_showJump || !mounted) return;
    _unread++;
  }

  /// Distinguishes a drag from a fling/keyboard/programmatic scroll.
  ///
  /// Returns true when the notification came from a real pointer.
  bool _handleNotification(ScrollNotification n) {
    if (_programmatic) return false;
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _dragging = true;
      // Grabbing the list always releases follow mode; the user is taking
      // over. They can re-arm it by scrolling back or tapping the button.
      if (_follow) _setFollow(false);
    } else if (n is ScrollUpdateNotification && n.dragDetails != null) {
      _dragging = true;
      // Dragging back down toward the tail re-arms auto-scroll once the gap
      // closes, so a small overscroll snaps to following again.
      final gap = n.metrics.maxScrollExtent - n.metrics.pixels;
      if (gap <= _stickSlop && !_follow) _setFollow(true);
    } else if (n is ScrollEndNotification && n.dragDetails != null) {
      _dragging = false;
    } else if (n is UserScrollNotification && n.depth == 0) {
      // Flings and keyboard-driven scrolls carry no dragDetails. Treat them
      // as intent too, so scrolling up with a trackpad also detaches.
      if (n.direction == ScrollDirection.reverse) _setFollow(false);
    }
    return false;
  }

  void _setFollow(bool v) {
    if (_follow == v) return;
    _follow = v;
    if (!v && mounted) {
      final show = _gap > _jumpThreshold;
      if (show != _showJump) setState(() => _showJump = show);
    }
  }

  /// Coalesces every pending auto-scroll into a single post-frame callback.
  void _queueAutoScroll() {
    if (!_follow || _scrollQueued) return;
    _scrollQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollQueued = false;
      _runAutoScroll();
    });
  }

  /// Moves the list to the tail, at most once, and never with an animation.
  ///
  /// `jumpTo` rather than `animateTo` is deliberate: an animation started per
  /// token stacks up into a fight with the user's finger, and it keeps
  /// dispatching scroll updates long after the turn is over.
  void _runAutoScroll() {
    if (!mounted || !_follow || _dragging || !scroll.hasClients) return;
    final pos = scroll.position;
    if (!pos.hasContentDimensions || pos.maxScrollExtent <= 0) return;
    if ((pos.maxScrollExtent - pos.pixels).abs() < 0.5) return;
    _programmatic = true;
    pos.jumpTo(pos.maxScrollExtent);
    _programmatic = false;
  }

  /// Jump button: resume following and glide to the newest message.
  void _jumpToLatest() {
    _setFollow(true);
    _showJump = false;
    _unread = 0;
    if (!scroll.hasClients) return;
    _programmatic = true;
    scroll
        .animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() => _programmatic = false);
    // Re-run once the layout settles in case the tail grew while animating.
    _queueAutoScroll();
  }

  /// Prepending older messages changes every offset above the viewport, so
  /// restore by measuring the extent delta instead of guessing a constant.
  Future<void> _loadOlderMessages(OcStore store) async {
    if (!store.hasMoreMessages || store.messagesLoading) return;
    if (!scroll.hasClients) return;
    final beforeExtent = scroll.position.maxScrollExtent;
    final beforePixels = scroll.position.pixels;

    await store.loadOlderMessages();
    if (!mounted || !scroll.hasClients) return;
    // Wait for the new rows to be laid out before measuring again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scroll.hasClients || _dragging) return;
      final grew = scroll.position.maxScrollExtent - beforeExtent;
      if (grew <= 0) return;
      _programmatic = true;
      scroll.jumpTo(beforePixels + grew);
      _programmatic = false;
    });
  }

  /// Runs after every store notification: decides whether the tail should
  /// move. Never called per token — [OcStore] already coalesces notifications
  /// to ~16/s, and [_queueAutoScroll] collapses whatever is left to one jump
  /// per frame.
  void _syncFollow() {
    // The listener is detached in dispose, but a notification already in flight
    // can still land there; read the cached store instead of doing an inherited
    // widget lookup (which is not legal outside build) on every token.
    final store = _store;
    if (store == null) return;
    final messages = store.messages;
    final count = messages.length;
    final tailId = messages.isEmpty ? '' : messages.last.info.id;

    // A fresh user message always re-arms follow: the user just spoke.
    // Keyed on the tail *id*, not the count: prepending an older page also
    // raises the count, and that used to yank the reader back to the bottom
    // mid-history whenever the last message happened to be theirs.
    if (tailId.isNotEmpty &&
        tailId != _lastTailId &&
        messages.last.info.isUser) {
      _setFollow(true);
    }
    _lastTailId = tailId;

    final justLoaded = _wasLoading && !store.messagesLoading;
    _wasLoading = store.messagesLoading;
    // Only re-arm follow on load completion if we were already following,
    // or if this is the initial load (messages was empty). Prevents jumping
    // to bottom after "load older" when user is scrolled up reading history.
    if (justLoaded && (_follow || _lastCount == 0)) {
      _setFollow(true);
    }
    _lastCount = count;

    _queueAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    // No ListenableBuilder on purpose. Every child below subscribes to exactly
    // what it needs — the bars and the composer to the store, the transcript to
    // [OcStore.messageListenable] — so this Column is static and stays out of
    // the rebuild path entirely.
    return Column(
      children: [
        // No session error bar here on purpose: the failing turn already carries
        // [_InlineError] directly above the composer, and a second copy of the
        // same sentence pinned to the top of the screen was the duplicate the
        // user kept seeing.
        // 2dp accent hairline pinned under the header. The old busy bar was a
        // full-width strip with text, which pushed the transcript down and
        // scrolled out of view during exactly the runs that needed watching.
        const _RunProgressLine(),
        const _BusyBarWidget(),
        Expanded(
          child: _ChatMessages(
            scroll: scroll,
            showJump: _showJump,
            unread: _unread,
            onNotification: _handleNotification,
            onJump: _jumpToLatest,
            onLoadOlder: _loadOlderMessages,
            onPickSuggestion: _sendSuggestion,
          ),
        ),
        _ComposerWidget(
          controller: input,
          focus: focus,
          onSend: _send,
        ),
      ],
    );
  }

  /// Suggestion cards send straight away. Dropping the text into the field
  /// first made the composer grow and the keyboard pop, so the user lost
  /// their place.
  Future<void> _sendSuggestion(String text) async {
    if (input.text.trim().isNotEmpty) {
      await _send();
      return;
    }
    input.text = text;
    await _send();
  }

  Future<void> _send() async {
    final store = AppScope.read(context);
    final text = input.text;
    if (text.trim().isEmpty && store.attachments.isEmpty) return;

    final trimmed = text.trim();
    if (trimmed.startsWith('/')) {
      final sp = trimmed.indexOf(' ');
      final cmd = (sp < 0 ? trimmed : trimmed.substring(0, sp)).substring(1);
      final args = sp < 0 ? '' : trimmed.substring(sp + 1);
      final match = store.commands.where((c) => c.name == cmd).firstOrNull;
      if (match != null) {
        input.clear();
        focus.requestFocus();
        await store.runCommand(cmd, args);
        return;
      }
    }

    if (store.providerId.isEmpty || store.modelId.isEmpty) {
      if (mounted) showSnack(context, S.modelMissing, error: true);
      return;
    }

    input.clear();
    focus.requestFocus();

    try {
      // Queues when a run is in flight, so a prompt typed mid-run is not lost.
      await store.sendOrQueue(text);
    } catch (e) {
      input.text = text;
      input.selection = TextSelection.collapsed(offset: text.length);
      if (mounted) showSnack(context, '$e', error: true);
    }
    if (mounted) setState(() {});
  }
}
