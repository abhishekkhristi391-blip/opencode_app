import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
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

  String get sessionId =>
      asStr(properties['sessionID'], asStr(properties['session']));

  bool get isPermission =>
      type == 'permission.asked' ||
      type == 'permission.updated' ||
      type == 'permission.v2.asked';

  bool get isQuestion =>
      type == 'question.asked' || type == 'question.v2.asked';

  bool get isError => type == 'session.error' || type == 'error';
}

/// Long-lived SSE connection to the opencode server with automatic reconnect.
///
/// Fixes vs. the old version:
///  * watchdog: a silently dead socket (wifi switch, phone sleep, Termux
///    restart) is detected and reconnected instead of hanging forever
///  * backoff counter resets after a successful connect
///  * [reconnect] for app-resume, so streaming restarts instantly
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

  /// If nothing (not even a heartbeat) arrives for this long, assume the
  /// connection is dead and reconnect.
  static const _staleAfter = Duration(seconds: 75);

  StreamSubscription<String>? _sub;
  http.Client? _client;
  Timer? _retry;
  Timer? _watchdog;
  DateTime _lastData = DateTime.now();
  bool _stopped = false;
  int _attempt = 0;
  bool _connected = false;
  int _gen = 0; // guards against callbacks from an old connection

  bool get connected => _connected;

  String get root => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Future<void> start() async {
    _stopped = false;
    await _connect();
  }

  /// Drop the current connection and connect again right now (e.g. app resumed).
  void reconnect() {
    if (_stopped) return;
    _attempt = 0;
    _retry?.cancel();
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_stopped) return;
    await stop(keepStopped: false);
    if (_stopped) return;
    final gen = ++_gen;
    _client = http.Client();

    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (password.isNotEmpty)
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    };

    try {
      final req = http.Request('GET', Uri.parse('$root/event'))
        ..headers.addAll(headers)
        ..persistentConnection = true;
      final res = await _client!.send(req).timeout(const Duration(seconds: 20));
      if (gen != _gen || _stopped) return;

      if (res.statusCode != 200) {
        throw http.ClientException('HTTP ${res.statusCode}', req.url);
      }
      _attempt = 0; // FIX: successful connect resets the backoff
      _lastData = DateTime.now();
      _setConnected(true);

      _watchdog = Timer.periodic(const Duration(seconds: 15), (_) {
        if (gen != _gen) return;
        if (DateTime.now().difference(_lastData) > _staleAfter)
          _scheduleRetry();
      });

      var pending = '';
      _sub = res.stream
          .transform(utf8.decoder)
          .listen(
            (chunk) {
              if (gen != _gen) return;
              _lastData = DateTime.now();
              pending = (pending + chunk).replaceAll('\r\n', '\n');
              // SSE frames end at a blank line.
              while (true) {
                final idx = pending.indexOf('\n\n');
                if (idx == -1) break;
                final frame = pending.substring(0, idx);
                pending = pending.substring(idx + 2);
                _handleFrame(frame);
              }
            },
            onError: (_) {
              if (gen == _gen) _scheduleRetry();
            },
            onDone: () {
              if (gen == _gen) _scheduleRetry();
            },
            cancelOnError: true,
          );
    } catch (e) {
      if (gen == _gen) _scheduleRetry();
      debugPrint('EventStream connection error: $e');
    }
  }

  void _handleFrame(String frame) {
    if (frame.trim().isEmpty) return;
    final data = <String>[];
    for (final l in frame.split('\n')) {
      if (l.startsWith('data:')) data.add(l.substring(5).trimLeft());
      // `event:` / `id:` / `:comment` lines carry no payload we need.
    }
    if (data.isEmpty) return;
    final text = data.join('\n');
    if (text.isEmpty || text == '[DONE]') return;
    try {
      onEvent(OcEvent.fromJson(asMap(jsonDecode(text))));
    } catch (e) {
      debugPrint('EventStream frame parse error: $e');
    }
  }

  void _setConnected(bool v) {
    if (_connected == v) return;
    _connected = v;
    onStatus?.call(v);
  }

  void _scheduleRetry() {
    if (_stopped) return;
    _gen++; // invalidate callbacks of the connection being torn down
    _watchdog?.cancel();
    _watchdog = null;
    _setConnected(false);
    _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
    _attempt++;
    final delayMs = (1000 * (1 << (_attempt.clamp(1, 5) - 1))).clamp(
      1000,
      15000,
    );
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: delayMs), _connect);
  }

  Future<void> stop({bool keepStopped = true}) async {
    if (keepStopped) _stopped = true;
    _retry?.cancel();
    _retry = null;
    _watchdog?.cancel();
    _watchdog = null;
    await _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
    _setConnected(false);
  }
}
