import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/models.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final String name;
  ApiException(this.status, this.name, this.message);

  bool get isAuth => status == 401 || status == 403;
  bool get isNotFound => status == 404;

  @override
  String toString() => message;
}

/// Runs in a background isolate so big JSON never freezes the UI.
dynamic _parseBytes(Uint8List b) => jsonDecode(utf8.decode(b, allowMalformed: true));

/// Bodies bigger than this are parsed off the UI thread.
const _isolateThreshold = 32 * 1024;

/// Thin typed wrapper over the opencode HTTP server.
class OcClient {
  String baseUrl;
  String username;
  String password;

  OcClient({this.baseUrl = 'http://127.0.0.1:4096', this.username = 'opencode', this.password = ''});

  // Fast connect timeout + keep-alive so repeated calls reuse the socket.
  final http.Client _client = IOClient(HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..idleTimeout = const Duration(minutes: 2));

  String get root => baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Map<String, String> _headers({bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (password.isNotEmpty)
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      };

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final qs = <String, String>{};
    q?.forEach((k, v) {
      if (v == null) return;
      final s = v is List ? v.join(',') : v.toString();
      if (s.isEmpty) return;
      qs[k] = s;
    });
    return Uri.parse('$root$path').replace(queryParameters: qs.isEmpty ? null : qs);
  }

  /// Decode a response body, turning opencode's `{name, data}` error envelope
  /// into an [ApiException]. Large bodies are parsed in a background isolate.
  Future<dynamic> _decode(http.Response r) async {
    final bytes = r.bodyBytes;
    dynamic body;
    var text = '';

    if (bytes.isNotEmpty) {
      if (bytes.length > _isolateThreshold && r.statusCode < 400) {
        try {
          body = await compute(_parseBytes, bytes);
        } catch (_) {
          body = utf8.decode(bytes, allowMalformed: true);
        }
      } else {
        text = utf8.decode(bytes, allowMalformed: true);
        try {
          body = jsonDecode(text);
        } catch (_) {
          body = text;
        }
      }
    }

    if (r.statusCode >= 400) {
      if (text.isEmpty && bytes.isNotEmpty) text = utf8.decode(bytes, allowMalformed: true);
      if (body is Map && body['name'] != null && body['data'] != null) {
        throw ApiException(r.statusCode, body['name'].toString(),
            asMap(body['data'])['message']?.toString() ?? text);
      }
      throw ApiException(r.statusCode, 'HTTP ${r.statusCode}',
          text.isEmpty ? 'HTTP ${r.statusCode}' : text);
    }
    return body;
  }

  Future<dynamic> _send(Future<http.Response> Function() run, Duration timeout) async {
    try {
      final r = await run().timeout(timeout);
      return await _decode(r);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(0, 'Timeout', 'Server ne ${timeout.inSeconds}s me reply nahi diya');
    } on SocketException {
      throw ApiException(0, 'NoConnection',
          'Server se connect nahi ho raha.\n\n$root reachable hai?\nTermux me chal raha hai?');
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network', e.message);
    } on FormatException {
      throw ApiException(0, 'BadResponse', 'Server ka reply samajh nahi aaya');
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? q, Duration? timeout}) =>
      _send(() => _client.get(_u(path, q), headers: _headers()), timeout ?? const Duration(seconds: 30));

  Future<dynamic> post(String path,
          {Object? body, Map<String, dynamic>? q, Duration? timeout}) =>
      _send(
          () => _client.post(_u(path, q), headers: _headers(), body: body == null ? null : jsonEncode(body)),
          timeout ?? const Duration(seconds: 30));

  Future<dynamic> patch(String path, {Object? body, Map<String, dynamic>? q, Duration? timeout}) => _send(
      () => _client.patch(_u(path, q), headers: _headers(), body: jsonEncode(body ?? {})),
      timeout ?? const Duration(seconds: 30));

  Future<dynamic> put(String path, {Object? body, Map<String, dynamic>? q, Duration? timeout}) => _send(
      () => _client.put(_u(path, q), headers: _headers(), body: jsonEncode(body ?? {})),
      timeout ?? const Duration(seconds: 30));

  Future<dynamic> delete(String path, {Object? body, Map<String, dynamic>? q, Duration? timeout}) => _send(
      () => _client.delete(_u(path, q), headers: _headers(), body: body == null ? null : jsonEncode(body)),
      timeout ?? const Duration(seconds: 30));

