// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Message / part / session upserts, toasts and connection lifecycle.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreMessages on OcStore {
  // FIX: with no open session, events from other sessions no longer leak into
  // the current message list.
  bool _isCurrent(String sid) =>
      current != null && (sid.isEmpty || current!.id == sid);

  ChatMessage? _messageById(String id) {
    // Newest messages are at the end, and streaming targets them: search backwards.
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].info.id == id) return messages[i];
    }
    return null;
  }

  int _optimisticIndex() {
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.info.raw['optimistic'] == true && m.info.role == 'user') return i;
    }
    return -1;
  }

  void _clearLocalEcho() {
    _echoForLocal = null;
    _echoInfo = null;
  }

  void _upsertMessage(Message info) {
    if (!_isCurrent(info.sessionId)) return;
    final existing = _messageById(info.id);
    final isRealUser = info.role == 'user' && info.raw['optimistic'] != true;

    if (existing != null) {
      existing.info = info;
      // Part events can arrive before the header; drop the stale local bubble.
      if (isRealUser) {
        final oi = _optimisticIndex();
        if (oi >= 0) messages.removeAt(oi);
      }
    } else if (isRealUser && _optimisticIndex() >= 0) {
      // Server echo of the optimistic user message. Replace it immediately
      // (user messages don't stream parts, so _upsertPart swap never fires).
      final oi = _optimisticIndex();
      if (oi >= 0) messages[oi] = ChatMessage(info, messages[oi].parts);
      _clearLocalEcho();
    } else {
      messages.add(ChatMessage(info, <Part>[]));
    }
    final m = _messageById(info.id);
    if (m != null && current != null) _scheduleFlush(current!.id, m);
    // Transcript-only: nothing outside the message list reads this.
    _scheduleMessageNotify();
  }

  void _upsertPart(Part part) {
    if (!_isCurrent(part.sessionId)) return;
    // The server has real content for the row we drew locally: adopt the real
    // id in place. Swapping here rather than on `message.updated` is what keeps
    // the sent text on screen for the whole hand-over.
    if (_echoForLocal != null && part.messageId == _echoForLocal) {
      final i = _optimisticIndex();
      final info = _echoInfo;
      _clearLocalEcho();
      if (i >= 0 && info != null) {
        final oldParts = messages[i].parts;
        messages[i] = ChatMessage(info, oldParts);
      }
    }
    var msg = _messageById(part.messageId);
    if (msg == null) {
      // The part arrived before its message header; synthesise a placeholder.
      // message.updated will fill in the real info (role etc.) right after.
      final info = Message(
        id: part.messageId,
        sessionId: part.sessionId,
        role: 'assistant',
        parentId: '',
        agent: agent,
        providerId: providerId,
        modelId: modelId,
        created: DateTime.now().millisecondsSinceEpoch,
        cost: 0,
        tokens: Tokens(0, 0, 0, 0, 0),
        finishReason: '',
        summaryText: '',
        summary: false,
        raw: const {},
      );
      msg = ChatMessage(info, <Part>[]);
      messages.add(msg);
    }
    final i = msg.parts.indexWhere((p) => p.id == part.id);
    if (i >= 0) {
      msg.parts[i] = part;
    } else {
      // A row adopted from the optimistic hand-over still carries the local
      // stand-in parts minted in [send]. Dedupe above is by id, so the server's
      // echo was *appended* rather than replacing them, and the bubble rendered
      // the user's text (and every attachment chip) twice. Retire the stand-in
      // this part supersedes — matched on content, not type alone, so sibling
      // attachments are left alone.
      if (!part.id.startsWith(OcStore._localPartPrefix)) {
        msg.parts.removeWhere(
          (p) =>
              p.id.startsWith(OcStore._localPartPrefix) &&
              p.type == part.type &&
              (part.type == 'file'
                  ? p.filename == part.filename
                  : p.text.trim() == part.text.trim()),
        );
      }
      msg.parts.add(part);
    }
    if (current != null) _scheduleFlush(current!.id, msg);
    if (msg.info.role == 'assistant') _buddyPart(part);
    _scheduleMessageNotify();
  }

  void _applyDelta(String partId, String field, String delta) {
    if (delta.isEmpty || partId.isEmpty) return;
    // Search newest message first: deltas always belong to the live message.
    for (var mi = messages.length - 1; mi >= 0; mi--) {
      final m = messages[mi];
      for (var i = m.parts.length - 1; i >= 0; i--) {
        if (m.parts[i].id != partId) continue;
        final raw = Map<String, dynamic>.from(m.parts[i].raw);
        raw[field] = '${asStr(raw[field])}$delta';
        m.parts[i] = Part.fromJson(raw);
        if (m.parts[i].type == 'reasoning') {
          _buddyCall('thinking', (b) => b.thinking());
        } else if (m.parts[i].type == 'text') {
          _buddyCall('writing', (b) => b.writing());
        }
        if (current != null) _scheduleFlush(current!.id, m);
        _scheduleMessageNotify(); // was notifyListeners() on every single token
        return;
      }
    }
  }

  void _removePart(String sid, String partId) {
    if (!_isCurrent(sid)) return;
    final affected = <ChatMessage>[];
    for (final m in messages) {
      final before = m.parts.length;
      m.parts.removeWhere((p) => p.id == partId);
      if (m.parts.length != before) affected.add(m);
    }
    // Re-mark only the affected messages so the dropped part is not
    // resurrected from the cache on the next open.
    if (current != null) {
      for (final m in affected) {
        _scheduleFlush(current!.id, m);
      }
    }
    _scheduleMessageNotify();
  }

  void _removeMessage(String sid, String messageId) {
    if (!_isCurrent(sid)) return;
    // The row still carries the local id, so a plain `removeWhere` missed it and
    // left a ghost bubble behind.
    if (messageId == _echoForLocal) {
      _clearLocalEcho();
      final i = _optimisticIndex();
      if (i >= 0) messages.removeAt(i);
    }
    messages.removeWhere((m) => m.info.id == messageId);
    if (current != null) {
      unawaited(ChatDB.instance.deleteMessage(current!.id, messageId));
    }
    _scheduleMessageNotify();
  }

  void _upsertSession(Session s) {
    final i = sessions.indexWhere((x) => x.id == s.id);
    if (i >= 0) {
      sessions[i] = s;
    } else {
      sessions.insert(0, s);
    }
    sessions.sort((a, b) => b.updated.compareTo(a.updated));
    if (current?.id == s.id) current = s;
    // Keep the on-disk session list current so the chat survives a cold start
    // with the server down.
    unawaited(ChatDB.instance.saveSession(s.id, s.toMap(), s.updated));
    // Stays global: the sessions list is a different view and must repaint.
    _scheduleNotify();
  }

  void _toast(String m) => _lastToast = m;
  String? takeToast() {
    final t = _lastToast;
    _lastToast = null;
    return t;
  }

  /// Call this on app resume to reconnect the SSE stream if needed.
  void reconnectStream() {
    if (_disposed) return;
    // `reconnect` now really does revive a paused stream. It used to bail out
    // on the `_stopped` flag that `pauseConnections` had set, so the very first
    // background/foreground cycle left the app permanently deaf: no events, no
    // streaming, red dot, and no retry loop because the timers were gone too.
    _stream?.reconnect();
  }

  void pauseConnections() {
    if (_disposed) return;
    try {
      // Reversible: the socket is released now, `reconnect` brings it back.
      unawaited(_stream?.stop());
    } catch (e) {
      debugPrint('Failed to pause connections: $e');
    }
    _clearBusyTimer();
    // Android can kill a backgrounded process without further notice; commit the
    // streamed tail now rather than relying on the debounce timer.
    unawaited(_flushHistory());
  }

  /// Foreground again. Android may have frozen the process for minutes, so the
  /// socket is assumed dead rather than trusted: reconnect at once (which also
  /// collapses the retry backoff) and re-verify the server, because a Termux
  /// restart means a new process, possibly a new version and a fresh session
  /// list.
  void resumeConnections() {
    if (_disposed) return;
    reconnectStream();
    unawaited(_verifyReachability(full: true));
    // Anything the frozen process missed is gone for good: the socket came back
    // with an empty backlog, so the todo list has to be asked for again.
    unawaited(refreshTodos());
  }
}
