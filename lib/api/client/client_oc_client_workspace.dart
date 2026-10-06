part of '../client.dart';

/// Commands/skills, files, VCS, MCP, LSP, pending prompts and the TUI.
///
/// Moved out of [OcClient] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcClient]; the only edit is that references to its statics read `OcClient.name`.
extension OcClientWorkspace on OcClient {
  // ---------------- commands / skills ----------------

  Future<List<CommandInfo>> commands() async =>
      asList(await get('/command'))
          .map((e) => CommandInfo.fromJson(asMap(e)))
          .toList();

  Future<List<SkillInfo>> skills() async =>
      asList(await get('/skill'))
          .map((e) => SkillInfo.fromJson(asMap(e)))
          .toList();

  Future<List<String>> toolIds() async =>
      asList(await get('/experimental/tool/ids'))
          .map((e) => e.toString())
          .toList();

  // ---------------- files ----------------

  Future<List<FileNode>> files(String path) async =>
      asList(await get('/file', q: {'path': path}))
          .map((e) => FileNode.fromJson(asMap(e)))
          .toList();

  Future<String> readFile(String path) async {
    final j = asMap(await get('/file/content', q: {'path': path}));
    return asStr(j['content'], asStr(j['text']));
  }

  Future<List<FileNode>> fileStatus() async =>
      asList(await get('/file/status'))
          .map((e) => FileNode.fromJson(asMap(e)))
          .toList();

  Future<List<String>> findFiles(
    String query, {
    String? type,
    String? directory,
    int limit = 100,
  }) async => asList(
    await get(
      '/find/file',
      q: {'query': query, 'type': type, 'directory': directory, 'limit': limit},
    ),
  ).map((e) => e.toString()).toList();

  Future<List<Map<String, dynamic>>> grep(
    String pattern, {
    int limit = 100,
  }) async {
    final j = await get('/find', q: {'pattern': pattern, 'limit': limit});
    if (j is List) return j.map(asMap).toList();
    return [asMap(j)];
  }

  Future<List<Map<String, dynamic>>> symbols(String query) async =>
      asList(await get('/find/symbol', q: {'query': query}))
          .map(asMap)
          .toList();

  // ---------------- vcs ----------------

  Future<String> vcsDiffRaw() async =>
      await get('/vcs/diff/raw').then((e) => e?.toString() ?? '');

  Future<String> vcsDiff({String mode = 'worktree', int? context}) async =>
      await get(
        '/vcs/diff',
        q: {'mode': mode, 'context': context},
      ).then((e) => e?.toString() ?? '');

  Future<List<Map<String, dynamic>>> vcsStatus() async {
    final j = await get('/vcs/status');
    if (j is List) return j.map(asMap).toList();
    return [asMap(j)];
  }

  Future<bool> vcsApply(String patch) async => asBool(
    await post(
      '/vcs/apply',
      body: {'patch': patch},
      timeout: const Duration(minutes: 2),
    ),
  );

  // ---------------- mcp / lsp / formatter ----------------

  Future<Map<String, NamedStatus>> mcp() async {
    final j = asMap(await get('/mcp'));
    return j.map((k, v) => MapEntry(k, NamedStatus.fromJson(k, asMap(v))));
  }

  Future<bool> mcpAdd(String name, Map<String, dynamic> config) async => asBool(
    await post(
      '/mcp',
      body: {'name': name, 'config': config},
      timeout: const Duration(minutes: 2),
    ),
  );

  Future<bool> mcpConnect(String name) async => asBool(
    await post('/mcp/$name/connect', timeout: const Duration(minutes: 2)),
  );

  Future<bool> mcpDisconnect(String name) async => asBool(
    await post('/mcp/$name/disconnect', timeout: const Duration(minutes: 2)),
  );

  Future<List<NamedStatus>> lsp() async =>
      asList(await get('/lsp'))
          .map((e) => NamedStatus.fromJson('', asMap(e)))
          .toList();

  Future<List<NamedStatus>> formatters() async =>
      asList(await get('/formatter'))
          .map((e) => NamedStatus.fromJson('', asMap(e)))
          .toList();

  // ---------------- questions / permissions ----------------

  Future<List<Map<String, dynamic>>> pendingQuestions() async =>
      asList(await get('/question')).map(asMap).toList();

  Future<List<Map<String, dynamic>>> pendingPermissions() async =>
      asList(await get('/permission')).map(asMap).toList();

  Future<bool> answerQuestion(
    String requestId,
    List<List<String>> answers,
  ) async => asBool(
    await post('/question/$requestId/reply', body: {'answers': answers}),
  );

  Future<bool> rejectQuestion(String requestId) async =>
      asBool(await post('/question/$requestId/reject'));

  // ---------------- tui ----------------

  Future<void> tui(String action, [Map<String, dynamic>? body]) =>
      post('/tui/$action', body: body ?? {});
}