  void close() => _client.close();

  // ---------------- live events (SSE) ----------------

  /// Live event stream. Each item is one decoded event: `{type, properties}`.
  /// Use this for streaming chat instead of polling `messages()`.
  Stream<Map<String, dynamic>> events({bool global = false}) async* {
    final req = http.Request('GET', _u(global ? '/global/event' : '/event'));
    req.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (password.isNotEmpty)
        'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    });

    http.StreamedResponse resp;
    try {
      resp = await _client.send(req).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw ApiException(0, 'Timeout', 'Event stream connect nahi hua');
    } on SocketException {
      throw ApiException(0, 'NoConnection', 'Server se connect nahi ho raha.');
    }
    if (resp.statusCode >= 400) {
      throw ApiException(resp.statusCode, 'HTTP ${resp.statusCode}', 'Event stream error ${resp.statusCode}');
    }

    final buf = StringBuffer();
    final lines = resp.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (line.isEmpty) {
        if (buf.isEmpty) continue;
        final raw = buf.toString();
        buf.clear();
        try {
          final j = jsonDecode(raw);
          if (j is Map) yield asMap(j);
        } catch (_) {}
      } else if (line.startsWith('data:')) {
        if (buf.isNotEmpty) buf.write('\n');
        buf.write(line.substring(5).trimLeft());
      }
    }
  }

  /// Same as [events] but reconnects automatically if the connection drops.
  Stream<Map<String, dynamic>> eventsAutoReconnect({bool global = false}) async* {
    while (true) {
      try {
        await for (final e in events(global: global)) {
          yield e;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // ---------------- global ----------------

  Future<({bool healthy, String version})> health() async {
    final j = asMap(await get('/global/health'));
    return (healthy: asBool(j['healthy']), version: asStr(j['version']));
  }

  Future<ServerPaths> paths() async => ServerPaths.fromJson(asMap(await get('/path')));

  Future<VcsInfo> vcs() async => VcsInfo.fromJson(asMap(await get('/vcs')));

  Future<void> disposeInstance() => post('/instance/dispose', timeout: const Duration(seconds: 60));

  Future<bool> upgrade() async => asBool(await post('/global/upgrade', timeout: const Duration(minutes: 5)));

  Future<bool> log(String service, String level, String message) async =>
      asBool(await post('/log', body: {'service': service, 'level': level, 'message': message}));

  // ---------------- config ----------------

  Future<Map<String, dynamic>> config() async => asMap(await get('/config'));

  Future<Map<String, dynamic>> patchConfig(Map<String, dynamic> values) async =>
      asMap(await patch('/config', body: values));

  Future<List<ProviderEntry>> configProviders() async {
    final j = asMap(await get('/config/providers'));
    return asList(j['providers']).map((e) => ProviderEntry.fromJson(asMap(e))).toList();
  }

  // ---------------- providers / models ----------------

  Future<ProviderInfo> providers() async => ProviderInfo.fromJson(asMap(await get('/provider')));

  Future<List<AuthMethod>> providerAuthMethods() async {
    final j = asMap(await get('/provider/auth'));
    final out = <AuthMethod>[];
    j.forEach((k, v) {
      for (final e in asList(v)) {
        out.add(AuthMethod.from(k, asMap(e)));
      }
    });
    return out;
  }

  Future<Map<String, dynamic>> providerAuthUrl(String providerId, {String? callbackUrl}) async =>
      asMap(await post('/provider/$providerId/oauth/authorize',
          body: {'callbackUrl': callbackUrl ?? 'http://localhost:8976/oauth/callback'}));

  Future<bool> setApiKey(String providerId, String key) async =>
      asBool(await put('/auth/$providerId', body: {'type': 'api', 'key': key}, timeout: const Duration(minutes: 2)));

  Future<void> removeAuth(String providerId) => delete('/auth/$providerId');

  // ---------------- agents ----------------

  Future<List<Agent>> agents() async =>
      asList(await get('/agent')).map((e) => Agent.fromJson(asMap(e))).toList();

  // ---------------- sessions ----------------

  Future<List<Session>> sessions() async =>
      asList(await get('/session')).map((e) => Session.fromJson(asMap(e))).toList();

  Future<Session> createSession({String? title, String? parentId, String? agent, Map<String, String>? model}) async =>
      Session.fromJson(asMap(await post('/session', body: {
        if (title != null) 'title': title,
        if (parentId != null) 'parentID': parentId,
        if (agent != null) 'agent': agent,
        if (model != null) 'model': model,
      })));

  Future<Session> session(String id) async => Session.fromJson(asMap(await get('/session/$id')));

  Future<bool> deleteSession(String id) async => asBool(await delete('/session/$id', timeout: const Duration(minutes: 2)));

  Future<Session> renameSession(String id, String title) async =>
      Session.fromJson(asMap(await patch('/session/$id', body: {'title': title})));

  Future<List<Session>> childSessions(String id) async =>
      asList(await get('/session/$id/children')).map((e) => Session.fromJson(asMap(e))).toList();

  Future<Map<String, dynamic>> sessionStatus() async => asMap(await get('/session/status'));

  Future<List<Todo>> todos(String id) async =>
      asList(await get('/session/$id/todo')).map((e) => Todo.fromJson(asMap(e))).toList();

  Future<bool> abort(String id) async =>
      asBool(await post('/session/$id/abort', timeout: const Duration(minutes: 2)));

  Future<Session> fork(String id, {String? messageId}) async =>
      Session.fromJson(asMap(await post('/session/$id/fork', body: {'messageID': messageId})));

  Future<Session> share(String id) async =>
      Session.fromJson(asMap(await post('/session/$id/share', timeout: const Duration(minutes: 2))));

  Future<Session> unshare(String id) async => Session.fromJson(
      asMap(await delete('/session/$id/share', timeout: const Duration(minutes: 2))));

  Future<List<FileDiff>> diff(String id, {String? messageId}) async =>
      asList(await get('/session/$id/diff', q: {'messageID': messageId}))
          .map((e) => FileDiff.fromJson(asMap(e)))
          .toList();

  Future<bool> init(String id, {required String messageId, required String providerId, required String modelId}) async =>
      asBool(await post('/session/$id/init',
          body: {'messageID': messageId, 'providerID': providerId, 'modelID': modelId},
          timeout: const Duration(minutes: 10)));

  Future<bool> summarize(String id, {required String providerId, required String modelId}) async =>
      asBool(await post('/session/$id/summarize',
          body: {'providerID': providerId, 'modelID': modelId},
          timeout: const Duration(minutes: 10)));

  Future<Session> revert(String id, {required String messageId, String? partId}) async =>
      Session.fromJson(asMap(await post('/session/$id/revert',
          body: {'messageID': messageId, if (partId != null) 'partID': partId})));

  Future<bool> unrevert(String id) async => asBool(await post('/session/$id/unrevert'));

  Future<bool> replyPermission(String sessionId, String permissionId, String response) async =>
      asBool(await post('/session/$sessionId/permissions/$permissionId', body: {'response': response}));

  Future<bool> replyPermissionV1(String requestId, String reply, {String message = ''}) async =>
      asBool(await post('/permission/$requestId/reply', body: {'reply': reply, 'message': message}));

  // ---------------- messages ----------------

  /// Returns a flat list of (message, parts) pairs.
  /// Default [limit] keeps payloads small; pass `limit: null`-style bigger
  /// value only when you really need full history.
  Future<List<({Message info, List<Part> parts})>> messages(String id, {int? limit = 60}) async {
    final raw = asList(await get('/session/$id/message', q: {'limit': limit}));
    return raw.map((e) {
      final m = asMap(e);
      return (
        info: Message.fromJson(asMap(m['info'])),
        parts: asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
      );
    }).toList();
  }

  Future<List<Part>> message(String id, String messageId) async {
    final m = asMap(await get('/session/$id/message/$messageId'));
    return asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList();
  }

  Future<void> deleteMessage(String id, String messageId) =>
      delete('/session/$id/message/$messageId', timeout: const Duration(minutes: 2));

  /// Fire-and-forget prompt. Progress arrives over [events].
  Future<void> promptAsync(
    String sessionId, {
    required String providerId,
    required String modelId,
    required String agent,
    required List<Map<String, dynamic>> parts,
    Map<String, bool>? tools,
    String? system,
  }) async {
    await post('/session/$sessionId/prompt_async', body: {
      'model': {'providerID': providerId, 'modelID': modelId},
      'agent': agent,
      'parts': parts,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
      if (system != null && system.isNotEmpty) 'system': system,
    }, timeout: const Duration(seconds: 60));
  }

  /// Blocking prompt, returns the assistant reply. Avoid for chat UI: use [promptAsync].
  Future<({Message info, List<Part> parts})> prompt(
    String sessionId, {
    required String providerId,
    required String modelId,
    required String agent,
    required List<Map<String, dynamic>> parts,
    Map<String, bool>? tools,
  }) async {
    final m = asMap(await post('/session/$sessionId/message', body: {
      'model': {'providerID': providerId, 'modelID': modelId},
      'agent': agent,
      'parts': parts,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
    }, timeout: const Duration(minutes: 30)));
    return (
      info: Message.fromJson(asMap(m['info'])),
      parts: asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
    );
  }

  Future<({Message info, List<Part> parts})> runCommand(
    String sessionId, {
    required String command,
    String arguments = '',
    String? agent,
    String? providerId,
    String? modelId,
    List<Map<String, dynamic>>? parts,
  }) async {
    final m = asMap(await post('/session/$sessionId/command', body: {
      'command': command,
      'arguments': arguments,
      if (agent != null) 'agent': agent,
      if (modelId != null && providerId != null)
        'model': {'providerID': providerId, 'modelID': modelId},
      if (parts != null) 'parts': parts,
    }, timeout: const Duration(minutes: 30)));
    return (
      info: Message.fromJson(asMap(m['info'])),
      parts: asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
    );
  }

  /// Runs a shell command through the agent's shell tool. No LLM call.
  Future<({Message info, List<Part> parts})> shell(
    String sessionId, {
    required String command,
    String agent = 'build',
    String? providerId,
    String? modelId,
  }) async {
    final m = asMap(await post('/session/$sessionId/shell', body: {
      'command': command,
      'agent': agent,
      if (modelId != null && providerId != null)
        'model': {'providerID': providerId, 'modelID': modelId},
    }, timeout: const Duration(minutes: 10)));
    return (
      info: Message.fromJson(asMap(m['info'])),
      parts: asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
    );
  }

  // ---------------- commands / skills ----------------

  Future<List<CommandInfo>> commands() async =>
      asList(await get('/command')).map((e) => CommandInfo.fromJson(asMap(e))).toList();

  Future<List<SkillInfo>> skills() async =>
      asList(await get('/skill')).map((e) => SkillInfo.fromJson(asMap(e))).toList();

  Future<List<String>> toolIds() async => asList(await get('/experimental/tool/ids')).map((e) => e.toString()).toList();

  // ---------------- files ----------------

  Future<List<FileNode>> files(String path) async =>
      asList(await get('/file', q: {'path': path})).map((e) => FileNode.fromJson(asMap(e))).toList();

  Future<String> readFile(String path) async {
    final j = asMap(await get('/file/content', q: {'path': path}));
    return asStr(j['content'], asStr(j['text']));
  }

  Future<List<FileNode>> fileStatus() async =>
      asList(await get('/file/status')).map((e) => FileNode.fromJson(asMap(e))).toList();

  Future<List<String>> findFiles(String query, {String? type, String? directory, int limit = 100}) async =>
      asList(await get('/find/file',
              q: {'query': query, 'type': type, 'directory': directory, 'limit': limit}))
          .map((e) => e.toString())
          .toList();

  Future<List<Map<String, dynamic>>> grep(String pattern, {int limit = 100}) async {
    final j = await get('/find', q: {'pattern': pattern, 'limit': limit});
    if (j is List) return j.map(asMap).toList();
    return [asMap(j)];
  }

  Future<List<Map<String, dynamic>>> symbols(String query) async =>
      asList(await get('/find/symbol', q: {'query': query})).map(asMap).toList();

  // ---------------- vcs ----------------

  Future<String> vcsDiffRaw() async => await get('/vcs/diff/raw').then((e) => e?.toString() ?? '');

  Future<String> vcsDiff({String mode = 'worktree', int? context}) async =>
      await get('/vcs/diff', q: {'mode': mode, 'context': context}).then((e) => e?.toString() ?? '');

  Future<List<Map<String, dynamic>>> vcsStatus() async {
    final j = await get('/vcs/status');
    if (j is List) return j.map(asMap).toList();
    return [asMap(j)];
  }

  Future<bool> vcsApply(String patch) async =>
      asBool(await post('/vcs/apply', body: {'patch': patch}, timeout: const Duration(minutes: 2)));

  // ---------------- mcp / lsp / formatter ----------------

  Future<Map<String, NamedStatus>> mcp() async {
    final j = asMap(await get('/mcp'));
    return j.map((k, v) => MapEntry(k, NamedStatus.fromJson(k, asMap(v))));
  }

  Future<bool> mcpAdd(String name, Map<String, dynamic> config) async =>
      asBool(await post('/mcp', body: {'name': name, 'config': config}, timeout: const Duration(minutes: 2)));

  Future<bool> mcpConnect(String name) async =>
      asBool(await post('/mcp/$name/connect', timeout: const Duration(minutes: 2)));

  Future<bool> mcpDisconnect(String name) async =>
      asBool(await post('/mcp/$name/disconnect', timeout: const Duration(minutes: 2)));

  Future<List<NamedStatus>> lsp() async =>
      asList(await get('/lsp')).map((e) => NamedStatus.fromJson('', asMap(e))).toList();

  Future<List<NamedStatus>> formatters() async =>
      asList(await get('/formatter')).map((e) => NamedStatus.fromJson('', asMap(e))).toList();

  // ---------------- questions ----------------

  Future<List<Map<String, dynamic>>> pendingQuestions() async =>
      asList(await get('/question')).map(asMap).toList();

  Future<bool> answerQuestion(String requestId, List<List<String>> answers) async =>
      asBool(await post('/question/$requestId/reply', body: {'answers': answers}));

  Future<bool> rejectQuestion(String requestId) async =>
      asBool(await post('/question/$requestId/reject'));

  // ---------------- tui ----------------

  Future<void> tui(String action, [Map<String, dynamic>? body]) => post('/tui/$action', body: body ?? {});
}

class ProviderInfo {
  final List<ProviderEntry> all;
  final Map<String, String> defaults;
  final List<String> connected;
  const ProviderInfo({required this.all, required this.defaults, required this.connected});

  factory ProviderInfo.fromJson(Map<String, dynamic> j) {
    final def = <String, String>{};
    asMap(j['default']).forEach((k, v) => def[k] = v.toString());
    return ProviderInfo(
      all: asList(j['all']).map((e) => ProviderEntry.fromJson(asMap(e))).toList(),
      defaults: def,
      connected: asList(j['connected']).map((e) => e.toString()).toList(),
    );
  }

  bool get isConnected => connected.isNotEmpty;

  /// Every model grouped by provider, connected providers first.
  List<ProviderEntry> get ordered {
    final set = connected.toSet();
    final list = [...all]..sort((a, b) {
        final ac = set.contains(a.id) ? 0 : 1;
        final bc = set.contains(b.id) ? 0 : 1;
        if (ac != bc) return ac - bc;
        return a.id.compareTo(b.id);
      });
    return list.where((p) => p.models.isNotEmpty).toList();
  }
}

class ProviderEntry {
  final String id, name, source;
  final List<String> env;
  final List<ModelInfo> models;
  ProviderEntry({
    required this.id,
    required this.name,
    required this.source,
    required this.env,
    required this.models,
  });

  factory ProviderEntry.fromJson(Map<String, dynamic> j) {
    final out = <ModelInfo>[];
    asMap(j['models']).forEach((mid, mv) {
      final m = asMap(mv);
      final merged = {...m, 'providerID': asStr(j['id'])};
      out.add(ModelInfo.fromJson(asStr(j['id']), mid, merged));
    });
    return ProviderEntry(
      id: asStr(j['id']),
      name: asStr(j['name'], asStr(j['id'])),
      source: asStr(j['source']),
      env: asList(j['env']).map((e) => e.toString()).toList(),
      models: out,
    );
  }

  bool get needsKey => env.isNotEmpty && models.isNotEmpty;
}

class AuthMethod {
  final String provider, type, label;
  final String? link;
  const AuthMethod({
    required this.provider,
    required this.type,
    required this.label,
    this.link,
  });

  factory AuthMethod.from(String provider, Map<String, dynamic> j) => AuthMethod(
        provider: provider,
        type: asStr(j['type']),
        label: asStr(j['label'], asStr(j['type'])),
        link: j['link']?.toString(),
      );
}
