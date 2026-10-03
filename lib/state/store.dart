import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import '../api/client.dart';
import '../api/events.dart';
import '../models/models.dart';
import '../db/chat_db.dart';

class ChatMessage {
  Message info;
  List<Part> parts;
  String? errorText;

  // FIX: always copy into a *growable* list. Passing `const []` used to make
  // parts.add() throw, so streamed parts never showed up.
  ChatMessage(this.info, List<Part> parts, {this.errorText})
    : parts = List<Part>.of(parts);

  bool get streaming =>
      info.finishReason.isEmpty &&
      info.role == 'assistant' &&
      errorText == null;
}

class PendingAttachment {
  final String path, mime, name;
  final int size;
  final String dataUrl;
  PendingAttachment({
    required this.path,
    required this.mime,
    required this.name,
    required this.size,
    required this.dataUrl,
  });
}

/// Single source of truth for the whole app. A [ChangeNotifier] wired into the
/// widget tree through [AppScope], so no external state-management dependency.
class OcStore extends ChangeNotifier {
  final OcClient api = OcClient();
  EventStream? _stream;

  SharedPreferences? _prefs;
  bool _disposed = false;

  // ---- connection ----
  String baseUrl = 'http://127.0.0.1:4096';
  String username = 'opencode';
  String password = '';
  bool online = false;
  String serverVersion = '';
  ServerPaths? paths;
  VcsInfo? vcs;
  String? fatalError;
  bool booted = false;

  // ---- session ----
  List<Session> sessions = [];
  bool sessionsLoading = false;
  String? sessionsError;
  Session? current;
  List<ChatMessage> messages = [];
  bool messagesLoading = false;
  bool hasMoreMessages = false;
  String? _oldestMessageId;
  bool busy = false;
  String busyStatus = '';
  String? sessionError;
  List<FileDiff> liveDiff = [];
  List<Todo> todos = [];
  final Set<String> toolsEnabled = {};

  // ---- catalog ----
  List<Agent> agents = [];
  ProviderInfo? providerInfo;
  String agent = 'build';
  String providerId = '';
  String modelId = '';
  String modelQuery = '';

  // ---- display prefs ----
  /// When true each assistant reply shows its token / cost footer. Persisted.
  /// Defaults to off; the chat redesign hides tokens behind this flag.
  bool showTokensInChat = false;

  void setShowTokensInChat(bool v) {
    if (showTokensInChat == v) return;
    showTokensInChat = v;
    unawaited(_persist());
    notifyListeners();
  }

  // ---- prompts ----
  List<PermissionReq> permissions = [];
  List<QuestionReq> questions = [];

  // ---- extras ----
  List<CommandInfo> commands = [];
  List<SkillInfo> skills = [];
  Map<String, dynamic> config = {};
  Map<String, NamedStatus> mcp = {};
  List<NamedStatus> lsp = [];
  List<NamedStatus> formatters = [];

  List<PendingAttachment> attachments = [];

  // =====================================================================
  // throttled notify (FIX: streaming used to rebuild the UI on every token)
  // =====================================================================

  Timer? _notifyTimer;

  /// Coalesces many rapid updates (stream deltas etc.) into ~16 rebuilds/sec.
  void _scheduleNotify() {
    if (_disposed || _notifyTimer != null) return;
    _notifyTimer = Timer(const Duration(milliseconds: 60), () {
      _notifyTimer = null;
      if (!_disposed) notifyListeners();
    });
  }

