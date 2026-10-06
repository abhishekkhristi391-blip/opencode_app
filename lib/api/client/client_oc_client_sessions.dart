part of '../client.dart';

/// Sessions: CRUD, status, todos, fork/share, diff, init and revert.
///
/// Moved out of [OcClient] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcClient]; the only edit is that references to its statics read `OcClient.name`.
extension OcClientSessions on OcClient {
  // ---------------- sessions ----------------

  Future<List<Session>> sessions() async =>
      asList(await get('/session'))
          .map((e) => Session.fromJson(asMap(e)))
          .toList();

  Future<Session> createSession({
    String? title,
    String? parentId,
    String? agent,
    Map<String, String>? model,
  }) async => Session.fromJson(
    asMap(
      await post(
        '/session',
        body: {
          if (title != null) 'title': title,
          if (parentId != null) 'parentID': parentId,
          if (agent != null) 'agent': agent,
          if (model != null) 'model': model,
        },
      ),
    ),
  );

  Future<Session> session(String id) async =>
      Session.fromJson(asMap(await get('/session/$id')));

  Future<bool> deleteSession(String id) async =>
      asBool(await delete('/session/$id', timeout: const Duration(minutes: 2)));

  Future<Session> renameSession(String id, String title) async =>
      Session.fromJson(
        asMap(await patch('/session/$id', body: {'title': title})),
      );

  Future<List<Session>> childSessions(String id) async =>
      asList(await get('/session/$id/children'))
          .map((e) => Session.fromJson(asMap(e)))
          .toList();

  Future<Map<String, dynamic>> sessionStatus() async =>
      asMap(await get('/session/status'));

  Future<List<Todo>> todos(String id) async =>
      asList(await get('/session/$id/todo'))
          .map((e) => Todo.fromJson(asMap(e)))
          .toList();

  Future<bool> abort(String id) async => asBool(
    await post('/session/$id/abort', timeout: const Duration(minutes: 2)),
  );

  Future<Session> fork(String id, {String? messageId}) async =>
      Session.fromJson(
        asMap(await post('/session/$id/fork', body: {'messageID': messageId})),
      );

  Future<Session> share(String id) async => Session.fromJson(
    asMap(
      await post('/session/$id/share', timeout: const Duration(minutes: 2)),
    ),
  );

  Future<Session> unshare(String id) async => Session.fromJson(
    asMap(
      await delete('/session/$id/share', timeout: const Duration(minutes: 2)),
    ),
  );

  Future<List<FileDiff>> diff(String id, {String? messageId}) async =>
      asList(await get('/session/$id/diff', q: {'messageID': messageId}))
          .map((e) => FileDiff.fromJson(asMap(e)))
          .toList();

  Future<bool> init(
    String id, {
    required String messageId,
    required String providerId,
    required String modelId,
  }) async => asBool(
    await post(
      '/session/$id/init',
      body: {
        'messageID': messageId,
        'providerID': providerId,
        'modelID': modelId,
      },
      timeout: const Duration(minutes: 10),
    ),
  );

  Future<bool> summarize(
    String id, {
    required String providerId,
    required String modelId,
  }) async => asBool(
    await post(
      '/session/$id/summarize',
      body: {'providerID': providerId, 'modelID': modelId},
      timeout: const Duration(minutes: 10),
    ),
  );

  Future<Session> revert(
    String id, {
    required String messageId,
    String? partId,
  }) async => Session.fromJson(
    asMap(
      await post(
        '/session/$id/revert',
        body: {'messageID': messageId, if (partId != null) 'partID': partId},
      ),
    ),
  );

  Future<bool> unrevert(String id) async =>
      asBool(await post('/session/$id/unrevert'));
}
