// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Notification debouncing and the on-disk chat-history cache.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreCache on OcStore {
  /// Coalesces streaming deltas into at most ~16 rebuilds/sec, but paints the
  /// *first* change of a burst straight away.
  ///
  /// The old version always waited a full window before the first rebuild, so
  /// the opening token of every reply appeared late; worse, any change that
  /// landed while a timer was pending was dropped without a trailing rebuild,
  /// so the final token of a turn could sit unrendered for good.
  void _scheduleNotify() {
    if (_disposed) return;
    _notifyPending = true;
    if (_notifyTimer != null) return;
    _notifyPending = false;
    notifyListeners();
    _notifyTimer = Timer(const Duration(milliseconds: 60), () {
      _notifyTimer = null;
      // Guarantees the last change of a burst always gets painted.
      if (_notifyPending) _scheduleNotify();
    });
  }

  /// Same throttle, but scoped to [messageList] so a token never rebuilds the
  /// rest of the app.
  void _scheduleMessageNotify() {
    if (_disposed) return;
    _msgNotifyPending = true;
    if (_msgNotifyTimer != null) return;
    _msgNotifyPending = false;
    messageList.notify();
    _msgNotifyTimer = Timer(const Duration(milliseconds: 60), () {
      _msgNotifyTimer = null;
      if (_msgNotifyPending) _scheduleMessageNotify();
    });
  }

  /// Keeps a burst of todo updates from turning into a burst of HTTP calls.
  ///
  /// Only used on the *fallback* path, where the event payload could not be
  /// read: a server that sends a shape we do not understand can send it in a
  /// tight loop, and one refetch per malformed event would be a request storm.
  /// The live path never needs this — a readable `todo.updated` carries the
  /// whole list and is applied without any network at all.
  void _debouncedTodos() {
    if (_disposed) return;
    _todoTimer?.cancel();
    _todoTimer = Timer(const Duration(milliseconds: 400), () {
      _todoTimer = null;
      if (!_disposed) unawaited(refreshTodos());
    });
  }

  // =====================================================================
  // local history cache
  // =====================================================================

  /// Row shape stored by [ChatDB]. Built from the models' raw server JSON so a
  /// reload round-trips through [Message.fromJson] without a lossy mapping.
  Map<String, dynamic> _dbRow(ChatMessage m) => {
    'info': m.info.toMap(),
    'parts': m.parts.map((p) => p.toMap()).toList(),
  };

  /// Messages that must not be written to disk: the local echo of a user
  /// message the server has not confirmed yet, and the blank placeholder
  /// synthesised when a part arrives before its header. Both get a real row
  /// moments later when the server echoes them back, so persisting them now
  /// only risks resurrecting an empty bubble.
  /// Also excludes assistant messages that are still streaming (no finishReason).
  bool _isCacheable(ChatMessage m) {
    if (m.info.id.isEmpty) return false;
    if (m.info.raw['optimistic'] == true) return false;
    if (m.info.raw.isEmpty) return false;
    // Don't cache assistant messages that haven't finished yet (no finishReason).
    if (m.info.role == 'assistant' && m.info.finishReason.isEmpty) return false;
    return true;
  }

  /// Combines already-loaded history with the newest [window] from the server.
  ///
  /// The server only returns the most recent page, so assigning it straight
  /// over `messages` discarded everything older. Cached messages that sit
  /// before that page are kept; messages inside it are replaced by the
  /// server's copy, which is authoritative.
  List<ChatMessage> _mergeHistory(
    List<ChatMessage> existing,
    List<ChatMessage> window,
  ) {
    if (window.isEmpty) return existing;
    final ids = {for (final m in window) m.info.id};
    final newest = window.last.info.created;
    final older = <ChatMessage>[];
    if (newest > 0) {
      for (final m in existing) {
        if (ids.contains(m.info.id)) continue;
        if (m.info.created > 0 && m.info.created < newest) older.add(m);
      }
    }
    final merged = [...older, ...window];
    OcStore._stripEchoedOptimistic(merged, window);
    return merged;
  }

  /// Reads a session's history out of the cache. Returns an empty list rather
  /// than throwing: a broken cache must never block opening a session.
  Future<List<ChatMessage>> _cachedHistory(String id) async {
    try {
      final rows = await ChatDB.instance.loadMessages(id);
      return rows
          .map(
            (r) => ChatMessage(
              Message.fromJson(asMap(r['info'])),
              asList(r['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
            ),
          )
          .where((m) => !m.info.summary)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('history cache read failed: $e');
      return const [];
    }
  }

  void _scheduleFlush(String sessionId, ChatMessage m) {
    if (!_isCacheable(m)) return;
    // Snapshots are keyed by session, so switching chats has to push out the
    // pending rows first or they would be written under the new session id.
    if (_flushSession != null && _flushSession != sessionId) {
      unawaited(_flushHistory());
    }
    _flushSession = sessionId;
    _dirty[m.info.id] = _dbRow(m);
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 400), () {
      if (!_disposed) unawaited(_flushHistory());
    });
  }

  /// Writes the pending snapshots now. Called before switching sessions and
  /// when a run goes idle, so the tail of a conversation is never left
  /// unwritten. Rows are read synchronously, before [ChatDB]'s queue turn.
  Future<void> _flushHistory() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    final sid = _flushSession;
    final rows = _dirty.values.toList();
    _flushSession = null;
    _dirty.clear();
    if (sid == null || rows.isEmpty) return;
    try {
      await ChatDB.instance.upsertMessages(sid, rows);
    } catch (e) {
      if (kDebugMode) debugPrint('history cache write failed: $e');
    }
  }

  /// Persists a full page of server messages (open / paginate / resync).
  void _persistHistory(String sessionId, List<ChatMessage> list) {
    final rows = list.where(_isCacheable).map(_dbRow).toList();
    if (rows.isEmpty) return;
    unawaited(ChatDB.instance.upsertMessages(sessionId, rows));
  }
}