  Timer? _todoTimer;
  void _debouncedTodos() {
    _todoTimer?.cancel();
    _todoTimer = Timer(const Duration(milliseconds: 600), () {
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
  bool _isCacheable(ChatMessage m) {
    if (m.info.id.isEmpty) return false;
    if (m.info.raw['optimistic'] == true) return false;
    if (m.info.raw.isEmpty) return false;
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
    return [...older, ...window];
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

  /// Streaming calls this per token. Snapshotting the touched messages and
  /// letting [ChatDB] serialise the write keeps the cache current without
  /// re-encoding every row in a long session on every token. During a run
  /// only the live message is dirty, so this stays at one row.
  Timer? _flushTimer;
  String? _flushSession;
  final Map<String, Map<String, dynamic>> _dirty = {};

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

  // ---- permissions ----
  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final manage = Permission.manageExternalStorage;
      var status = await manage.status;
      if (!status.isGranted) {
        status = await manage.request();
      }
      if (status.isGranted) return true;
    } catch (_) {}
    final st = await Permission.storage.request();
    return st.isGranted;
  }

  // =====================================================================
  // boot
  // =====================================================================

  Future<void> boot() async {
    _prefs = await SharedPreferences.getInstance();
    baseUrl = _prefs!.getString('url') ?? baseUrl;
    username = _prefs!.getString('user') ?? username;
    password = _prefs!.getString('pass') ?? '';
    agent = _prefs!.getString('agent') ?? agent;
    providerId = _prefs!.getString('provider') ?? '';
    modelId = _prefs!.getString('model') ?? '';
    toolsEnabled.addAll(_prefs!.getStringList('tools') ?? const []);
    showTokensInChat = _prefs!.getBool('showTokens') ?? false;
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
      notifyListeners();

      _startStream();
      await Future.wait([
        refreshCatalog(),
        refreshSessions(),
        refreshServerInfo(),
        refreshCommands(),
        loadPending(),
      ]);
    } on ApiException catch (e) {
      fatalError = e.message;
      // Health check failed, so refreshSessions() above never ran. Populate the
      // session list from disk anyway, otherwise the cached chat history has no
      // entry point while the server is unreachable.
      await _restoreSessionsFromCache();
    } catch (e) {
      fatalError = e.toString();
      await _restoreSessionsFromCache();
    }
    notifyListeners();
  }

  void _startStream() {
    _stream?.stop();
    _stream = EventStream(
      baseUrl: baseUrl,
      username: username,
      password: password,
      onEvent: handleEvent,
      onStatus: (v) {
        online = v;
        notifyListeners();
        if (v && !_disposed) {
          unawaited(loadPending());
          // Re-sync the open chat: events missed while disconnected are gone.
          final id = current?.id;
          if (id != null && !messagesLoading) unawaited(_resyncMessages(id));
        }
      },
    );
    _stream!.start();
  }

  Future<void> _resyncMessages(String id) async {
    try {
      final fresh = (await api.messages(id))
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
      hasMoreMessages = messages.length > fresh.length || fresh.length >= 60;
      _persistHistory(id, fresh);
      notifyListeners();
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> refreshServerInfo() async {
    try {
      paths = await api.paths();
      vcs = await api.vcs();
    } catch (_) {
      /* non fatal */
    }
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    try {
      agents = await api.agents();
      providerInfo = await api.providers();
    } catch (_) {
      /* non fatal */
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
      final list = rows
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
    current =
        sessions.where((s) => s.id == id).firstOrNull ?? await _safeSession(id);
    messages = [];
    sessionError = null;
    liveDiff = [];
    todos = [];
    _oldestMessageId = null;
    hasMoreMessages = false;
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
      final fetched = (await api.messages(id, limit: 60))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      // Merge, don't replace: the server only sent the newest page, and
      // assigning it over `messages` used to drop all older history.
      messages = _mergeHistory(cached, fetched);
      _oldestMessageId = messages.isEmpty ? null : messages.first.info.id;
      // More to show if the merge kept older cached pages, or if the server
      // page came back full (so there is likely another page behind it).
      hasMoreMessages = messages.length > fetched.length || fetched.length >= 60;
      _persistHistory(id, fetched);
      final st = asMap(await api.sessionStatus())[id];
      busy = st != null && asStr(asMap(st)['type']) == 'busy';
      busyStatus = busy ? asStr(asMap(st)['message'], 'busy') : '';
      if (busy) _startBusyTimer();
      unawaited(refreshTodos());
      unawaited(refreshDiff());
    } on ApiException catch (e) {
      sessionError = e.message;
    }
    messagesLoading = false;
    notifyListeners();
  }

  Future<Session?> _safeSession(String id) async {
    try {
      return await api.session(id);
    } catch (_) {
      return null;
    }
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
      _toast('Share link ban gaya');
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
    notifyListeners();
  }

  // =====================================================================
  // todos / diff
  // =====================================================================

  Future<void> refreshTodos() async {
    final id = current?.id;
    if (id == null) return;
    try {
      todos = await api.todos(id);
    } catch (_) {
      /* ignore */
    }
    notifyListeners();
  }

  Future<void> refreshDiff() async {
    final id = current?.id;
    if (id == null) return;
    try {
      liveDiff = await api.diff(id);
    } catch (_) {
      /* ignore */
    }
    notifyListeners();
  }

  Future<void> loadOlderMessages() async {
    final id = current?.id;
    if (id == null || _oldestMessageId == null || messagesLoading) return;
    messagesLoading = true;
    notifyListeners();
    try {
      final fetched =
          (await api.messages(id, limit: 60, before: _oldestMessageId))
              .map((e) => ChatMessage(e.info, e.parts))
              .where((m) => !m.info.summary)
              .toList();
      if (fetched.isNotEmpty) {
        _oldestMessageId = fetched.first.info.id;
        hasMoreMessages = fetched.length >= 60;
        messages = [...fetched, ...messages];
        // Cache the page we just pulled in, otherwise closing and reopening the
        // session re-downloads it and it is gone from disk in between.
        _persistHistory(id, fetched);
      } else {
        hasMoreMessages = false;
      }
    } catch (_) {
      hasMoreMessages = false;
    }
    messagesLoading = false;
    notifyListeners();
  }

  // =====================================================================
  // prompting
  // =====================================================================

  void addAttachment(PendingAttachment a) {
    attachments.add(a);
    notifyListeners();
  }

  void removeAttachment(int i) {
    if (i >= 0 && i < attachments.length) attachments.removeAt(i);
    notifyListeners();
  }

  void clearAttachments() {
    attachments.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> _partPayload() {
    final parts = <Map<String, dynamic>>[];
    for (final a in attachments) {
      parts.add({
        'type': 'file',
        'mime': a.mime,
        'filename': a.name,
        'url': a.dataUrl,
      });
    }
    return parts;
  }

  /// Send a chat message. Returns immediately; output streams in via SSE.
  Future<void> send(
    String text, {
    List<Map<String, dynamic>> extraParts = const [],
  }) async {
    var sid = current?.id;
    if (sid == null) {
      final s = await newSession();
      if (s == null) return;
      sid = s.id;
    }

    final parts = [..._partPayload(), ...extraParts];
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) parts.insert(0, {'type': 'text', 'text': text});
    if (parts.isEmpty) return;
    clearAttachments();

    // Optimistically add user message for instant feedback
    final userMsgId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = Message(
      id: userMsgId,
      sessionId: sid,
      role: 'user',
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
      raw: {'optimistic': true},
    );
    final userParts = parts
        .where((p) => p['type'] == 'text' || p['type'] == 'file')
        .map((p) {
          if (p['type'] == 'text') {
            return Part.fromJson({
              'id': 'part-$userMsgId',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'text',
              'text': p['text'],
            });
          } else {
            return Part.fromJson({
              'id': 'part-$userMsgId-${p['filename']}',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'file',
              'filename': p['filename'],
              'mime': p['mime'],
              'url': p['url'],
            });
          }
        })
        .toList();
    messages.add(ChatMessage(userMsg, userParts));
    notifyListeners();

    sessionError = null;
    await _sendParts(sid, parts);
  }

  // ---- busy watchdog -------------------------------------------------
  // FIX: the old 5-minute one-shot timer was never reset, so any long agent
  // run showed a fake "timeout". Now it only fires after 5 min of *silence*.
  Timer? _busyTimer;
  DateTime _lastActivity = DateTime.now();

  void _touchActivity() => _lastActivity = DateTime.now();

  void _startBusyTimer() {
    _touchActivity();
    if (_busyTimer?.isActive ?? false) return;
    _busyTimer = Timer.periodic(const Duration(seconds: 30), (t) {
      if (_disposed || !busy) {
        t.cancel();
        _busyTimer = null;
        return;
      }
      if (DateTime.now().difference(_lastActivity) >
          const Duration(minutes: 5)) {
        t.cancel();
        _busyTimer = null;
        busy = false;
        busyStatus = '';
        sessionError = 'Server se 5 min tak koi activity nahi aayi. Server logs check karo ya dobara try karo.';
        notifyListeners();
      }
    });
  }

  void _clearBusyTimer() {
    _busyTimer?.cancel();
    _busyTimer = null;
  }

  Future<void> _sendParts(String sid, List<Map<String, dynamic>> parts) async {
    if (providerId.isEmpty || modelId.isEmpty) {
      _toast('Pehle model choose karo');
      return;
    }
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
      sessionError = e.message;
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
      sessionError = e.message;
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
      _toast('Pehle kuch message bhejo');
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

  // =====================================================================
  // shell / files (uses a private utility session so the chat stays clean)
  // =====================================================================

  static const utilSessionTitle = '__opencode_app_util__';
  String? _utilSessionId;

  Future<String> _utilSession() async {
    if (_utilSessionId != null) {
      try {
        await api.session(_utilSessionId!);
        return _utilSessionId!;
      } catch (_) {
        _utilSessionId = null;
      }
    }
    final existing = sessions
        .where((s) => s.title == utilSessionTitle)
        .firstOrNull;
    if (existing != null) {
      _utilSessionId = existing.id;
      return existing.id;
    }
    final s = await api.createSession(title: utilSessionTitle);
    _utilSessionId = s.id;
    if (!_disposed) unawaited(refreshSessions());
    return s.id;
  }

  Future<({int exit, String output})> runShell(String command) async {
    final sid = await _utilSession();
    final r = await api.shell(sid, command: command, agent: agent);
    var out = '';
    var code = 0;
    for (final p in r.parts) {
      if (p.type == 'tool') {
        out = p.output;
        code = p.exitCode ?? 0;
        if (p.errorText.isNotEmpty && out.isEmpty) out = p.errorText;
      }
    }
    return (exit: code, output: out);
  }

  Future<void> writeFile(String path, String content) async {
    final ok = await _ensureStoragePermission();
    if (!ok) {
      throw ApiException(1, 'PermissionDenied', 'Storage permission required to write files');
    }
    final b64 = base64Encode(utf8.encode(content));
    // Chunked so very large files stay inside ARG_MAX.
    const chunk = 24000;
    final chunks = <String>[];
    for (var i = 0; i < b64.length; i += chunk) {
      chunks.add(b64.substring(i, min(i + chunk, b64.length)));
    }
    final q = _shellQuote(path);
    var cmd = ': > $q';
    for (final c in chunks) {
      cmd += " && printf '%s' '$c' >> $q.b64tmp";
    }
    cmd += ' && base64 -d $q.b64tmp > $q && rm -f $q.b64tmp';
    final r = await runShell(cmd);
    if (r.exit != 0)
      throw ApiException(
        1,
        'WriteFailed',
        r.output.isEmpty ? 'Write fail' : r.output,
      );
  }

  static String _shellQuote(String s) {
    // Escape for POSIX shell single quotes: replace ' with '\'' and wrap in single quotes.
    // Also reject newlines and null bytes which would break the quoting.
    if (s.contains('\n') || s.contains('\r') || s.contains('\u0000')) {
      throw ArgumentError('Invalid path: contains newline or null byte');
    }
    return "'${s.replaceAll("'", "'\\''")}'";
  }

  Future<void> deleteEntry(String path) async {
    await runShell('rm -rf ${_shellQuote(path)}');
  }

  Future<void> mkdirEntry(String path) async {
    await runShell('mkdir -p ${_shellQuote(path)}');
  }

  // =====================================================================
  // commands / config / mcp
  // =====================================================================

  Future<void> refreshCommands() async {
    try {
      commands = await api.commands();
      skills = await api.skills();
    } catch (_) {
      /* ignore */
    }
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    try {
      config = await api.config();
      mcp = await api.mcp();
      lsp = await api.lsp();
      formatters = await api.formatters();
    } catch (_) {
      /* ignore */
    }
    notifyListeners();
  }

  Future<void> saveConfig(Map<String, dynamic> patch) async {
    try {
      config = await api.patchConfig(patch);
      _toast('Config save ho gaya');
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }

  Future<void> addMcp(
    String name,
    String type,
    String value,
    List<String> args,
  ) async {
    try {
      final cfg = type == 'remote'
          ? {'type': 'remote', 'url': value, 'enabled': true}
          : {
              'type': 'local',
              'command': [value, ...args],
              'enabled': true,
            };
      await api.mcpAdd(name, cfg);
      mcp = await api.mcp();
      _toast('$name add ho gaya');
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }

  // =====================================================================
  // permissions / questions
  // =====================================================================

  Future<void> loadPending() async {
    if (!online) return;
    try {
      final list = await api.pendingQuestions();
      questions = list
          .where((e) => asStr(e['id']).isNotEmpty)
          .map(QuestionReq.fromJson)
          .where((q) => q.id.isNotEmpty)
          .toList();
    } catch (_) {
      /* ignore */
    }
    notifyListeners();
  }

  Future<void> answerPermission(PermissionReq p, String response) async {
    permissions.removeWhere((e) => e.id == p.id);
    notifyListeners();
    try {
      if (p.sessionId.isNotEmpty) {
        await api.replyPermission(p.sessionId, p.id, response);
      } else {
        await api.replyPermissionV1(p.id, response);
      }
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> answerQuestion(QuestionReq q, List<List<String>> answers) async {
    questions.removeWhere((e) => e.id == q.id);
    notifyListeners();
    try {
      await api.answerQuestion(q.id, answers);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> rejectQuestion(QuestionReq q) async {
    questions.removeWhere((e) => e.id == q.id);
    notifyListeners();
    try {
      await api.rejectQuestion(q.id);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  // =====================================================================
  // event handling
  // =====================================================================

  void handleEvent(OcEvent e) {
    if (_disposed) return;
    // FIX: one malformed event must never kill the handler / stream.
    try {
      _handleEvent(e);
    } catch (err, st) {
      if (kDebugMode) debugPrint('handleEvent(${e.type}) failed: $err\n$st');
    }
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
          if (wasBusy && !busy) _clearBusyTimer();
          if (busy) _startBusyTimer();
          notifyListeners();
        }
        break;
      case 'session.idle':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          busy = false;
          busyStatus = '';
          notifyListeners();
          // The run is over: commit the tail now instead of waiting out the
          // flush debounce, so killing the app here still keeps the answer.
          unawaited(_flushHistory());
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
          sessionError = _errorText(asMap(p['error']));
          busy = false;
          notifyListeners();
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
        final req = e.type == 'permission.v2.asked'
            ? PermissionReq.fromV2(asMap(p))
            : PermissionReq.fromJson(asMap(p));
        if (req.id.isNotEmpty && !permissions.any((x) => x.id == req.id)) {
          permissions.add(req);
          notifyListeners();
        }
        break;
      case 'permission.replied':
      case 'permission.v2.replied':
        final id = asStr(p['permissionID'], asStr(p['id']));
        permissions.removeWhere((x) => x.id == id);
        notifyListeners();
        break;
      case 'question.asked':
      case 'question.v2.asked':
        final q = QuestionReq.fromJson(asMap(p));
        if (q.id.isNotEmpty && !questions.any((x) => x.id == q.id)) {
          questions.add(q);
          notifyListeners();
        }
        break;
      case 'question.replied':
      case 'question.rejected':
      case 'question.v2.replied':
        questions.removeWhere(
          (x) => x.id == asStr(p['questionID'], asStr(p['id'])),
        );
        notifyListeners();
        break;
      case 'todo.updated':
        // FIX: debounced. Used to fire an HTTP call + rebuild on every event.
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

  int _optimisticIndex() => messages.indexWhere(
    (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
  );

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
      // Server echo of the message we showed optimistically: swap in place.
      messages[_optimisticIndex()] = ChatMessage(info, <Part>[]);
    } else {
      messages.add(ChatMessage(info, <Part>[]));
    }
    final m = _messageById(info.id);
    if (m != null && current != null) _scheduleFlush(current!.id, m);
    _scheduleNotify();
  }

  void _upsertPart(Part part) {
    if (!_isCurrent(part.sessionId)) return;
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
      msg.parts.add(part);
    }
    if (current != null) _scheduleFlush(current!.id, msg);
    _scheduleNotify();
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
        if (current != null) _scheduleFlush(current!.id, m);
        _scheduleNotify(); // FIX: was notifyListeners() on every single token
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
    _scheduleNotify();
  }

  void _removeMessage(String sid, String messageId) {
    if (!_isCurrent(sid)) return;
    messages.removeWhere((m) => m.info.id == messageId);
    if (current != null) {
      unawaited(ChatDB.instance.deleteMessage(current!.id, messageId));
    }
    _scheduleNotify();
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
    _scheduleNotify();
  }

  // =====================================================================

  String? _lastToast;
  void _toast(String m) => _lastToast = m;
  String? takeToast() {
    final t = _lastToast;
    _lastToast = null;
    return t;
  }

  /// Call this on app resume to reconnect the SSE stream if needed.
  void reconnectStream() {
    _stream?.reconnect();
  }

  void pauseConnections() {
    try {
      _stream?.stop();
    } catch (_) {}
    _clearBusyTimer();
    // Android can kill a backgrounded process without further notice; commit the
    // streamed tail now rather than relying on the debounce timer.
    unawaited(_flushHistory());
  }

  void resumeConnections() {
    try {
      _stream?.reconnect();
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _clearBusyTimer();
    _notifyTimer?.cancel();
    _todoTimer?.cancel();
    _flushTimer?.cancel();
    _stream?.stop();
    unawaited(_flushHistory());
    api.close();
    super.dispose();
  }
}
