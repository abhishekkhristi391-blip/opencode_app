// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Session list and per-session actions, todos and diff.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreSessions on OcStore {
  // =====================================================================
  // sessions
  // =====================================================================

  Future<void> refreshSessions() async {
    sessionsLoading = true;
    sessionsError = null;
    notifyListeners();
    try {
      final list = await api.sessions();
      sessions = list..sort((a, b) => b.updated.compareTo(a.updated));
      // Pinned chats float above the rest, still newest-first inside each
      // group. Re-sorted here rather than in the list widget so every consumer
      // of [sessions] agrees on the order.
      sessions.sort((a, b) {
        final pa = pinned.contains(a.id) ? 0 : 1;
        final pb = pinned.contains(b.id) ? 0 : 1;
        return pa != pb ? pa - pb : b.updated.compareTo(a.updated);
      });
      if (current != null) {
        final i = sessions.indexWhere((s) => s.id == current!.id);
        if (i >= 0) current = sessions[i];
      }
      _persistSessions(sessions);
    } on ApiException catch (e) {
      sessionsError = e.message;
      fatalError = e.message;
      // The server is unreachable. Without the cached session list the whole
      // history cache is unreachable too — there is nothing to tap open.
      await _restoreSessionsFromCache();
    } catch (e) {
      sessionsError = e.toString();
      await _restoreSessionsFromCache();
    } finally {
      sessionsLoading = false;
      notifyListeners();
    }
  }

  void _persistSessions(List<Session> list) {
    final rows = list
        .where((s) => s.id.isNotEmpty)
        .map((s) => {'id': s.id, 'raw': s.toMap(), 'updated': s.updated})
        .toList();
    if (rows.isEmpty) return;
    unawaited(ChatDB.instance.saveSessions(rows));
  }

  /// Falls back to the on-disk session list so cached chats stay reachable
  /// offline. Leaves an existing online list alone.
  Future<void> _restoreSessionsFromCache() async {
    if (sessions.isNotEmpty) return;
    try {
      final rows = await ChatDB.instance.loadSessions();
      if (rows.isEmpty) return;
      final list =
          rows
              .map((r) => Session.fromJson(r))
              .where((s) => s.id.isNotEmpty)
              .toList()
            ..sort((a, b) => b.updated.compareTo(a.updated));
      if (list.isEmpty) return;
      sessions = list;
      if (kDebugMode) debugPrint('restored ${list.length} sessions from cache');
    } catch (e) {
      if (kDebugMode) debugPrint('session cache read failed: $e');
    }
  }

  Future<Session?> newSession({String? title}) async {
    try {
      final s = await api.createSession(
        title: title,
        agent: agent,
        model: providerId.isEmpty
            ? null
            : {'providerID': providerId, 'id': modelId},
      );
      await refreshSessions();
      await openSession(s.id);
      return s;
    } on ApiException catch (e) {
      _toast(e.message);
      return null;
    }
  }

  Future<void> openSession(String id) async {
    // Land the previous session's last streamed chunk before moving on.
    await _flushHistory();
    // Invalidate any in-flight history loads for the old session.
    _historyLoadGen++;
    current =
        sessions.where((s) => s.id == id).firstOrNull ?? await _safeSession(id);
    messages = [];
    _clearLocalEcho();
    sessionError = null;
    liveDiff = [];
    todos = [];
    _oldestMessageId = null;
    hasMoreMessages = false;
    _limit = OcStore.pageLimit;
    messagesLoading = true;
    notifyListeners();
    try {
      // Paint cached history first so the chat is readable immediately, and
      // stays readable if the server never answers.
      final cached = await _cachedHistory(id);
      if (cached.isNotEmpty) {
        messages = cached;
        _oldestMessageId = cached.first.info.id;
        hasMoreMessages = true;
        notifyListeners();
      }
      final fetched = (await api.messages(id, limit: _limit))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      // Merge, don't replace: the server page is capped at [_limit], and
      // assigning it over `messages` used to drop all older history.
      messages = _mergeHistory(cached, fetched);
      _oldestMessageId = messages.isEmpty ? null : messages.first.info.id;
      // More to show if the merge kept older cached pages, or if the server
      // page came back full (so there is likely another page behind it).
      hasMoreMessages =
          messages.length > fetched.length || fetched.length >= _limit;
      _persistHistory(id, fetched);
      final st = asMap(await api.sessionStatus())[id];
      busy = st != null && asStr(asMap(st)['type']) == 'busy';
      busyStatus = busy ? asStr(asMap(st)['message'], 'busy') : '';
      if (busy) _startBusyTimer();
      unawaited(refreshTodos());
      unawaited(refreshDiff());
    } on ApiException catch (e) {
      sessionError = e.message;
    } catch (e) {
      // Anything else must not escape: the caller awaits this before pushing
      // the chat route, so a throw here left the user tapping a dead row, and
      // skipping the reset below left the list spinning forever.
      sessionError = e.toString();
      if (kDebugMode) debugPrint('openSession($id) failed: $e');
    }
    messagesLoading = false;
    notifyListeners();
  }

  Future<Session?> _safeSession(String id) async {
    try {
      return await api.session(id);
    } catch (e) {
      debugPrint('Failed to fetch session $id: $e');
      return null;
    }
  }

  /// Pins or unpins a chat. Local only: the server has no pinned concept, so the
