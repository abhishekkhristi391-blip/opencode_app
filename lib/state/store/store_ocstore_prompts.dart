// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Loading, resyncing and answering pending permission / question prompts.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStorePrompts on OcStore {
  // =====================================================================
  // permissions / questions
  // =====================================================================

  Future<void> loadPending() async {
    if (!online) return;
    try {
      final qlist = await api.pendingQuestions();
      questions = qlist
          .where((e) => asStr(e['id']).isNotEmpty)
          .map(QuestionReq.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Failed to load pending questions: $e');
    }
    try {
      final plist = await api.pendingPermissions();
      permissions = plist
          .where((e) => asStr(e['id']).isNotEmpty)
          .map((e) => PermissionReq.fromJson(asMap(e)))
          .where((p) => p.id.isNotEmpty)
          .toList();
      // A fetch failure must NOT empty the list: the requests we already hold
      // are still pending, and clearing them on a flaky link is exactly how a
      // prompt goes missing. The catch below leaves the old list in place.
    } catch (e) {
      debugPrint('Failed to load pending permissions: $e');
    }
    // Stamp before publishing, so the very first frame already has a queue
    // order. `putIfAbsent` keeps an id's original position across reconnects,
    // and dropping the stamps of ids the server no longer lists keeps the
    // counter from creeping upward across a long session.
    _stampArrival([
      for (final q in questions) q.id,
      for (final p in permissions) p.id,
    ]);
    final live = {for (final q in questions) q.id, for (final p in permissions) p.id};
    _arrival.removeWhere((id, _) => !live.contains(id));
    notifyListeners();
  }

  /// Re-fetch both pending lists. Called on connect, on every stream-up edge
  /// and on resume, because an event asked while the socket was down is gone
  /// for good and the server's own list is the only authority left.
  Future<void> resyncPrompts() async {
    // Single-flight. Connect, the reachability fallback, the stream-up edge and
    // a failed event parse can all land here within the same few hundred
    // milliseconds; running four overlapping fetches would interleave their
    // list assignments and let a slower, staler response overwrite a fresher
    // one. A caller that arrives mid-flight sets the flag instead of starting
    // a second run, and gets exactly one more pass when the first finishes.
    if (_promptSyncing) {
      _promptResyncAgain = true;
      return;
    }
    _promptSyncing = true;
    try {
      await _resyncPromptsOnce();
    } finally {
      _promptSyncing = false;
      if (_promptResyncAgain && !_disposed) {
        _promptResyncAgain = false;
        // Not awaited: this is the tail of the previous run and the caller is
        // already gone. Looping here guarantees a request that arrived during
        // the in-flight pass is still picked up.
        unawaited(resyncPrompts());
      } else {
        _promptResyncAgain = false;
      }
    }
  }

  Future<void> _resyncPromptsOnce() async {
    // Snapshot the ids we already knew: a request that is merely still pending
    // must not undo a dismissal, but a genuinely new one has to be shown.
    final known = <String>{
      for (final p in permissions) p.id,
      for (final q in questions) q.id,
    };
    await loadPending();
    if (_disposed) return;
    if (!awaitingPrompt) {
      promptSheetDismissed = false;
    } else {
      // A request we had never seen before has to be shown, however the sheet
      // was left. One that was already on screen when it was dismissed stays
      // dismissed, or every reconnect would reopen a card the user closed.
      final fresh = [
        ...permissions.where((e) => !known.contains(e.id)),
        ...questions.where((e) => !known.contains(e.id)),
      ];
      if (fresh.isNotEmpty) promptSheetDismissed = false;
    }
    notifyListeners();
  }

  Future<void> answerPermission(PermissionReq p, String response) async {
    permissions.removeWhere((e) => e.id == p.id);
    _forgetArrival([p.id]);
    _onPromptRemoved();
    notifyListeners();
    try {
      if (p.sessionId.isNotEmpty) {
        await api.replyPermission(p.sessionId, p.id, response);
      } else {
        await api.replyPermissionV1(p.id, response);
      }
    } on ApiException catch (e) {
      _toast(e.message);
      // The removal above was optimistic. If the reply never reached the server
      // the request is *still* pending, and leaving it deleted would hide a
      // prompt the agent is genuinely blocked on until something else happened
      // to trigger a resync. Re-read the server's list straight away.
      unawaited(resyncPrompts());
    }
  }

  Future<void> answerQuestion(QuestionReq q, List<List<String>> answers) async {
    questions.removeWhere((e) => e.id == q.id);
    _forgetArrival([q.id]);
    _onPromptRemoved();
    notifyListeners();
    try {
      await api.answerQuestion(q.id, answers);
    } on ApiException catch (e) {
      _toast(e.message);
      unawaited(resyncPrompts());
    }
  }

  Future<void> rejectQuestion(QuestionReq q) async {
    questions.removeWhere((e) => e.id == q.id);
    _forgetArrival([q.id]);
    _onPromptRemoved();
    notifyListeners();
    try {
      await api.rejectQuestion(q.id);
    } on ApiException catch (e) {
      _toast(e.message);
      unawaited(resyncPrompts());
    }
  }
}
