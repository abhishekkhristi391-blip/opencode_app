part of '../client.dart';

/// Server info, config, providers and auth, and agents.
///
/// Moved out of [OcClient] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcClient]; the only edit is that references to its statics read `OcClient.name`.
extension OcClientServer on OcClient {
  // ---------------- global ----------------

  Future<({bool healthy, String version})> health() async {
    final j = asMap(await get('/global/health'));
    return (healthy: asBool(j['healthy']), version: asStr(j['version']));
  }

  Future<ServerPaths> paths() async =>
      ServerPaths.fromJson(asMap(await get('/path')));

  Future<VcsInfo> vcs() async => VcsInfo.fromJson(asMap(await get('/vcs')));

  Future<void> disposeInstance() =>
      post('/instance/dispose', timeout: const Duration(seconds: 60));

  Future<bool> upgrade() async => asBool(
    await post('/global/upgrade', timeout: const Duration(minutes: 5)),
  );

  Future<bool> log(String service, String level, String message) async =>
      asBool(
        await post(
          '/log',
          body: {'service': service, 'level': level, 'message': message},
        ),
      );

  // ---------------- config ----------------

  Future<Map<String, dynamic>> config() async => asMap(await get('/config'));

  Future<Map<String, dynamic>> patchConfig(Map<String, dynamic> values) async =>
      asMap(await patch('/config', body: values));

  Future<List<ProviderEntry>> configProviders() async {
    final j = asMap(await get('/config/providers'));
    return asList(j['providers'])
        .map((e) => ProviderEntry.fromJson(asMap(e)))
        .toList();
  }

  // ---------------- providers / models ----------------

  Future<ProviderInfo> providers() async =>
      ProviderInfo.fromJson(asMap(await get('/provider')));

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

  Future<Map<String, dynamic>> providerAuthUrl(
    String providerId, {
    String? callbackUrl,
  }) async => asMap(
    await post(
      '/provider/$providerId/oauth/authorize',
      body: {
        'callbackUrl': callbackUrl ?? 'http://localhost:8976/oauth/callback',
      },
    ),
  );

  Future<bool> setApiKey(String providerId, String key) async => asBool(
    await put(
      '/auth/$providerId',
      body: {'type': 'api', 'key': key},
      timeout: const Duration(minutes: 2),
    ),
  );

  Future<void> removeAuth(String providerId) => delete('/auth/$providerId');

  // ---------------- agents ----------------

  Future<List<Agent>> agents() async =>
      asList(await get('/agent')).map((e) => Agent.fromJson(asMap(e))).toList();
}
