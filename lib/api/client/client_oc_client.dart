part of '../client.dart';

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
dynamic _parseBytes(Uint8List b) =>
    jsonDecode(utf8.decode(b, allowMalformed: true));

/// Bodies bigger than this are parsed off the UI thread.
const _isolateThreshold = 32 * 1024;

// The fields and constructor of OcClient live here. The endpoint
// methods are split by topic into the OcClient* extensions in client_oc_client_<topic>.dart.
/// Thin typed wrapper over the opencode HTTP server.
class OcClient {
  String baseUrl;
  String username;
  String password;

  OcClient({
    this.baseUrl = 'http://127.0.0.1:4096',
    this.username = 'opencode',
    this.password = '',
  });

  // Fast connect timeout + keep-alive so repeated calls reuse the socket.
  final http.Client _client = IOClient(
    HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(minutes: 2),
  );
}
