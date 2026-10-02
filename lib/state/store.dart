import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/events.dart';
import '../models/models.dart';

class ChatMessage {
  Message info;
  List<Part> parts;
  String? errorText;
  ChatMessage(this.info, this.parts, {this.errorText});

  bool get streaming => info.finishReason.isEmpty && info.role == 'assistant' && errorText == null;
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
  Session? current;
  List<ChatMessage> messages = [];
  bool messagesLoading = false;
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
    } catch (e) {
      fatalError = e.toString();
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
        }
      },
    );
    _stream!.start();
  }

  Future<void> refreshServerInfo() async {
    try {
      paths = await api.paths();
      vcs = await api.vcs();
    } catch (_) {/* non fatal */}
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    try {
      agents = await api.agents();
      providerInfo = await api.providers();
    } catch (_) {/* non fatal */}

    if (providerId.isEmpty || modelId.isEmpty) {
      final p = providerInfo;
      if (p != null) {
        final conn = p.connected.isNotEmpty ? p.connected : p.ordered.map((e) => e.id).toList();
        for (final pid in conn) {
          final prov = p.all.where((e) => e.id == pid).firstOrNull;
          if (prov == null || prov.models.isEmpty) continue;
          final def = p.defaults[pid];
          final pick = prov.models.firstWhere((m) => m.id == def,
              orElse: () => prov.models.first);
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

  Map<String, bool>? get toolMap => toolsEnabled.isEmpty ? null : {for (final t in toolsEnabled) t: true};

  // =====================================================================
  // sessions
  // =====================================================================

  Future<void> refreshSessions() async {
    try {
      final list = await api.sessions();
      sessions = list..sort((a, b) => b.updated.compareTo(a.updated));
      if (current != null) {
        final i = sessions.indexWhere((s) => s.id == current!.id);
        if (i >= 0) current = sessions[i];
      }
    } on ApiException catch (e) {
      fatalError = e.message;
    }
    notifyListeners();
  }

  Future<Session?> newSession({String? title}) async {
    try {
      final s = await api.createSession(
        title: title,
        agent: agent,
        model: providerId.isEmpty ? null : {'providerID': providerId, 'id': modelId},
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
    current = sessions.where((s) => s.id == id).firstOrNull ?? await _safeSession(id);
    messages = [];
    sessionError = null;
    liveDiff = [];
    todos = [];
    messagesLoading = true;
    notifyListeners();
    try {
      messages = (await api.messages(id))
          .map((e) => ChatMessage(e.info, e.parts))
          .where((m) => !m.info.summary)
          .toList();
      final st = asMap(await api.sessionStatus())[id];
      busy = st != null && asStr(asMap(st)['type']) == 'busy';
      busyStatus = busy ? asStr(asMap(st)['message'], 'busy') : '';
      await Future.wait([refreshTodos(), refreshDiff()]);
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
    } catch (_) {/* ignore */}
    notifyListeners();
  }

  Future<void> refreshDiff() async {
    final id = current?.id;
    if (id == null) return;
    try {
      liveDiff = await api.diff(id);
    } catch (_) {/* ignore */}
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
  Future<void> send(String text, {List<Map<String, dynamic>> extraParts = const []}) async {
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
    final userParts = parts.where((p) => p['type'] == 'text' || p['type'] == 'file').map((p) {
      if (p['type'] == 'text') {
        return Part.fromJson({'id': 'part-$userMsgId', 'messageID': userMsgId, 'sessionID': sid, 'type': 'text', 'text': p['text']});
      } else {
        return Part.fromJson({'id': 'part-$userMsgId-${p['filename']}', 'messageID': userMsgId, 'sessionID': sid, 'type': 'file', 'filename': p['filename'], 'mime': p['mime'], 'url': p['url']});
      }
    }).toList();
    messages.add(ChatMessage(userMsg, userParts));
    notifyListeners();

    sessionError = null;
    await _sendParts(sid, parts);
  }

  Timer? _busyTimer;

  void _startBusyTimer() {
    _busyTimer?.cancel();
    _busyTimer = Timer(const Duration(minutes: 5), () {
      if (busy) {
        busy = false;
        busyStatus = '';
        sessionError = 'Server response timeout (5 min). Check server logs or try again.';
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
    try {
      await api.promptAsync(
        sid,
        providerId: providerId,
        modelId: modelId,
        agent: agent,
        parts: parts,
        tools: toolMap,
      );
      _startBusyTimer();
    } on ApiException catch (e) {
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
      await api.post('/session/$sid/command', body: {
        'command': name,
        'arguments': args,
        if (agent.isNotEmpty) 'agent': agent,
        if (providerId.isNotEmpty) 'model': {'providerID': providerId, 'modelID': modelId},
        if (toolMap != null) 'tools': toolMap,
      }, timeout: const Duration(minutes: 30));
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
    final lastUser = messages.lastWhere((m) => m.info.isUser,
        orElse: () => messages.firstWhere((m) => m.info.isUser, orElse: () => messages.first));
    try {
      await api.init(id,
          messageId: lastUser.info.id, providerId: providerId, modelId: modelId);
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
    final existing = sessions.where((s) => s.title == utilSessionTitle).firstOrNull;
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
    if (r.exit != 0) throw ApiException(1, 'WriteFailed', r.output.isEmpty ? 'Write fail' : r.output);
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
    } catch (_) {/* ignore */}
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    try {
      config = await api.config();
      mcp = await api.mcp();
      lsp = await api.lsp();
      formatters = await api.formatters();
    } catch (_) {/* ignore */}
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

  Future<void> addMcp(String name, String type, String value, List<String> args) async {
    try {
      final cfg = type == 'remote'
          ? {'type': 'remote', 'url': value, 'enabled': true}
          : {'type': 'local', 'command': [value, ...args], 'enabled': true};
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
    } catch (_) {/* ignore */}
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
    final p = e.properties;

    switch (e.type) {
      case 'message.updated':
        _upsertMessage(Message.fromJson(asMap(p['info'])));
        break;
      case 'message.part.updated':
        _upsertPart(Part.fromJson(asMap(p['part'])));
        break;
      case 'message.part.delta':
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
          if (!wasBusy && busy) _startBusyTimer();
          notifyListeners();
        }
        break;
      case 'session.idle':
        if (_isCurrent(asStr(p['sessionID']))) {
          _clearBusyTimer();
          busy = false;
          busyStatus = '';
          notifyListeners();
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
        _upsertSession(Session.fromJson(asMap(p['info'])));
        break;
      case 'session.created':
        _upsertSession(Session.fromJson(asMap(p['info'])));
        break;
      case 'session.deleted':
        sessions.removeWhere((s) => s.id == asStr(p['sessionID'], asStr(p['info'] != null ? asMap(p['info'])['id'] : '')));
        if (current?.id == asStr(p['info'] != null ? asMap(p['info'])['id'] : '')) {
          current = null;
          messages = [];
        }
        notifyListeners();
        break;
      case 'session.diff':
        if (_isCurrent(asStr(p['sessionID']))) {
          liveDiff = asList(p['diff']).map((e) => FileDiff.fromJson(asMap(e))).toList();
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
        questions.removeWhere((x) => x.id == asStr(p['questionID'], asStr(p['id'])));
        notifyListeners();
        break;
      case 'todo.updated':
      case 'lsp.updated':
      case 'file.edited':
      case 'mcp.tools.changed':
      case 'installation.updated':
        if (!_disposed) unawaited(refreshTodos());
        break;
      case 'server.connected':
        online = true;
        notifyListeners();
        break;
    }
  }

  String _errorText(Map<String, dynamic> err) {
    final name = asStr(err['name']);
    final data = asMap(err['data']);
    final msg = asStr(data['message'], asStr(err['message']));
    return msg.isEmpty ? (name.isEmpty ? 'Unknown error' : name) : msg;
  }

  bool _isCurrent(String sid) => sid.isEmpty || current == null || current!.id == sid;

  ChatMessage? _messageById(String id) {
    for (final m in messages) {
      if (m.info.id == id) return m;
    }
    return null;
  }

  void _upsertMessage(Message info) {
    if (!_isCurrent(info.sessionId)) return;
    final existing = _messageById(info.id);
    if (existing != null) {
      existing.info = info;
    } else {
      // Check if this is a server-echoed user message replacing an optimistic one
      if (info.role == 'user' && !info.raw.containsKey('optimistic')) {
        final optimisticIdx = messages.indexWhere((m) => m.info.raw['optimistic'] == true && m.info.role == 'user');
        if (optimisticIdx >= 0) {
          messages[optimisticIdx] = ChatMessage(info, const []);
          notifyListeners();
          return;
        }
      }
      messages.add(ChatMessage(info, const []));
    }
    notifyListeners();
  }

  void _upsertPart(Part part) {
    if (!_isCurrent(part.sessionId)) return;
    var msg = _messageById(part.messageId);
    if (msg == null) {
      // Check if the message was an optimistic one that got replaced
      ChatMessage? optimisticMsg;
      for (final m in messages) {
        if (m.info.raw['optimistic'] == true && m.info.role == 'user') {
          optimisticMsg = m;
          break;
        }
      }
      if (optimisticMsg != null && part.messageId.startsWith('local-')) {
        // Map the optimistic message ID to the real one
        // This is a heuristic - the server might send parts for the real message ID
        msg = optimisticMsg;
      } else {
        // The part arrived before its message header; synthesise a placeholder.
        final info = Message(
          id: part.messageId,
          sessionId: part.sessionId,
          role: part.type == 'text' && part.messageId.isEmpty ? 'user' : 'assistant',
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
        msg = ChatMessage(info, const []);
        messages.add(msg);
      }
    }
    if (msg != null) {
      final i = msg.parts.indexWhere((p) => p.id == part.id);
      if (i >= 0) {
        msg.parts[i] = part;
      } else {
        msg.parts.add(part);
      }
    }
    notifyListeners();
  }

  void _applyDelta(String partId, String field, String delta) {
    if (delta.isEmpty) return;
    for (final m in messages) {
      final i = m.parts.indexWhere((p) => p.id == partId);
      if (i < 0) continue;
      final p = m.parts[i];
      final raw = Map<String, dynamic>.from(p.raw);
      raw[field] = '${asStr(raw[field])}$delta';
      // Only replace if the part actually changed meaningfully
      final newPart = Part.fromJson(raw);
      if (newPart != p) {
        m.parts[i] = newPart;
        notifyListeners();
      }
      return;
    }
  }

  void _removePart(String sid, String partId) {
    if (!_isCurrent(sid)) return;
    for (final m in messages) {
      m.parts.removeWhere((p) => p.id == partId);
    }
    notifyListeners();
  }

  void _removeMessage(String sid, String messageId) {
    if (!_isCurrent(sid)) return;
    messages.removeWhere((m) => m.info.id == messageId);
    notifyListeners();
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
    notifyListeners();
  }

  // =====================================================================

  String? _lastToast;
  void _toast(String m) => _lastToast = m;
  String? takeToast() {
    final t = _lastToast;
    _lastToast = null;
    return t;
  }

  @override
  void dispose() {
    _disposed = true;
    _clearBusyTimer();
    _stream?.stop();
    api.close();
    super.dispose();
  }
}
