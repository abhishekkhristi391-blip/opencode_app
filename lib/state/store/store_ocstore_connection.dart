// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Boot, server connection, reachability probe, event stream and catalog refresh.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreConnection on OcStore {
  // ---- permissions ----
  // NOTE: there is deliberately no storage-permission gate here. File writes go
  // through the server's shell, so this app's MANAGE_EXTERNAL_STORAGE state is
  // irrelevant to them; prompting for it only added friction.

  // =====================================================================
  // boot
  // =====================================================================

  Future<void> boot() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    baseUrl = prefs.getString('url') ?? baseUrl;
    username = prefs.getString('user') ?? username;
    password = prefs.getString('pass') ?? '';
    agent = prefs.getString('agent') ?? agent;
    providerId = prefs.getString('provider') ?? '';
    modelId = prefs.getString('model') ?? '';
    toolsEnabled.addAll(prefs.getStringList('tools') ?? const []);
    pinned.addAll(prefs.getStringList('pinned') ?? const []);
    showTokensInChat = prefs.getBool('showTokens') ?? false;
    booted = true;
    notifyListeners();
    await connect();
  }

  Future<void> _persist() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString('url', baseUrl);
    await p.setString('user', username);
    await p.setString('pass', password);
    await p.setString('agent', agent);
    await p.setString('provider', providerId);
    await p.setString('model', modelId);
    await p.setStringList('tools', toolsEnabled.toList());
    await p.setStringList('pinned', pinned.toList());
    await p.setBool('showTokens', showTokensInChat);
  }

  // =====================================================================
  // connection
  // =====================================================================

  Future<void> setServer(String url, {String? user, String? pass}) async {
    baseUrl = url.trim();
    if (user != null) username = user.trim();
    if (pass != null) password = pass;
    await _persist();
    await connect();
  }

  Future<void> connect() async {
    // A second tap on Retry must not race the first: two health checks, two
    // streams and two session refreshes would interleave into a duplicate.
    if (_connecting || _disposed) return;
    _connecting = true;
    try {
      fatalError = null;
      online = false;
      api.baseUrl = baseUrl;
      api.username = username;
      api.password = password;
      notifyListeners();

      try {
        final h = await api.health().timeout(const Duration(seconds: 8));
        serverVersion = h.version;
        online = true;
        fatalError = null;
        notifyListeners();

        _startStream();
        await Future.wait([
          refreshCatalog(),
          refreshSessions(),
          refreshServerInfo(),
          refreshCommands(),
          resyncPrompts(),
        ]);
      } on ApiException catch (e) {
        fatalError = e.message;
        // Health check failed, so refreshSessions() above never ran. Populate
        // the session list from disk anyway, otherwise the cached chat history
        // has no entry point while the server is unreachable.
        await _restoreSessionsFromCache();
      } catch (e) {
        // Anything the client did not already translate (a raw socket error
        // from a half-open handshake, a format error from an HTTP 200 that was
        // not JSON) becomes one actionable line instead of a stack trace.
        if (kDebugMode) debugPrint('connect failed: $e');
        fatalError = _offlineMessage();
        await _restoreSessionsFromCache();
      }
      notifyListeners();
    } finally {
      _connecting = false;
    }
  }

  /// The single user-facing offline string. Kept identical everywhere so the
  /// error screen and any toast agree on what to do about it.
  String _offlineMessage() => S.netUnreachable(baseUrl);

  /// Asks the server whether it is really gone.
  ///
  /// A dropped event stream is ambiguous: the socket can die while the server
  /// is perfectly healthy (battery freeze, OS-reaped socket, wifi handover),
  /// and the server can die while the socket still looks open. Only the server
  /// can tell them apart, and the UI must not show "Offline" for the first one
  /// or a green dot for the second.
  Future<void> _verifyReachability({bool full = false}) async {
    if (_reachProbeBusy || _disposed) return;
    _reachProbeBusy = true;
    var up = false;
    String? err;
    try {
      final h = await api.health().timeout(const Duration(seconds: 6));
      serverVersion = h.version;
      up = true;
    } on ApiException catch (e) {
      err = e.message;
    } catch (e) {
      if (kDebugMode) debugPrint('reachability probe failed: $e');
      err = _offlineMessage();
    } finally {
      _reachProbeBusy = false;
    }
    if (_disposed) return;

    if (up) {
      online = true;
      // Still reconnecting if the SSE stream itself has not come back yet.
      reconnecting = !(_stream?.live ?? false);
      fatalError = null;
      notifyListeners();
      // The server is up, so the app stays usable and the dot stays green. The
      // stream is simply retrying: if nothing is already connecting, kick it
      // now to collapse its backoff, so a Termux that came back mid-backoff is
      // picked up on the first try instead of up to 15s later.
      final stream = _stream;
      final live = stream?.live ?? false;
      if (stream != null && !live) stream.reconnect();
      // If the stream cannot come up at all (SSE refused while HTTP works),
      // nothing else will ever re-sync, so do it here instead.
      if (!live) {
        unawaited(resyncPrompts());
        final id = current?.id;
        if (id != null && !messagesLoading) unawaited(_resyncMessages(id));
        if (busy) unawaited(_probeBusyState());
      }
      if (full) {
        // Coming back from the background: sessions may have been created,
        // renamed or deleted elsewhere while we were frozen.
        unawaited(refreshSessions());
        unawaited(refreshServerInfo());
      }
      return;
    }

    online = false;
    reconnecting = false;
    fatalError = err ?? _offlineMessage();
    notifyListeners();
  }

  void _startStream() {
    // The old stream is being replaced, not paused: make sure no late callback
    // from it can reconnect into this store.
    unawaited(_stream?.shutdown());
    _stream = EventStream(
      baseUrl: baseUrl,
      username: username,
      password: password,
      onEvent: handleEvent,
      onStatus: _onStreamStatus,
      // The watchdog uses this to tell "the agent is quiet" from "the socket
      // is gone" — without it every long tool call looks like a dead stream.
      isBusy: () => busy,
    );
    // `online` is not forced true here: the stream owns that signal from now
    // on. Claiming it before the SSE handshake is what let the UI sit on a
    // green dot over a stream that had never connected.
    unawaited(_stream!.start());
  }

  /// Stream up/down edges. See [_verifyReachability] for why a down edge is
  /// never applied to `online` directly.
  void _onStreamStatus(bool up) {
    if (_disposed) return;
    if (!up) {
      // Stream dropped but the server may still be reachable. [online] keeps
      // telling the last known truth until the probe decides, so the header has
      // to say "reconnecting" rather than flip straight to "offline" and then
      // back, which reads as two unrelated states.
      reconnecting = true;
      unawaited(_verifyReachability());
      return;
    }
    online = true;
    reconnecting = false;
    fatalError = null;
    notifyListeners();

    // A permission or question asked while we were away has no event left to
    // deliver it, so the prompt card would simply never appear.
    unawaited(resyncPrompts());
    // Todo updates that landed while the socket was down are gone with it, and
    // the list is the one panel the user watches during a run. Single-flight, so
    // this coalesces with the resume path that is usually running alongside it.
    unawaited(refreshTodos());
    // Events missed while disconnected are gone and cannot be replayed, so the
    // server's own page is the only authority on what really happened.
    final id = current?.id;
    if (id != null && !messagesLoading) unawaited(_resyncMessages(id));
    // A run that finished while we were away never sent its idle event, so the
    // dots would spin for a full 45s silence window before the probe noticed.
    if (busy) unawaited(_probeBusyState());
  }

  Future<void> _resyncMessages(String id) async {
    // Resume, a socket re-established by the watchdog and a manual reconnect
    // can all land here within the same second. One in-flight fetch covers
    // them all, and a second would only fight it over `messages`.
    if (_resyncing) return;
    _resyncing = true;
    try {
      // Same page size as openSession — the 60 default silently truncated the
      // history of any long conversation on every resync.
      final fresh = (await api.messages(id, limit: _limit))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      if (current?.id != id || _disposed) return;
      // Merge rather than replace: this fires once a run finishes, and
      // assigning the fresh page over the list used to drop every message the
      // server did not include — and nothing was cached afterwards, so the
      // next open lost them for good.
      messages = _mergeHistory(messages, fresh);
      // The merge can push older messages back to the front, so the pagination
      // cursor has to move with it or "load older" would skip a page.
      _oldestMessageId = messages.isEmpty ? null : messages.first.info.id;
      hasMoreMessages =
          messages.length > fresh.length || fresh.length >= _limit;
      _persistHistory(id, fresh);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to resync messages: $e');
    } finally {
      _resyncing = false;
    }
  }

  Future<void> refreshServerInfo() async {
    try {
      paths = await api.paths();
      vcs = await api.vcs();
    } catch (e) {
      debugPrint('Failed to refresh server info: $e');
    }
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    try {
      agents = await api.agents();
      providerInfo = await api.providers();
    } catch (e) {
      debugPrint('Failed to refresh catalog: $e');
    }

    if (providerId.isEmpty || modelId.isEmpty) {
      final p = providerInfo;
      if (p != null) {
        final conn = p.connected.isNotEmpty
            ? p.connected
            : p.ordered.map((e) => e.id).toList();
        for (final pid in conn) {
          final prov = p.all.where((e) => e.id == pid).firstOrNull;
          if (prov == null || prov.models.isEmpty) continue;
          final def = p.defaults[pid];
          final pick = prov.models.firstWhere(
            (m) => m.id == def,
            orElse: () => prov.models.first,
          );
          providerId = prov.id;
          modelId = pick.id;
          break;
        }
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setModel(String provider, String model) async {
    providerId = provider;
    modelId = model;
    await _persist();
    notifyListeners();
  }

  Future<void> setAgent(String a) async {
    agent = a;
    await _persist();
    notifyListeners();
  }

  void toggleTool(String id, bool on) {
    if (on) {
      toolsEnabled.add(id);
    } else {
      toolsEnabled.remove(id);
    }
    unawaited(_persist());
    notifyListeners();
  }

  Map<String, bool>? get toolMap =>
      toolsEnabled.isEmpty ? null : {for (final t in toolsEnabled) t: true};
}