/// id just lives in prefs and moves the chat to the top of the list.
Future<void> togglePin(String id) async {
  if (!pinned.remove(id)) pinned.add(id);
  notifyListeners();
  unawaited(_persist());
  await refreshSessions();
}

Future<void> renameSession(String id, String title) async {
    try {
      await api.renameSession(id, title);
      await refreshSessions();
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<bool> deleteSession(String id) async {
    try {
      await api.deleteSession(id);
      if (current?.id == id) {
        _historyLoadGen++;
        current = null;
        messages = [];
      }
      unawaited(ChatDB.instance.clearSession(id));
      unawaited(ChatDB.instance.deleteSessionRow(id));
      await refreshSessions();
      return true;
    } on ApiException catch (e) {
      _toast(e.message);
      return false;
    }
  }

  Future<Session?> forkSession(String id, {String? messageId}) async {
    try {
      final s = await api.fork(id, messageId: messageId);
      await refreshSessions();
      return s;
    } on ApiException catch (e) {
      _toast(e.message);
      return null;
    }
  }

  Future<void> shareSession(String id) async {
    try {
      await api.share(id);
      await refreshSessions();
      _toast(S.shareLinkCreated);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> unshareSession(String id) async {
    try {
      await api.unshare(id);
      await refreshSessions();
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> abortSession() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.abort(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
    _clearBusyTimer();
    busy = false;
    busyStatus = '';
    // Stop pressed: the aborted message never gets a completion stamp, so its
    // dots would keep spinning for the rest of the session.
    _settleStuckStreaming();
    notifyListeners();
  }

  // =====================================================================
  // todos / diff
  // =====================================================================

  /// Re-read the current session's todo list from the server.
  ///
  /// Single-flight: a request that arrives while a fetch is running is answered
  /// by exactly one more fetch when that one lands. The triggers are
  /// independent of each other — page open, session switch, resume, reconnect,
  /// the idle edge — and several of them routinely land in the same second, so
  /// they have to coalesce rather than queue up behind each other.
  Future<void> refreshTodos() async {
    final id = current?.id;
    if (id == null) return;
    if (_todosInFlight) {
      _todosQueued = true;
      return;
    }
    _todosInFlight = true;
    try {
      try {
        final list = await api.todos(id);
        // A session switch mid-await must not paint the previous chat's list.
        if (current?.id == id && !_disposed) {
          todos = list;
          _todosFetchedAt = DateTime.now();
        }
      } catch (e) {
        debugPrint('Failed to refresh todos: $e');
      }
    } finally {
      _todosInFlight = false;
      todoList.notify();
    }
    // Whatever asked while we were fetching was asking about the session that is
    // open *now* — which is not necessarily the one we just read — so it gets one
    // more fetch here rather than being silently dropped.
    if (_todosQueued && !_disposed) {
      _todosQueued = false;
      unawaited(refreshTodos());
    }
  }

  /// Apply a `todo.updated` payload. The event carries the whole list, so this
  /// is the live path: no HTTP round trip, and only the todos section rebuilds.
  ///
  /// Returns false when the payload is not the documented shape, so the caller
  /// can fall back to a refetch — a list that quietly stops moving is worse than
  /// a wasted request.
  bool _applyTodosPayload(Map<String, dynamic> p) {
    final raw = p['todos'];
    if (raw is! List) return false;
    final list = <Todo>[];
    for (final item in raw) {
      if (item is! Map) return false;
      final j = asMap(item);
      if (asStr(j['status']).isEmpty) return false;
      list.add(Todo.fromJson(j));
    }
    todos = list;
    _todosFetchedAt = DateTime.now();
    return true;
  }

  bool get todosStale {
    if (!busy) return false;
    final at = _todosFetchedAt;
    if (at == null) return true;
    return DateTime.now().difference(at) > OcStore._staleAfter;
  }

  /// Safe to call from anywhere, as often as a widget rebuilds: it does nothing
  /// unless the list is stale *and* an agent is running, and then at most once
  /// per stale window.
  void ensureTodosFresh() {
    if (_disposed || !todosStale) return;
    if (DateTime.now().difference(_todosLastFetch) < OcStore._staleAfter) return;
    _todosLastFetch = DateTime.now();
    unawaited(refreshTodos());
  }

  Future<void> refreshDiff() async {
    final id = current?.id;
    if (id == null) return;
    try {
      liveDiff = await api.diff(id);
    } catch (e) {
      debugPrint('Failed to refresh diff: $e');
    }
    notifyListeners();
  }
}
