// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Derived getters, the token toggle and the prompt-sheet bookkeeping.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreViewState on OcStore {
  /// Tasks still to come: not finished, and not dropped by the agent. Both
  /// badges count this, so the number on the button is the number of rows the
  /// list is still waiting on.
  int get openTodos => todos.where((t) => !t.done && !t.cancelled).length;

  void setShowTokensInChat(bool v) {
    if (showTokensInChat == v) return;
    showTokensInChat = v;
    unawaited(_persist());
    notifyListeners();
  }

  /// Single source of truth for "is the agent blocked on a human". Every prompt
  /// surface — the header badge, the working strip, the overlay — reads this,
  /// so they cannot disagree about how many requests are waiting.
  int get pendingPromptCount => permissions.length + questions.length;

  /// Arrival order, permissions and questions interleaved.
  ///
  /// The two lists above are per-endpoint and would each be "oldest first" on
  /// their own; sorting them together by arrival is what makes the queue fair.
  /// `_arrival` is stamped once per id and preserved across resyncs, so this
  /// ordering cannot be reset by a reconnect.
  List<PendingPrompt> get pendingPrompts {
    // Stamped here rather than only at the mutation sites: a request that
    // reached the list by any other path still gets a queue slot. The invariant
    // that matters is that the badge count and the number of answerable
    // requests can never disagree — a prompt counted but not queued is a
    // prompt the user is told about and then cannot reach.
    final out = <PendingPrompt>[
      for (final x in permissions)
        PendingPrompt(_arrival.putIfAbsent(x.id, () => ++_promptSeq), x, null),
      for (final x in questions)
        PendingPrompt(_arrival.putIfAbsent(x.id, () => ++_promptSeq), null, x),
    ]..sort((a, b) => a.seq.compareTo(b.seq));
    return out;
  }

  /// The request that has been waiting longest, whatever its kind. This is what
  /// the overlay shows, the working strip describes and every Review/Answer
  /// button opens, so all four always agree on which request is next.
  PendingPrompt? get oldestPendingPrompt {
    final q = pendingPrompts;
    return q.isEmpty ? null : q.first;
  }

  /// Stamp a newly seen request id. Ids already known keep their original
  /// position, which is what makes a resync non-destructive to queue order.
  void _stampArrival(Iterable<String> ids) {
    for (final id in ids) {
      if (id.isEmpty) continue;
      _arrival.putIfAbsent(id, () => ++_promptSeq);
    }
  }

  void _forgetArrival(Iterable<String> ids) {
    for (final id in ids) {
      _arrival.remove(id);
    }
  }

  /// True when the session can make no progress until the user replies.
  bool get awaitingPrompt => pendingPromptCount > 0;

  /// Show the prompt sheet for the oldest pending request. A no-op when
  /// nothing is pending, so a stale Review tap cannot open an empty card.
  void openPromptSheet() {
    if (!awaitingPrompt) return;
    if (promptSheetDismissed) {
      promptSheetDismissed = false;
      notifyListeners();
    }
  }

  /// Dismiss the sheet without answering. The request stays pending on the
  /// server, so the badge, the strip and the drawer count keep reporting it.
  void dismissPromptSheet() {
    if (promptSheetDismissed) return;
    promptSheetDismissed = true;
    notifyListeners();
  }

  /// A request arrived. The sheet re-arms unconditionally — a prompt that
  /// was dismissed while a *different* one was on screen must still be seen.
  void _onPromptAdded() {
    promptSheetDismissed = false;
  }

  /// A request was answered (here or in the TUI). Only clear the dismissal once
  /// nothing at all is left, otherwise dismissing and then answering would pop
  /// the sheet straight back open for the next request in the queue.
  void _onPromptRemoved() {
    if (!awaitingPrompt) promptSheetDismissed = false;
  }

  /// Display title for a session id, falling back to the id itself when the
  /// session is not in the list the app holds (a subagent's session, or one
  /// created while we were offline). Used to label a prompt that arrived from
  /// another chat so it is obvious whose run is blocked.
  String sessionLabel(String id) {
    if (id.isEmpty) return S.dash;
    if (current?.id == id) return current!.label;
    for (final s in sessions) {
      if (s.id == id) return s.label;
    }
    return id;
  }
}
