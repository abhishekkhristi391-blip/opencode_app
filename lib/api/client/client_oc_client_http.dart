part of '../client.dart';

/// HTTP plumbing: base URL, headers, retrying send, and the verb helpers.
///
/// Moved out of [OcClient] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcClient]; the only edit is that references to its statics read `OcClient.name`.
extension OcClientHttp on OcClient {
  String get root => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Map<String, String> _headers({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (password.isNotEmpty)
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$username:$password'))}',
  };

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final qs = <String, String>{};
    q?.forEach((k, v) {
      if (v == null) return;
      final s = v is List ? v.join(',') : v.toString();
      if (s.isEmpty) return;
      qs[k] = s;
    });
    return Uri.parse('$root$path')
        .replace(queryParameters: qs.isEmpty ? null : qs);
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
        } catch (e) {
          if (kDebugMode) debugPrint('Isolate JSON parse failed: $e');
          body = utf8.decode(bytes, allowMalformed: true);
        }
      } else {
        text = utf8.decode(bytes, allowMalformed: true);
        try {
          body = jsonDecode(text);
        } catch (e) {
          if (kDebugMode) debugPrint('JSON decode failed: $e');
          body = text;
        }
      }
    }

    if (r.statusCode >= 400) {
      if (text.isEmpty && bytes.isNotEmpty)
        text = utf8.decode(bytes, allowMalformed: true);
      if (body is Map && body['name'] != null && body['data'] != null) {
        throw ApiException(
          r.statusCode,
          body['name'].toString(),
          asMap(body['data'])['message']?.toString() ?? text,
        );
      }
      throw ApiException(
        r.statusCode,
        'HTTP ${r.statusCode}',
        text.isEmpty ? 'HTTP ${r.statusCode}' : text,
      );
    }
    return body;
  }

  Future<dynamic> _sendOnce(
    Future<http.Response> Function() run,
    Duration timeout,
  ) async {
    try {
      final r = await run().timeout(timeout);
      return await _decode(r);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(0, 'Timeout', S.netTimeout(timeout.inSeconds));
    } on SocketException {
      throw ApiException(0, 'NoConnection', S.netUnreachable(root));
    } on TlsException {
      // Listed before HandshakeException: it is a subtype, so the other order
      // would make this branch unreachable.
      throw ApiException(
        0,
        'BadProtocol',
        'Could not verify the server certificate.\n\nCheck the URL for $root.',
      );
    } on HandshakeException catch (e) {
      // https:// against a plain http server, or a hostname that resolves
      // somewhere unexpected. Without this it escaped as a raw exception and
      // every caller that only catches ApiException printed a stack trace.
      debugPrint('TLS handshake failed: ${e.message}');
      throw ApiException(
        0,
        'BadProtocol',
        'Could not open a secure connection.\n\n'
            'Check the URL and protocol (http/https) for $root.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network', e.message);
    } on FormatException {
      throw ApiException(0, 'BadResponse', 'Could not read the server reply');
    }
  }

  /// Sends [run], mapping every transport failure onto an [ApiException].
  ///
  /// [idempotent] buys one transparent retry: this client pools keep-alive
  /// sockets, and a Termux restart (or a server-side idle reap) closes them
  /// while they sit in the pool. The next request then fails on a socket that
  /// was already dead when the call started, so every call after a server
  /// restart failed until the pool aged out. Reads are safe to repeat, so one
  /// fresh-socket attempt turns that into a non-event. Deliberately *not*
  /// retried on a timeout: a 30s agent turn must not silently become 60s.
  Future<dynamic> _send(
    Future<http.Response> Function() run,
    Duration timeout, {
    bool idempotent = false,
  }) async {
    try {
      return await _sendOnce(run, timeout);
    } on ApiException catch (e) {
      final transport = e.name == 'NoConnection' || e.name == 'Network';
      if (!idempotent || !transport) rethrow;
      if (kDebugMode) debugPrint('retrying once over a fresh socket: $e');
      await Future.delayed(const Duration(milliseconds: 250));
      return _sendOnce(run, timeout);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? q,
    Duration? timeout,
  }) => _send(
    () => _client.get(_u(path, q), headers: _headers()),
    timeout ?? const Duration(seconds: 30),
    idempotent: true,
  );

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? q,
    Duration? timeout,
  }) => _send(
    () => _client.post(
      _u(path, q),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    ),
    timeout ?? const Duration(seconds: 30),
  );

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? q,
    Duration? timeout,
  }) => _send(
    () => _client.patch(
      _u(path, q),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    ),
    timeout ?? const Duration(seconds: 30),
  );

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? q,
    Duration? timeout,
  }) => _send(
    () => _client.put(
      _u(path, q),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    ),
    timeout ?? const Duration(seconds: 30),
  );

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? q,
    Duration? timeout,
  }) => _send(
    () => _client.delete(
      _u(path, q),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    ),
    timeout ?? const Duration(seconds: 30),
  );

  void close() => _client.close();
}
