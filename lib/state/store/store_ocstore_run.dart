// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Busy-state watchdog, sending parts, slash commands, revert and agents.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreRun on OcStore {
  void _touchActivity() {
    _probeFailures = 0;
    _lastActivity = DateTime.now();
  }

  void _startBusyTimer() {
    _touchActivity();
    if (_busyTimer?.isActive ?? false) return;
    _busyTimer = Timer.periodic(const Duration(seconds: 15), (t) {
      if (_disposed || !busy) {
        t.cancel();
        _busyTimer = null;
        return;
      }
      final silent = DateTime.now().difference(_lastActivity);
      // 45s of silence used to mean "hang" and the UI spun until the 5 min
      // bail-out. The stream can simply have dropped an event, so ask the
      // server instead of guessing: it is the only authority on run state.
      if (silent > const Duration(seconds: 45)) {
        unawaited(_probeBusyState());
        return;
      }
      if (silent > const Duration(minutes: 5)) {
        t.cancel();
        _busyTimer = null;
        busy = false;
        busyStatus = '';
        _settleStuckStreaming();
        sessionError = S.errNoActivity;
        notifyListeners();
      }
    });
  }

  /// Asks the server whether the current session is still running. Only a
  /// definite "not busy" clears the spinner; a failed probe keeps waiting so a
  /// flaky network can't unlock the composer mid-run.
  Future<void> _probeBusyState() async {
    final id = current?.id;
    if (id == null || _disposed || !busy) return;
    // Don't stack probes on a slow link.
    if (_busyProbeActive) return;
    _busyProbeActive = true;
    try {
      final st = asMap(await api.sessionStatus())[id];
      _probeFailures = 0;
      // Session unknown to the server => nothing is running for it.
      if (st == null) {
        _clearBusyTimer();
        busy = false;
        busyStatus = '';
        _settleStuckStreaming();
        notifyListeners();
        unawaited(refreshTodos());
        return;
      }
      if (asStr(asMap(st)['type']) != 'busy') {
        _clearBusyTimer();
        busy = false;
        busyStatus = '';
        // The run is over server-side; if its closing `message.updated` was lost
        // the dots would spin forever, so retire them before re-syncing.
        _settleStuckStreaming();
        // The idle event was lost: re-sync so the answer is not left cut off.
        unawaited(_resyncMessages(id));
        notifyListeners();
        // Same reason: the todo list's last update went with it.
        unawaited(refreshTodos());
      } else {
        // Still genuinely running: restart the silence window.
        _touchActivity();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('busy probe failed: $e');
      // A flaky link must not unlock the composer mid-run, so the window is
      // still restarted — but after a few failures we stop doing that, which is
      // what lets the 5-minute bail-out above actually fire instead of the probe
      // resetting the clock forever.
      _probeFailures++;
      if (_probeFailures < 3) _touchActivity();
    } finally {
      _busyProbeActive = false;
    }
  }

  void _clearBusyTimer() {
    _busyTimer?.cancel();
    _busyTimer = null;
  }

  /// Kills the typing dots on trailing assistant messages the server never
  /// closed out. Only called on paths where the store has already decided the
  /// run is over (abort, error, lost-`message.updated` probe), so it can never
  /// cut a genuinely live message short — a normal `message.updated` with a
  /// completion stamp is what ends the dots in the happy path.
  ///
  /// Returns true when something changed, so callers can skip a pointless
  /// rebuild.
  bool _settleStuckStreaming() {
    var changed = false;
    for (final m in messages) {
      if (m.streaming) {
        m.settled = true;
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _sendParts(String sid, List<Map<String, dynamic>> parts) async {
    if (providerId.isEmpty || modelId.isEmpty) {
      _toast(S.pickModelFirst);
      return;
    }
    // Was: a system prompt instructing the model to treat Roman-script Hinglish
    // as Hindi and reply in the same script. That is what produced the Hinglish
    // UI strings in the first place - the app was asking the agent to be
    // bilingual while its own chrome was supposed to be one language.
    // One language, English, everywhere.
    // Instant feedback: show "working" right away, don't wait for the server.
    busy = true;
    busyStatus = '';
    _startBusyTimer();
    notifyListeners();
    try {
      await api.promptAsync(
        sid,
        providerId: providerId,
        modelId: modelId,
        agent: agent,
        parts: parts,
        tools: toolMap,
      );
    } on ApiException catch (e) {
      _clearBusyTimer();
      busy = false;
      messagesLoading = false;
      sessionError = e.message;
      _buddyError(e.message);
      // Remove the optimistic user message on error
      messages.removeWhere(
        (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
      );
      notifyListeners();
    } catch (e) {
      _clearBusyTimer();
      busy = false;
      messagesLoading = false;
      sessionError = e.toString();
      _buddyError(e.toString());
      // Remove the optimistic user message on error
      messages.removeWhere(
        (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
      );
      notifyListeners();
    }
  }

  /// Runs a slash command by name.
  Future<void> runCommand(String name, String args) async {
    var sid = current?.id;
    if (sid == null) {
      final s = await newSession();
      if (s == null) return;
      sid = s.id;
    }
    // Same instant-feedback contract as send(): a slash command runs a full
    // agent turn but produced no indicator at all until the server's first
    // status event, so the UI looked inert for seconds.
    busy = true;
    busyStatus = '';
    _startBusyTimer();
    _buddyCall('user', (b) => b.userSent());
    notifyListeners();
    try {
      await api.post(
        '/session/$sid/command',
        body: {
          'command': name,
          'arguments': args,
          if (agent.isNotEmpty) 'agent': agent,
          if (providerId.isNotEmpty)
            'model': {'providerID': providerId, 'modelID': modelId},
          if (toolMap != null) 'tools': toolMap,
        },
        timeout: const Duration(minutes: 30),
      );
    } on ApiException catch (e) {
      _clearBusyTimer();
      busy = false;
      sessionError = e.message;
      _buddyError(e.message);
      _settleStuckStreaming();
      notifyListeners();
    }
  }

  /// Built-in session actions that need a message id.
  Future<void> summarize() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.summarize(id, providerId: providerId, modelId: modelId);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> revert(String messageId, {String? partId}) async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.revert(id, messageId: messageId, partId: partId);
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> unrevert() async {
    final id = current?.id;
    if (id == null) return;
    try {
      await api.unrevert(id);
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> initAgents() async {
    final id = current?.id;
    if (id == null || messages.isEmpty) {
      _toast(S.sendMessageFirst);
      return;
    }
    final lastUser = messages.lastWhere(
      (m) => m.info.isUser,
      orElse: () => messages.firstWhere(
        (m) => m.info.isUser,
        orElse: () => messages.first,
      ),
    );
    try {
      await api.init(
        id,
        messageId: lastUser.info.id,
        providerId: providerId,
        modelId: modelId,
      );
      await openSession(id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }
}
