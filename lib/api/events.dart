import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// A decoded server-sent event from `GET /event`.
class OcEvent {
  final String type;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> raw;
  OcEvent(this.type, this.properties, this.raw);

  factory OcEvent.fromJson(Map<String, dynamic> j) {
    var props = asMap(j['properties']);
    // Some event families nest the payload one level deeper under `properties`.
    if (props.isEmpty) props = asMap(j['properties'] ?? j['info']);
    return OcEvent(asStr(j['type']), props, j);
  }

  String get sessionId => asStr(properties['sessionID'], asStr(properties['session']));

  bool get isPermission =>
      type == 'permission.asked' || type == 'permission.updated' || type == 'permission.v2.asked';

  bool get isQuestion => type == 'question.asked' || type == 'question.v2.asked';

  bool get isError => type == 'session.error' || type == 'error';
}

/// Long-lived SSE connection to the opencode server with automatic reconnect.
class EventStream {
  final String baseUrl;
  final String username;
  final String password;
  final void Function(OcEvent) onEvent;
  final void Function(bool connected)? onStatus;

  EventStream({
    required this.baseUrl,
    required this.username,
    required this.password,
    required this.onEvent,
    this.onStatus,
  });

  StreamSubscription<String>? _sub;
  http.Client? _client;
  Timer? _retry;
  bool _stopped = false;
  int _attempt = 0;
  bool _connected = false;

  bool get connected => _connected;

  String get root => baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Future<void> start() async {
    _stopped = false;
    await _connect();
  }

  Future<void> _connect() async {
    if (_stopped) return;
    await stop(keepStopped: false);
    _client = http.Client();

    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (password.isNotEmpty)
        'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    };

    try {
      final req = http.Request('GET', Uri.parse('$root/event'))
        ..headers.addAll(headers)
        ..persistentConnection = true;
      final res = await _client!.send(req).timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        throw http.ClientException('HTTP ${res.statusCode}', req.url);
      }
      _setConnected(true);

      final buf = StringBuffer();
      _sub = res.stream.transform(utf8.decoder).listen(
        (chunk) {
          buf.write(chunk);
          var s = buf.toString();
          while (true) {
            // SSE frames end at a blank line: "\n\n" or "\r\n\r\n".
            final lf = s.indexOf('\n\n');
            final crlf = s.indexOf('\r\n\r\n');
            int idx, skip;
            if (lf == -1 && crlf == -1) {
              break;
            } else if (crlf != -1 && (lf == -1 || crlf < lf)) {
              idx = crlf;
              skip = 4;
            } else {
              idx = lf;
              skip = 2;
            }
            final frame = s.substring(0, idx);
            s = s.substring(idx + skip);
            _handleFrame(frame);
          }
          buf
            ..clear()
            ..write(s);
        },
        onError: (_) => _scheduleRetry(),
        onDone: _scheduleRetry,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleRetry();
    }
  }

  void _handleFrame(String frame) {
    if (frame.trim().isEmpty) return;
    final lines = frame.split(RegExp(r'\r?\n'));
    final data = <String>[];
    for (final l in lines) {
      if (l.startsWith('data:')) data.add(l.substring(5).trimLeft());
      // `event:` / `id:` lines carry no payload we need; opencode puts the
      // event type inside the JSON body.
    }
    if (data.isEmpty) return;
    final text = data.join('\n');
    if (text.isEmpty || text == '[DONE]') return;
    try {
      onEvent(OcEvent.fromJson(asMap(jsonDecode(text))));
    } catch (_) {
      // Ignore malformed frames rather than killing the stream.
    }
  }

  void _setConnected(bool v) {
    if (_connected == v) return;
    _connected = v;
    onStatus?.call(v);
  }

  void _scheduleRetry() {
    if (_stopped) return;
    _setConnected(false);
    _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
    _attempt++;
    final delayMs = (1000 * (1 << (_attempt.clamp(1, 5) - 1))).clamp(1000, 15000);
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: delayMs), _connect);
  }

  Future<void> stop({bool keepStopped = true}) async {
    if (keepStopped) _stopped = true;
    _retry?.cancel();
    _retry = null;
    await _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
    _setConnected(false);
  }
}
