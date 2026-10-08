// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Server-sent event handling.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreEvents on OcStore {
  // =====================================================================
  // event handling
  // =====================================================================

  void handleEvent(OcEvent e) {
    if (_disposed) return;
    _markAlive();
    // FIX: one malformed event must never kill the handler / stream.
    try {
      _handleEvent(e);
    } catch (err, st) {
      if (kDebugMode) debugPrint('handleEvent(${e.type}) failed: $err\n$st');
    }
  }

  /// The request id a reply/reject event refers to.
  ///
  /// opencode 1.18.27 sends `requestID` for permission and question events in
  /// both v1 and v2. Older builds used `permissionID`/`questionID`, so all
  /// three are tried; an event id (`evt_`) is never accepted as a fallback,
  /// because it can never match a request and silently matching nothing is
  /// exactly the failure that leaves a stale prompt on screen.
  String _repliedId(Map<String, dynamic> p) => asStr(
    p['requestID'],
    asStr(p['permissionID'], asStr(p['questionID'])),
  );

  /// A prompt event we could not make sense of. Log it and re-read the
  /// server's lists rather than dropping it: the event stream is the fast path,
  /// `GET /permission` + `GET /question` are the authority, and a prompt the UI
  /// cannot parse is precisely a prompt the user must still be shown.
  void _promptParseFailed(OcEvent e, String what) {
    debugPrint(
      'Prompt event unusable ($what): ${e.type} '
      'keys=${e.properties.keys.toList()}',
    );
    unawaited(resyncPrompts());
  }

  void _handleEvent(OcEvent e) {
    final p = e.properties;

    switch (e.type) {
      case 'message.updated':
        _touchActivity();
        _upsertMessage(Message.fromJson(asMap(p['info'])));
        break;
      case 'message.part.updated':
        _touchActivity();
        _upsertPart(Part.fromJson(asMap(p['part'])));
        break;
      case 'message.part.delta':
        _touchActivity();
        _applyDelta(asStr(p['partID']), asStr(p['field']), asStr(p['delta']));
        break;
      case 'message.part.removed':
        _removePart(asStr(p['sessionID']), asStr(p['partID']));
        break;
      case 'message.removed':
        _removeMessage(asStr(p['sessionID']), asStr(p['messageID']));
        break;
      case 'session.status':
        if (_isCurrent(asStr(p['sessionID']))) {
          final st = asMap(p['status']);
          final t = asStr(st['type']);
          final wasBusy = busy;
          busy = t == 'busy';
          busyStatus = busy ? asStr(st['message'], 'busy') : '';
          if (wasBusy && !busy) {
            _clearBusyTimer();
            _buddyDone();
            // The server declared the session idle, so a prompt typed during
            // the run is safe to release.
            unawaited(_flushQueue());
            // The agent writes its last todo update immediately before it
            // finishes, so this edge is the one time the list is worth re-reading
            // without waiting to be asked.
            unawaited(refreshTodos());
          }
          if (busy) _startBusyTimer();
          notifyListeners();
        }
        break;
      case 'session.idle':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          busy = false;
          busyStatus = '';
          messagesLoading = false;
          _buddyDone();
          notifyListeners();
          // The run is over: commit the tail now instead of waiting out the
          // flush debounce, so killing the app here still keeps the answer.
          unawaited(_flushHistory());
          unawaited(_flushQueue());
          if (!_disposed) {
            unawaited(refreshTodos());
            unawaited(refreshDiff());
            unawaited(refreshSessions());
          }
        }
        break;
      case 'session.error':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          final msg = _errorText(asMap(p['error']));
          sessionError = msg;
          busy = false;
          messagesLoading = false;
          // A failed run's message never gets a completion stamp either.
          _settleStuckStreaming();
          _buddyError(msg);
          notifyListeners();
          unawaited(_flushQueue());
        }
        break;
      case 'session.updated':
      case 'session.created':
        _upsertSession(Session.fromJson(asMap(p['info'])));
        break;
      case 'session.deleted':
        final info = p['info'];
        final delId = asStr(
          p['sessionID'],
          info != null ? asStr(asMap(info)['id']) : '',
        );
        sessions.removeWhere((s) => s.id == delId);
        if (current?.id == delId) {
          current = null;
          messages = [];
        }
        if (delId.isNotEmpty) {
          unawaited(ChatDB.instance.clearSession(delId));
          unawaited(ChatDB.instance.deleteSessionRow(delId));
        }
        notifyListeners();
        break;
      case 'session.diff':
        if (_isCurrent(asStr(p['sessionID']))) {
          liveDiff = asList(p['diff'])
              .map((e) => FileDiff.fromJson(asMap(e)))
              .toList();
          notifyListeners();
        }
        break;
      case 'permission.asked':
      case 'permission.updated':
      case 'permission.v2.asked':
        // `permission.updated` is an update of the request already on screen,
        // not a new one: replace it in place so a widened pattern list or a
        // changed command is what the user actually sees, and so it does not
        // take a second slot in the queue.
        final req = e.type == 'permission.v2.asked'
            ? PermissionReq.fromV2(asMap(p))
            : PermissionReq.fromJson(asMap(p));
        if (req.id.isEmpty) {
          // Never swallow a prompt we failed to understand: re-read the
          // server's own lists, which are authoritative.
          _promptParseFailed(e, 'permission asked');
          break;
        }
        // An id we already hold is the *same* request. `permission.updated`
        // therefore updates it in place — a widened pattern list or a changed
        // command is what the user then sees — and a replayed `asked` (a
        // reconnect can repeat one) refreshes it harmlessly. Neither may take a
        // second slot in the queue or reset its arrival position.
        final at = permissions.indexWhere((x) => x.id == req.id);
        if (at >= 0) {
          permissions[at] = req;
          notifyListeners();
          break;
        }
        permissions.add(req);
        _stampArrival([req.id]);
        _onPromptAdded();
        notifyListeners();
        break;
      case 'permission.replied':
      case 'permission.v2.replied':
        // opencode 1.18.27 names the field `requestID` in *both* v1 and v2
        // (EventPermissionReplied / EventPermissionV2Replied). The old lookup
        // read `permissionID`, fell through to the event's own `id` — an
        // `evt_` that never matches a `per_` — so a permission answered from
        // the TUI stayed on screen forever. All three spellings are accepted so
        // an older or newer server is not misread.
        final id = _repliedId(p);
        if (id.isEmpty) {
          _promptParseFailed(e, 'permission reply');
          break;
        }
        // Answered anywhere — here or in the TUI — drops it on the spot.
        permissions.removeWhere((x) => x.id == id);
        _forgetArrival([id]);
        _onPromptRemoved();
        notifyListeners();
        break;
      case 'question.asked':
      case 'question.v2.asked':
        final q = QuestionReq.fromJson(asMap(p));
        if (q.id.isEmpty) {
          _promptParseFailed(e, 'question');
          break;
        }
        if (!questions.any((x) => x.id == q.id)) {
          questions.add(q);
          _stampArrival([q.id]);
          _onPromptAdded();
          // Question tool pauses the agent — treat as idle for UI so prompt is usable.
          if (_isCurrent(q.sessionId)) {
            _clearBusyTimer();
            busy = false;
            busyStatus = '';
          }
          notifyListeners();
        }
        break;
      case 'question.replied':
      case 'question.rejected':
      case 'question.v2.replied':
      case 'question.v2.rejected':
        // `question.v2.rejected` exists on 1.18.27 and used to fall through to
        // no case at all, so a rejected v2 question was never cleared.
        // `requestID` is the field the server sends; see above.
        final qid = _repliedId(p);
        if (qid.isEmpty) {
          _promptParseFailed(e, 'question reply');
          break;
        }
        questions.removeWhere((x) => x.id == qid);
        _forgetArrival([qid]);
        _onPromptRemoved();
        notifyListeners();
        break;
      case 'todo.updated':
        // The event carries the whole list, so it is applied straight into the
        // store: the Tasks page and the badges move while the agent works,
        // without an HTTP call per update and without touching the transcript.
        if (!_isCurrent(asStr(p['sessionID']))) break;
        if (_applyTodosPayload(p)) {
          todoList.notify();
          break;
        }
        // Never swallow an event we could not read: the server's own endpoint
        // is the authority, so ask it rather than leaving the list frozen.
        debugPrint(
          'Todo event unusable: ${e.type} keys=${p.keys.toList()}',
        );
        _debouncedTodos();
        break;
      case 'server.connected':
        online = true;
        notifyListeners();
        break;
      // file.edited / lsp.updated / mcp.tools.changed / installation.updated:
      // no need to refetch todos for these any more.
    }
  }

  String _errorText(Map<String, dynamic> err) {
    final name = asStr(err['name']);
    final data = asMap(err['data']);
    final msg = asStr(data['message'], asStr(err['message']));
    return msg.isEmpty ? (name.isEmpty ? 'Unknown error' : name) : msg;
  }
}
