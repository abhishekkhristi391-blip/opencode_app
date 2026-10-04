import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'line_icons.dart';
import 'markdown.dart';
import 'models_page.dart';
import 'parts.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

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
  int _lastCount = 0;
  String _lastTailId = '';
  bool _wasLoading = false;

  /// Kept in a field so [dispose] can detach the listener. Looking it up through
  /// the context there is unsafe: the element is already defunct at that point
  /// (and `mounted` is false for a state being disposed), which trips the
  /// dependOnInheritedWidgetOfExactType assert and leaks the listener.
  OcStore? _store;

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
    super.dispose();
  }

  void _onStoreChange() {
    if (!mounted) return;
    _syncFollow();
  }

  double get _gap {
    if (!scroll.hasClients) return 0;
    return scroll.position.maxScrollExtent - scroll.position.pixels;
  }

  void _onScroll() {
    if (!scroll.hasClients) return;
    final show = _gap > _jumpThreshold;
    if (show != _showJump && mounted) setState(() => _showJump = show);
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
    if (tailId.isNotEmpty && tailId != _lastTailId && messages.last.info.isUser) {
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
        const _ErrorBarWidget(),
        const _BusyBarWidget(),
        Expanded(
          child: _ChatMessages(
            scroll: scroll,
            showJump: _showJump,
            onNotification: _handleNotification,
            onJump: _jumpToLatest,
            onLoadOlder: _loadOlderMessages,
            onPickSuggestion: _sendSuggestion,
          ),
        ),
        _ComposerWidget(controller: input, focus: focus, onSend: _send),
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
      await store.send(text);
    } catch (e) {
      input.text = text;
      input.selection = TextSelection.collapsed(offset: text.length);
      if (mounted) showSnack(context, '$e', error: true);
    }
    if (mounted) setState(() {});
  }
}

/// Rebuilds only when sessionError changes
class _ErrorBarWidget extends StatelessWidget {
  const _ErrorBarWidget();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        if (store.sessionError == null) return const SizedBox.shrink();
        return _ErrorBar(
          store.sessionError!,
          () => store.openSession(store.current!.id),
        );
      },
    );
  }
}

/// Rebuilds only when busy/busyStatus changes
class _BusyBarWidget extends StatelessWidget {
  const _BusyBarWidget();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        if (!store.busy) return const SizedBox.shrink();
        return _BusyBar(store.busyStatus);
      },
    );
  }
}

/// The transcript.
///
/// There is exactly one scrollable here and the parent owns its controller, so
/// follow-mode, the jump button and the loader cannot disagree. Anything that
/// needs to scroll (suggestion lists, sheets) lives in the composer or in a
/// modal route, never in the message list.
class _ChatMessages extends StatelessWidget {
  final ScrollController scroll;
  final bool showJump;
  final bool Function(ScrollNotification) onNotification;
  final VoidCallback onJump;
  final Future<void> Function(OcStore) onLoadOlder;
  final void Function(String) onPickSuggestion;

  const _ChatMessages({
    required this.scroll,
    required this.showJump,
    required this.onNotification,
    required this.onJump,
    required this.onLoadOlder,
    required this.onPickSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    // Bound to the transcript's own signal, not to the whole store: a token now
    // repaints this list and nothing else in the app. `messageListenable` also
    // carries the app-wide notifications that change this list's own chrome
    // (loading state, `hasMoreMessages`, `showTokensInChat`), so a session
    // switch or a settings toggle still lands here.
    return ListenableBuilder(
      listenable: store.messageListenable,
      builder: (context, _) => _buildList(context, store),
    );
  }

  Widget _buildList(BuildContext context, OcStore store) {
    final messages = store.messages;

    if (store.messagesLoading && messages.isEmpty) {
      return const LoadingView(label: S.chatLoading);
    }
    if (messages.isEmpty) {
      return _Welcome(store, onPick: onPickSuggestion);
    }

    // The footer belongs to the last assistant reply only; older ones keep
    // their tokens hidden behind the store flag like everything else.
    var lastAssistantIndex = -1;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (!messages[i].info.isUser) {
        lastAssistantIndex = i;
        break;
      }
    }

    final hasOlder = store.hasMoreMessages;
    final leading = hasOlder ? 1 : 0;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: onNotification,
          child: ListView.builder(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            itemCount: messages.length + leading,
            cacheExtent: 600,
            itemBuilder: (_, i) {
              if (hasOlder && i == 0) {
                return _LoadOlderButton(
                  onTap: () => onLoadOlder(store),
                  loading: store.messagesLoading,
                );
              }
              final index = i - leading;
              final m = messages[index];
              return _MessageTile(
                key: ValueKey(m.info.id),
                msg: m,
                isLastReply: index == lastAssistantIndex,
                showTokens: store.showTokensInChat,
              );
            },
          ),
        ),
        if (showJump)
          Positioned(
            right: 18,
            bottom: 14,
            child: _JumpToLatest(onTap: onJump),
          ),
      ],
    );
  }
}

