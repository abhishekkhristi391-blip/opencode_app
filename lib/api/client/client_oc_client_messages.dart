part of '../client.dart';

/// Permission replies, messages, prompts, commands and shell.
///
/// Moved out of [OcClient] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcClient]; the only edit is that references to its statics read `OcClient.name`.
extension OcClientMessages on OcClient {
  Future<bool> replyPermission(
    String sessionId,
    String permissionId,
    String response,
  ) async => asBool(
    await post(
      '/session/$sessionId/permissions/$permissionId',
      body: {'response': response},
    ),
  );

  Future<bool> replyPermissionV1(
    String requestId,
    String reply, {
    String message = '',
  }) async => asBool(
    await post(
      '/permission/$requestId/reply',
      body: {'reply': reply, 'message': message},
    ),
  );

  // ---------------- messages ----------------

  /// Returns a flat list of (message, parts) pairs.
  /// Default [limit] keeps payloads small; pass `limit: null`-style bigger
  /// value only when you really need full history.
  /// [before] loads messages older than the given message ID.
  Future<List<({Message info, List<Part> parts})>> messages(
    String id, {
    int? limit = 60,
    String? before,
  }) async {
    final q = <String, dynamic>{'limit': limit};
    if (before != null) q['before'] = before;
    final raw = asList(await get('/session/$id/message', q: q));
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

  Future<void> deleteMessage(String id, String messageId) => delete(
    '/session/$id/message/$messageId',
    timeout: const Duration(minutes: 2),
  );

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
    await post(
      '/session/$sessionId/prompt_async',
      body: {
        'model': {'providerID': providerId, 'modelID': modelId},
        'agent': agent,
        'parts': parts,
        if (tools != null && tools.isNotEmpty) 'tools': tools,
        if (system != null && system.isNotEmpty) 'system': system,
      },
      timeout: const Duration(seconds: 60),
    );
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
    final m = asMap(
      await post(
        '/session/$sessionId/message',
        body: {
          'model': {'providerID': providerId, 'modelID': modelId},
          'agent': agent,
          'parts': parts,
          if (tools != null && tools.isNotEmpty) 'tools': tools,
        },
        timeout: const Duration(minutes: 30),
      ),
    );
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
    final m = asMap(
      await post(
        '/session/$sessionId/command',
        body: {
          'command': command,
          'arguments': arguments,
          if (agent != null) 'agent': agent,
          if (modelId != null && providerId != null)
            'model': {'providerID': providerId, 'modelID': modelId},
          if (parts != null) 'parts': parts,
        },
        timeout: const Duration(minutes: 30),
      ),
    );
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
    final m = asMap(
      await post(
        '/session/$sessionId/shell',
        body: {
          'command': command,
          'agent': agent,
          if (modelId != null && providerId != null)
            'model': {'providerID': providerId, 'modelID': modelId},
        },
        timeout: const Duration(minutes: 10),
      ),
    );
    return (
      info: Message.fromJson(asMap(m['info'])),
      parts: asList(m['parts']).map((p) => Part.fromJson(asMap(p))).toList(),
    );
  }
}
