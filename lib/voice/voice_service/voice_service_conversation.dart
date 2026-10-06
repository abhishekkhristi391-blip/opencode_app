// ignore_for_file: invalid_use_of_protected_member
part of '../voice_service.dart';

/// Hands-free conversation: committing utterances, the reply loop and re-listening.
///
/// Moved out of [VoiceService] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [VoiceService]; the only edit is that references to its statics read `VoiceService.name`.
extension VoiceServiceConversation on VoiceService {
  Future<void> _finishUtterance(String text) async {
    if (_phase != VoicePhase.listening) return;
    _partial = text;
    _go(VoicePhase.processing);
    await _stopRecognizer();
    final spoken = text.trim();
    _partial = '';
    _level = 0;
    if (spoken.isEmpty) {
      _onEmptyUtterance();
      return;
    }
    await _commitUtterance(spoken);
  }

  /// Hand one finished utterance to whoever is waiting for it: the composer in
  /// plain dictation, the store in hands-free mode.
  Future<void> _commitUtterance(String text) async {
    if (_conversation && _autoSend) {
      await _sendAndWait(text);
      return;
    }
    if (!_utterances.isClosed) _utterances.add(text);
    if (_conversation) {
      // Hands-free without auto-send: the words are in the field and the loop
      // cannot continue, because the send is now the user's to make.
      _fail(VoiceFailure.autoSendOff);
      return;
    }
    _go(VoicePhase.idle);
  }

  Future<void> _sendAndWait(String text) async {
    if (!_store.online) {
      _fail(VoiceFailure.network);
      return;
    }
    if (_store.providerId.isEmpty || _store.modelId.isEmpty) {
      // The store would raise its own "pick a model first" toast from inside a
      // hands-free loop nobody is watching, so it is said here instead.
      _fail(VoiceFailure.noModel);
      return;
    }
    try {
      // The composer's own path, unchanged: one prompt in flight, mid-run
      // prompts queued in order, optimistic echo handled by the store.
      await _store.sendOrQueue(text);
    } catch (e) {
      debugPrint('VoiceService: send failed: $e');
      _fail(VoiceFailure.unknown);
      return;
    }
    _awaitingReply = true;
    _emptyResults = 0;
    _lastActivity = DateTime.now();
    _go(VoicePhase.waiting);
    // If the run already ended - a rejected prompt, a server that answered
    // instantly - the reply is picked up here instead of on the next change.
    _onStore();
  }

  void _onEmptyUtterance() {
    _partial = '';
    _level = 0;
    _emptyResults++;
    if (_conversation) {
      if (_emptyResults >= VoiceService._emptyLimit) {
        _notice = VoiceFailure.noSpeech;
        _forget(endConversation());
        return;
      }
      _forget(_relisten());
      return;
    }
    _go(VoicePhase.idle);
  }

  /// Hands-free, on or off.
  Future<void> toggleConversation() async {
    if (_conversation) {
      await endConversation();
      return;
    }
    await startConversation();
  }

  Future<void> startConversation() async {
    if (_suspended) return;
    if (!_autoSend) {
      // Refused rather than half-started: a hands-free loop that cannot send is
      // just an open microphone.
      _notice = VoiceFailure.autoSendOff;
      notifyListeners();
      return;
    }
    clearNotice();
    _conversation = true;
    _emptyResults = 0;
    _blockedByOverlay =
        _store.permissions.isNotEmpty || _store.questions.isNotEmpty;
    notifyListeners();
    if (_blockedByOverlay) return;
    await _resumeLoop();
  }

  /// End hands-free. Whatever was in the microphone is committed first, so a
  /// tap never loses a sentence.
  Future<void> endConversation() async {
    _conversation = false;
    _awaitingReply = false;
    _waitingForLink = false;
    _relistenTimer?.cancel();
    final heard = _partial.trim();
    final commitHeard = _heard && heard.isNotEmpty;
    _forget(_stopRecognizer(discard: !commitHeard));
    _forget(_stopSpeaking(silent: true));
    if (commitHeard) {
      // Hands-free with words half-heard puts them in the field. Dropping them
      // is the one thing a stop button must never do.
      await _finishUtterance(heard);
      return;
    }
    _partial = '';
    _level = 0;
    _go(VoicePhase.idle);
    notifyListeners();
  }

  void _onSessionChanged() {
    // A different session is a different conversation: whatever was pending
    // belonged to the old one and is dropped rather than spoken into the new.
    _awaitingReply = false;
    _lastHandledId = null;
    _emptyResults = 0;
    _waitingForLink = false;
    _forget(_stopRecognizer(discard: true));
    _forget(_stopSpeaking(silent: true));
    if (_conversation) {
      _forget(_resumeLoop());
      return;
    }
    if (_phase == VoicePhase.listening) _go(VoicePhase.idle);
  }

  /// Speak the newest finished assistant reply, once.
  void _handleTail() {
    // A run has to have been seen going before its reply counts as new. Opening
    // the app onto a restored session with read-aloud on would otherwise start
    // talking about the last thing that was said, unasked, at launch.
    if (!_sawRun) return;
    final tail = _lastAssistantMessage();
    if (tail == null) return;
    final id = tail.info.id;
    if (id == _lastHandledId) return;
    if (tail.streaming) {
      // The run ended but the message has not settled. Nothing to do; the next
      // change will say so.
      return;
    }
    _lastHandledId = id;
    _awaitingReply = false;
    _partial = '';
    _level = 0;
    final text = VoiceService._messageText(tail);
    if (text.trim().isEmpty) {
      if (_conversation) _forget(_relisten());
      return;
    }
    // Read it whether or not hands-free asked for it: `_readAloud` is the
    // user's standing instruction, and a hands-free turn needs to hear this
    // reply in order to answer it.
    _forget(speak(text));
  }

  /// The tail message, if it is an assistant one.
  ChatMessage? _lastAssistantMessage() {
    final messages = _store.messages;
    if (messages.isEmpty) return null;
    final last = messages.last;
    if (last.info.isUser) return null;
    return last;
  }

  void _checkInactivity() {
    if (DateTime.now().difference(_lastActivity) < VoiceService._idleLimit) return;
    _notice = VoiceFailure.noSpeech;
    _forget(endConversation());
  }

  Future<void> _resumeLoop() async {
    if (!_conversation || _suspended) return;
    if (_blockedByOverlay) return;
    if (!_store.online) {
      // Nothing to send a prompt to. The store listener wakes the loop when the
      // link comes back.
      _waitingForLink = true;
      return;
    }
    _waitingForLink = false;
    await _relisten();
  }

  /// Back to the microphone, once the synthesiser has fallen quiet.
  Future<void> _relisten() async {
    if (!_conversation || _suspended) return;
    if (_blockedByOverlay || _waitingForLink) return;
    // Not while a reply is still coming: the microphone would transcribe the
    // agent's own tools asking questions.
    if (_phase == VoicePhase.waiting) return;

    _relistenTimer?.cancel();
    final gate = Completer<void>();
    _relistenTimer = Timer(VoiceService._echoGuard, gate.complete);
    await gate.future;
    _relistenTimer = null;

    if (!_conversation || _suspended) return;
    if (_store.permissions.isNotEmpty || _store.questions.isNotEmpty) {
      _blockedByOverlay = true;
      return;
    }
    if (!_store.online) {
      _waitingForLink = true;
      return;
    }
    await _beginListen();
  }
}