/// Floating pill that appears once the reader scrolls away from the tail.
class _JumpToLatest extends StatelessWidget {
  final VoidCallback onTap;
  const _JumpToLatest({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      label: S.jumpToLatest,
      child: Material(
        color: t.card,
        borderRadius: BorderRadius.circular(999),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: t.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LIcon(LI.arrowDown, size: 16, color: t.mute, strokeWidth: 2.2),
                const SizedBox(width: 6),
                Text(
                  S.jumpToLatest,
                  style: OCTypography.micro.copyWith(
                    color: t.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------

class _LoadOlderButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const _LoadOlderButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OCSpace.sm),
      child: Center(
        child: loading
            ? const OCProgressRing(value: 0.65, size: 22, stroke: 3)
            : OCButton(
                onPressed: onTap,
                icon: Icons.keyboard_arrow_up,
                label: S.chatLoadOlder,
                variant: OCButtonVariant.secondaryPill,
                expand: false,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------

class _ErrorBar extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorBar(this.msg, this.onRetry);

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      width: double.infinity,
      color: t.errSoft,
      padding: const EdgeInsets.fromLTRB(18, 8, 4, 8),
      child: Row(
        children: [
          LIcon(LI.warning, size: 17, color: t.err),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: OCTypography.caption.copyWith(color: t.err),
            ),
          ),
          LIconButton(
            icon: LI.close,
            size: 17,
            color: t.err,
            padding: const EdgeInsets.all(6),
            semanticLabel: S.delete,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}

class _BusyBar extends StatelessWidget {
  final String status;
  const _BusyBar(this.status);

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: OCSpace.xs),
    child: OCProgressBar(value: 1, height: 6, animate: false),
  );
}

/// Reference `.empty`: a big question, a muted line, then four bordered cards
/// with a title and a subtitle. Tapping one sends it immediately.
class _Welcome extends StatelessWidget {
  final OcStore store;
  final void Function(String) onPick;
  const _Welcome(this.store, {required this.onPick});

  static const _suggestions = <(String, String)>[
    (S.chatSuggestionStructure, S.chatSuggestionStructureSub),
    (S.chatSuggestionTests, S.chatSuggestionTestsSub),
    (S.chatSuggestionTodo, S.chatSuggestionTodoSub),
    (S.chatSuggestionPlan, S.chatSuggestionPlanSub),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return ListView(
      // The parent wraps the body in a SafeArea, so only inset the top.
      padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
      children: [
        Text(
          S.chatWelcomeTitle,
          style: OCTypography.h1.copyWith(
            color: t.ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          store.modelId.isEmpty
              ? S.chatWelcomeEmptySubtitle
              : S.chatWelcomeSubtitle(
                  '${store.providerId}/${store.modelId}',
                  store.agent,
                ),
          style: OCTypography.body.copyWith(color: t.mute),
        ),
        const SizedBox(height: 22),
        for (final (title, sub) in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionCard(
              title: title,
              subtitle: sub,
              onTap: () => onPick(title),
            ),
          ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SuggestionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OCTypography.body.copyWith(
                  color: t.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: OCTypography.body.copyWith(color: t.mute)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// message bubble
// ---------------------------------------------------------------------

class _MessageTile extends StatefulWidget {
  final ChatMessage msg;
  final bool isLastReply;
  final bool showTokens;
  const _MessageTile({
    super.key,
    required this.msg,
    required this.isLastReply,
    required this.showTokens,
  });

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile> {
  // FIX: every store update used to re-parse the markdown of EVERY message.
  // Now a tile only rebuilds when its own message actually changed.
  Widget? _cache;
  int _sig = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cache = null; // theme / screen size changed
  }

  int _signature() {
    final m = widget.msg;
    return Object.hash(
      identityHashCode(m.info),
      m.parts.length,
      Object.hashAll(m.parts.map(identityHashCode)),
      m.errorText,
      widget.isLastReply,
      widget.showTokens,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sig = _signature();
    if (_cache == null || sig != _sig) {
      _sig = sig;
      _cache = RepaintBoundary(child: _buildContent(context));
    }
    return _cache!;
  }

  Future<void> _openMenu() async {
    await showMessageMenu(context, widget.msg);
  }

  Widget _buildContent(BuildContext context) {
    final t = context.oc;
    final m = widget.msg;
    final user = m.info.isUser;

    final text = m.parts
        .where((p) => p.type == 'text')
        .map((p) => p.text)
        .join('\n')
        .trim();
    final files = m.parts.where((p) => p.type == 'file').toList();
    final others = m.parts
        .where(
          (p) =>
              p.type != 'text' &&
              p.type != 'file' &&
              p.type != 'step-start' &&
              p.type != 'step-finish',
        )
        .toList();

    // OcStore._upsertMessage swaps an optimistic user message for the
    // server's echo with an *empty* part list, then fills in the parts when
    // their events land. Rendering the bubble during that window is what put
    // a stray empty black pill in the transcript, so a row with nothing to
    // show collapses to nothing.
    final hasContent =
        text.isNotEmpty ||
        files.isNotEmpty ||
        others.isNotEmpty ||
        m.errorText != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        // Long press is the only entry point to fork / delete, which is what
        // lets the inline row shrink to the two actions the reference shows.
        onLongPress: _openMenu,
        borderRadius: BorderRadius.circular(12),
        child: user
            ? _userBubble(context, t, text, files, hasContent)
            : _assistantBlock(context, t, text, others, m, hasContent),
      ),
    );
  }

  Widget _userBubble(
    BuildContext context,
    OCTokens t,
    String text,
    List<Part> files,
    bool hasContent,
  ) {
    if (!hasContent) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: t.ink,
            // Reference: 20px radii with a 6px tail on the bottom right.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final f in files) _IncomingFileChip(f),
              if (text.isNotEmpty)
                Markdown(
                  text,
                  base: OCTypography.body.copyWith(color: t.bg, height: 1.45),
                  onLink: (url) => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assistantBlock(
    BuildContext context,
    OCTokens t,
    String text,
    List<Part> others,
    ChatMessage m,
    bool hasContent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (others.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ToolTimeline(parts: others),
          ),
        if (text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Markdown(
              text,
              base: OCTypography.body.copyWith(color: t.ink, height: 1.45),
              onLink: (url) => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        if (m.streaming && !hasContent) const _TypingDots(),
        if (m.displayError != null) _InlineError(m.displayError!),
        if (m.displayError == null && !m.streaming && m.info.tokens.total > 0)
          _ReplyMeta(msg: m, visible: widget.showTokens),
        // Only the newest reply carries the inline actions; older ones reach
        // the same operations through the long-press menu.
        if (widget.isLastReply && m.displayError == null) _ReplyActions(msg: m),
      ],
    );
  }
}

/// Token / cost line under a finished reply. Hidden unless the settings toggle
/// is on, and reduced to the bare counts when it is.
class _ReplyMeta extends StatelessWidget {
  final ChatMessage msg;
  final bool visible;
  const _ReplyMeta({required this.msg, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final t = context.oc;
    final i = msg.info;
    final bits = <String>[
      if (i.tokens.total > 0) i.tokens.pretty,
      if (i.cost > 0) '\$${i.cost.toStringAsFixed(4)}',
    ];
    if (bits.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        bits.join(' · '),
        style: OCTypography.micro.copyWith(color: t.mute),
      ),
    );
  }
}

/// Copy + Undo, shown only under the final AI reply (reference `.actions`).
class _ReplyActions extends StatelessWidget {
  final ChatMessage msg;
  const _ReplyActions({required this.msg});

  @override
  Widget build(BuildContext context) {
    // read(), not of(): these buttons don't need to rebuild on every update.
    final store = AppScope.read(context);

    return Padding(
      padding: const EdgeInsets.only(left: -8, top: 2),
      child: Row(
        children: [
          _ActionBtn(
            icon: LI.copy,
            label: S.copy,
            onTap: () {
              final text = msg.parts
                  .where((p) => p.type == 'text')
                  .map((p) => p.text)
                  .join('\n');
              copyToClipboard(context, text);
            },
          ),
          _ActionBtn(
            icon: LI.undo,
            label: S.messageUndo,
            onTap: () => store.revert(msg.info.id),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LIcon(icon, size: 16, color: t.mute),
              const SizedBox(width: 5),
              Text(
                label,
                style: OCTypography.micro.copyWith(color: t.mute, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Long-press menu: Copy, Fork, Undo, Delete.
///
/// Fork and Delete leave the inline row entirely, so they live here. Copy and
/// Undo are deliberately duplicated from the last reply's inline row: a long
/// press is the only way to reach them on an older message.
Future<void> showMessageMenu(BuildContext context, ChatMessage msg) async {
  final store = AppScope.read(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetRow(
            icon: LI.copy,
            label: S.copy,
            onTap: () {
              Navigator.pop(sheetCtx);
              final text = msg.parts
                  .where((p) => p.type == 'text')
                  .map((p) => p.text)
                  .join('\n');
              copyToClipboard(context, text);
            },
          ),
          _SheetRow(
            icon: LI.fork,
            label: S.messageForkHere,
            onTap: () async {
              Navigator.pop(sheetCtx);
              final s = await store.forkSession(
                store.current!.id,
                messageId: msg.info.id,
              );
              if (s != null && context.mounted) {
                await store.openSession(s.id);
                if (context.mounted) showSnack(context, S.messageForked);
              }
            },
          ),
          if (!msg.info.isUser)
            _SheetRow(
              icon: LI.undo,
              label: S.messageUndo,
              onTap: () {
                Navigator.pop(sheetCtx);
                store.revert(msg.info.id);
              },
            ),
          _SheetRow(
            icon: LI.trash,
            label: S.delete,
            danger: true,
            onTap: () async {
              Navigator.pop(sheetCtx);
              final ok = await confirmDialog(
                context,
                title: S.messageDeleteTitle,
                message: S.messageDeleteBody,
                confirm: S.delete,
                danger: true,
              );
              if (!ok) return;
              try {
                await store.api.deleteMessage(store.current!.id, msg.info.id);
                await store.openSession(store.current!.id);
              } catch (e) {
                if (context.mounted) showSnack(context, '$e', error: true);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// One row in a bottom sheet, styled like the reference `.opt` line.
class _SheetRow extends StatelessWidget {
  final LI icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final color = danger ? t.err : t.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
        child: Row(
          children: [
            LIcon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: OCTypography.body.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingFileChip extends StatelessWidget {
  final Part part;
  const _IncomingFileChip(this.part);

  @override
  Widget build(BuildContext context) {
    // Sits inside the dark user bubble, so it inherits the bubble's contrast
    // rather than a fixed light-only colour.
    final t = context.oc;
    final onBubble = t.ink;
    final isImg = part.mime.startsWith('image/');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LIcon(isImg ? LI.terminal : LI.attach, size: 15, color: onBubble),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              part.filename.isEmpty ? baseName(part.url) : part.filename,
              style: OCTypography.caption.copyWith(color: onBubble),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  const _InlineError(this.text);

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.errSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: LIcon(LI.warning, size: 15, color: t.err),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: OCTypography.caption.copyWith(color: t.err),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
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

/// Rebuilds only when attachments/busy/modelId/agent/toolsEnabled changes
class _ComposerWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;

  const _ComposerWidget({
    required this.controller,
    required this.focus,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppScope.of(context),
      builder: (context, _) {
        final store = AppScope.of(context);
        return _Composer(
          store: store,
          controller: controller,
          focus: focus,
          onSend: onSend,
          onStop: store.abortSession,
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final OcStore store;
  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSend;
  final VoidCallback onStop;
  const _Composer({
    required this.store,
    required this.controller,
    required this.focus,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Container(
      // Reference `.composer`: 6px 12px 10px around a single 24px-radius box.
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.line),
          boxShadow: [
            BoxShadow(color: t.line, offset: const Offset(0, 1), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (store.attachments.isNotEmpty) _AttachmentStrip(store),
            // One field, then one tools row — the reference stacks the two
            // inside a single container instead of using separate bars.
            SlashTextField(
              controller: controller,
              focusNode: focus,
              store: store,
              onSubmit: onSend,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                LIconButton(
                  icon: LI.attach,
                  size: 22,
                  color: t.mute,
                  semanticLabel: S.composerAttachTooltip,
                  onTap: () => _showAttachSheet(context),
                ),
                const SizedBox(width: 2),
                _ModelPill(store: store),
                const Spacer(),
                _SendButton(
                  store: store,
                  controller: controller,
                  onSend: onSend,
                  onStop: onStop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttachSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetRow(
              icon: LI.attach,
              label: S.attachImage,
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(context);
              },
            ),
            _SheetRow(
              icon: LI.folder,
              label: S.attachFile,
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickProjectFile(context);
              },
            ),
            _SheetRow(
              icon: LI.terminal,
              label: S.attachSlash,
              onTap: () {
                Navigator.pop(sheetCtx);
                _showCommands(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final b64 = base64Encode(bytes);
    store.addAttachment(
      PendingAttachment(
        path: x.path,
        mime: x.mimeType ?? 'image/jpeg',
        name: x.name,
        size: bytes.length,
        dataUrl: 'data:${x.mimeType ?? 'image/jpeg'};base64,$b64',
      ),
    );
  }

  Future<void> _pickProjectFile(BuildContext context) async {
    final picked = await showModalBottomSheet<FileNode>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _FilePickerSheet(),
    );
    if (picked == null) return;
    try {
      final content = await store.api.readFile(picked.path);
      store.addAttachment(
        PendingAttachment(
          path: picked.path,
          mime: _mimeFor(picked.name),
          name: picked.name,
          size: content.length,
          dataUrl:
              'data:${_mimeFor(picked.name)};base64,${base64Encode(utf8.encode(content))}',
        ),
      );
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
    }
  }

  static String _mimeFor(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => 'text/x-dart',
      'py' => 'text/x-python',
      'js' || 'mjs' => 'text/javascript',
      'ts' => 'text/typescript',
      'json' => 'application/json',
      'md' => 'text/markdown',
      'yaml' || 'yml' => 'text/yaml',
      'sh' => 'text/x-sh',
      _ => 'text/plain',
    };
  }

  Future<void> _showCommands(BuildContext context) async {
    final builtins = const ['init', 'compact', 'undo', 'redo', 'share'];
    final names = {...store.commands.map((c) => c.name), ...builtins}.toList()
      ..sort();
    // Tappable: picking a command inserts it, which keeps the existing
    // insert-into-the-field behaviour instead of silently doing nothing.
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                S.pickerCommandsTitle,
                style: OCTypography.bodyStrong.copyWith(color: context.oc.mute),
              ),
            ),
            for (final n in names)
              ListTile(
                dense: true,
                leading: LIcon(LI.terminal, size: 18, color: context.oc.mute),
                title: Text(
                  S.slashCommand(n),
                  style: OCTypography.mono(size: 13),
                ),
                onTap: () => Navigator.pop(context, n),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      final t = controller.text;
      controller.text = t.isEmpty ? '/$picked ' : '$t /$picked ';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }
}

class _AttachmentStrip extends StatelessWidget {
  final OcStore store;
  const _AttachmentStrip(this.store);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        itemCount: store.attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final a = store.attachments[i];
          return InputChip(
            avatar: Icon(
              a.mime.startsWith('image/')
                  ? Icons.image_outlined
                  : Icons.description_outlined,
              size: 17,
            ),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                '${a.name} · ${fmtBytes(a.size)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            backgroundColor: cs.surfaceContainerHighest,
            onDeleted: () => store.removeAttachment(i),
          );
        },
      ),
    );
  }
}

/// Reference `.pill`: one accent-tinted chip reading `model · agent` that
/// opens the model / agent / tools sheet. This replaces the old three-chip
/// quick bar; there is no separate tools chip or dropdown anymore.
class _ModelPill extends StatelessWidget {
  final OcStore store;
  const _ModelPill({required this.store});

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final label = store.modelId.isEmpty
        ? S.chipPickModel
        : S.composerModelAgent(store.modelId, store.agent);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Material(
        color: t.accSoft,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () => showModelSheet(context, store),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LIcon(LI.tune, size: 15, color: t.accInk, strokeWidth: 2),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OCTypography.body.copyWith(
                      color: t.accInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Model / agent / tools, as the reference `.sheet` panel.
Future<void> showModelSheet(BuildContext context, OcStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetOption(
            label: S.moreModel,
            value: store.modelId.isEmpty ? S.chipPickModel : store.modelId,
            onTap: () async {
              Navigator.pop(sheetCtx);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelsPage()),
              );
            },
          ),
          _SheetOption(
            label: S.moreAgent,
            value: store.agent,
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickAgentSheet(context, store);
            },
          ),
          _SheetOption(
            label: S.moreTools,
            value: S.moreToolsCount(store.toolsEnabled.length),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickToolsSheet(context, store);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// `.opt` line: label on the left, muted value plus chevron on the right.
class _SheetOption extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SheetOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Text(label, style: OCTypography.body.copyWith(color: t.ink)),
            const Spacer(),
            Text(value, style: OCTypography.body.copyWith(color: t.mute)),
            const SizedBox(width: 8),
            LIcon(LI.chevronRight, size: 16, color: t.mute),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAgentSheet(BuildContext context, OcStore store) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => RadioGroup<String>(
      groupValue: store.agent,
      onChanged: (v) {
        if (v != null) store.setAgent(v);
        Navigator.pop(sheetCtx);
      },
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                S.moreAgent,
                style: OCTypography.bodyStrong.copyWith(color: context.oc.mute),
              ),
            ),
            for (final a in store.agents)
              RadioListTile<String>(
                value: a.name,
                dense: true,
                title: Text(a.name, style: OCTypography.body),
                subtitle: a.description.isEmpty
                    ? null
                    : Text(
                        a.description,
                        maxLines: 2,
                        style: OCTypography.micro,
                      ),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickToolsSheet(BuildContext context, OcStore store) async {
  List<String> ids;
  try {
    ids = await store.api.toolIds();
  } catch (e) {
    if (context.mounted) showSnack(context, '$e', error: true);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (c, setSheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(S.moreTools, style: OCTypography.bodyStrong),
                  ),
                  TextButton(
                    onPressed: () {
                      store.toolsEnabled.clear();
                      setSheet(() {});
                    },
                    child: Text(S.toolsEnableAll),
                  ),
                ],
              ),
            ),
            Text(
              S.toolsSheetHint,
              style: OCTypography.micro.copyWith(color: context.oc.mute),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final id in ids)
                    CheckboxListTile(
                      dense: true,
                      value: store.toolsEnabled.contains(id),
                      title: Text(id, style: OCTypography.mono(size: 12.5)),
                      onChanged: (v) {
                        store.toggleTool(id, v ?? false);
                        setSheet(() {});
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Reference `.send`: a 40px circle that is Stop while the agent runs, an
/// up-arrow while there is something to send, and the voice glyph otherwise.
class _SendButton extends StatelessWidget {
  final OcStore store;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStop;
  const _SendButton({
    required this.store,
    required this.controller,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (store.busy) {
          return _CircleButton(
            icon: LI.stop,
            bg: t.ink,
            fg: t.bg,
            semanticLabel: S.chatStopTooltip,
            onTap: onStop,
          );
        }
        final canSend =
            value.text.trim().isNotEmpty || store.attachments.isNotEmpty;
        if (canSend) {
          return _CircleButton(
            icon: LI.send,
            bg: t.acc,
            fg: const Color(0xFFFFFFFF),
            semanticLabel: S.chatSendTooltip,
            onTap: onSend,
          );
        }
        // Voice chat lands in a later prompt; keep the affordance visible so
        // the composer reads the same as the reference.
        return _CircleButton(
          icon: LI.mic,
          bg: t.card,
          fg: t.ink,
          semanticLabel: S.composerVoiceTooltip,
          onTap: () => showSnack(context, S.composerVoiceTooltip),
          border: t.line,
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final LI icon;
  final Color bg;
  final Color fg;
  final String semanticLabel;
  final VoidCallback onTap;
  final Color? border;
  const _CircleButton({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.semanticLabel,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: border == null
                ? null
                : BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border!),
                  ),
            child: Center(child: LIcon(icon, size: 20, color: fg)),
          ),
        ),
      ),
    );
  }
}

/// TextField with inline autocomplete for `/commands` and `@files`.
class SlashTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final OcStore store;
  final VoidCallback onSubmit;
  const SlashTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.store,
    required this.onSubmit,
  });

  @override
  State<SlashTextField> createState() => _SlashTextFieldState();
}

class _SlashTextFieldState extends State<SlashTextField> {
  List<String> _suggestions = [];
  String _mode = '';
  List<String> _files = [];
  late final VoidCallback _focusListener;
  Timer? _fileSearchTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusListener = () {
      if (widget.focusNode.hasFocus) _onChanged();
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.focusNode.removeListener(_focusListener);
    _fileSearchTimer?.cancel();
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid || !sel.isCollapsed) return _set([]);

    final upto = text.substring(0, sel.baseOffset);
    final slash = RegExp(r'(?:^|\s)/([\w-]*)$').firstMatch(upto);
    if (slash != null) {
      final q = slash.group(1)!.toLowerCase();
      final names = widget.store.commands.map((c) => c.name).toSet()
        ..addAll(const ['init', 'compact', 'undo', 'redo', 'share', 'clear']);
      return _set(
        names.where((n) => n.startsWith(q)).take(8).toList(),
        mode: '/',
      );
    }
    final at = RegExp(r'(?:^|\s)@([\w./-]*)$').firstMatch(upto);
    if (at != null) {
      final q = at.group(1)!.toLowerCase();
      _mode = '@';
      _debouncedSearchFiles(q);
      return;
    }
    _set([]);
  }

  void _debouncedSearchFiles(String q) {
    _fileSearchTimer?.cancel();
    _fileSearchTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _searchFiles(q);
    });
  }

  void _searchFiles(String q) async {
try {
        final list = await widget.store.api.findFiles(
          q.isEmpty ? ' ' : q,
          limit: 8,
        );
        if (!mounted || _mode != '@') return;
        setState(() => _files = list);
      } catch (e) {
        debugPrint('File search failed: $e');
      }
    }

  void _set(List<String> s, {String mode = ''}) {
    if (!mounted) return;
    if (s.length == _suggestions.length &&
        mode == _mode &&
        s.join() == _suggestions.join())
      return;
    setState(() {
      _suggestions = s;
      _mode = mode;
    });
  }

  void _apply(String token) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid) return;
    final upto = text.substring(0, sel.baseOffset);
    final pattern = _mode == '@'
        ? RegExp(r'(?:^|\s)@[\w./-]*$')
        : RegExp(r'(?:^|\s)/[\w-]*$');
    final m = pattern.firstMatch(upto);
    if (m == null) return;
    final start = sel.baseOffset - m.group(0)!.length;
    final prefix = _mode == '@' ? '' : (m.group(0)!.startsWith(' ') ? '' : '');
    final insert = '$_mode$token ';
    final next = text.replaceRange(start, sel.baseOffset, '$prefix$insert');
    widget.controller.text = next;
    widget.controller.selection = TextSelection.collapsed(
      offset: start + insert.length,
    );
    _set([]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final showList =
        _suggestions.isNotEmpty || (_mode == '@' && _files.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          minLines: 1,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          onSubmitted: (_) => widget.onSubmit(),
          style: OCTypography.body.copyWith(color: t.ink, height: 1.4),
          decoration: InputDecoration(
            hintText: S.chatPlaceholder,
            hintStyle: OCTypography.body.copyWith(color: t.mute),
            // Borderless: the enclosing composer container already draws the
            // 24px rounded box and its focus ring.
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        // Rendered above the tools row rather than below it, so accepting a
        // completion never resizes the composer's bottom edge.
        if (showList)
          Container(
            constraints: const BoxConstraints(maxHeight: 190),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final s in _suggestions)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: LIcon(LI.terminal, size: 15, color: t.mute),
                    title: Text(
                      s,
                      style: OCTypography.caption.copyWith(color: t.ink),
                    ),
                    subtitle: widget.store.commands
                        .where((c) => c.name == s)
                        .map(
                          (c) => Text(
                            c.description,
                            style: OCTypography.micro.copyWith(color: t.mute),
                          ),
                        )
                        .firstOrNull,
                    onTap: () => _apply(s),
                  ),
                for (final f in _files)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: LIcon(LI.folder, size: 15, color: t.mute),
                    title: Text(
                      baseName(f),
                      style: OCTypography.caption.copyWith(color: t.ink),
                    ),
                    subtitle: Text(
                      f,
                      style: OCTypography.micro.copyWith(color: t.mute),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _apply(f),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FilePickerSheet extends StatefulWidget {
  const _FilePickerSheet();

  @override
  State<_FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends State<_FilePickerSheet> {
  String dir = '.';
  List<FileNode> nodes = [];
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? d]) async {
    setState(() {
      loading = true;
      err = null;
      if (d != null) dir = d;
    });
    try {
      final list = await AppScope.read(context).api.files(dir);
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        return a.name.compareTo(b.name);
      });
      if (!mounted) return;
      setState(() {
        nodes = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        err = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(
              children: [
                if (dir != '.')
                  IconButton(
                    iconSize: 19,
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => _load(dir == '.' ? '.' : dirName(dir)),
                  ),
                Expanded(
                  child: Mono(dir == '.' ? S.filesProjectRoot : dir, size: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const LoadingView()
                : err != null
                ? EmptyHint(
                    icon: Icons.error_outline,
                    title: S.filesLoadFailed,
                    message: err!,
                  )
                : nodes.isEmpty
                ? const EmptyHint(
                    icon: Icons.folder_off_outlined,
                    title: S.empty,
                    message: S.filesEmptyBody,
                  )
                : ListView.builder(
                    itemCount: nodes.length,
                    itemBuilder: (_, i) {
                      final n = nodes[i];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          n.isDir ? Icons.folder_outlined : _iconFor(n.name),
                          size: 19,
                          color: n.isDir
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(
                          n.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () =>
                            n.isDir ? _load(n.path) : Navigator.pop(context, n),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (e) {
      'dart' => Icons.code,
      'js' || 'ts' || 'jsx' || 'tsx' => Icons.javascript,
      'py' => Icons.code,
      'json' => Icons.data_object,
      'md' => Icons.article_outlined,
      'yaml' || 'yml' => Icons.settings_input_component,
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => Icons.image_outlined,
      'sh' => Icons.terminal,
      'lock' => Icons.lock_outline,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}
