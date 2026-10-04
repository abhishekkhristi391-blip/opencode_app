import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

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
/// Resilience contract:
///  * [stop] pauses and is reversible by [reconnect]; only [shutdown] is final
///  * the socket survives silence (a quiet server is not a dead socket)
///  * liveness is proven against `/global/health`, never inferred from silence
///  * `onStatus` emits exactly one `false` per outage and one `true` per
///    recovery, so the UI never shows a green dot over a dead stream nor a red
///    dot over a healthy server
class EventStream {
  final String baseUrl;
  final String username;
  final String password;
  final void Function(OcEvent) onEvent;
  final void Function(bool connected)? onStatus;

  /// Is a run in flight? Silence while busy means a dead stream; silence while
  /// idle just means there is nothing to say. Without this the watchdog cannot
  /// tell "agent is thinking" from "socket is gone".
  final bool Function()? isBusy;

  EventStream({
    required this.baseUrl,
    required this.username,
    required this.password,
    required this.onEvent,
    this.onStatus,
    this.isBusy,
  });

  /// Silence past this long makes the stream *suspect*, not dead. It must sit
  /// above any heartbeat gap the server may use and above the health-probe
  /// round trip, so a legitimately quiet stream is never torn down.
  static const _staleAfter = Duration(seconds: 90);

  /// Silence past this long *while a run is in flight* is treated as a dead
  /// stream even if the server answers the probe. A run always produces
  /// something — status changes, part updates, tokens — so a two-minute
  /// vacuum means events are being lost, which truncates answers. Set well
  /// above a long-but-quiet tool call (`sleep`, a build) so those do not cost a
  /// reconnect: a successful probe resets the window instead.
  static const _staleWhileBusy = Duration(seconds: 180);

  /// Cadence of the liveness check once the stream looks stale.
  static const _probeEvery = Duration(seconds: 15);

  /// Consecutive failed probes needed to declare the server gone. A busy CPU
  /// in Termux can drop one request; it should not cost us the connection.
  static const _probeFailures = 2;

  /// Socket timeouts. `idleTimeout` is the critical one: dart:io defaults to
  /// **15 seconds**, and it applies to a streamed response body, not just to
  /// pooled sockets. With the default, the SSE connection was killed by the
  /// Dart client itself every time the agent went quiet for 15s — a tool run,
  /// a model thinking, or a user just reading. Every one of those kills cost a
  /// full reconnect plus a history resync. Local loopback makes 10 minutes of
  /// silence free, and Android can freeze the process for far longer than that
  /// (it re-enters through [reconnect], not through silence).
  static const _connectTimeout = Duration(seconds: 10);
  static const _handshakeTimeout = Duration(seconds: 20);
  static const _socketIdle = Duration(minutes: 10);

  StreamSubscription<String>? _sub;
  http.Client? _client;
  HttpClient? _http;
  Timer? _retry;
  Timer? _watchdog;
  DateTime _lastData = DateTime.now();
  bool _stopped = false;
  bool _finished = false;
  int _attempt = 0;
  bool _connected = false;

  /// Whether an outage has already been reported to [onStatus].
  bool _downReported = false;
  int _gen = 0; // guards against callbacks from an old connection
  int _probeFails = 0;
  bool _probing = false;
  bool _connecting = false;

  bool get connected => _connected;

  /// Connected, or on its way there. The owner's reachability probe uses this
  /// so it does not kick a second connect into one that is already running.
  bool get live => _connected || _connecting;

  String get root => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Future<void> start() async {
    if (_finished) return;
    _stopped = false;
    await _connect();
  }

  /// Drop the current connection and connect again right now (e.g. app resumed).
  void reconnect() {
    if (_stopped || _finished) return;
    _attempt = 0;
    _retry?.cancel();
    _retry = null;
    // Emit the down edge even when we are already down, so the owner's
    // recovery path (resync on reconnect) always runs exactly once. It is a
    // no-op when nothing was connected.
    _markDown();
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_stopped || _finished) return;
    // Claim the generation *before* the first await. App resume, the retry
    // timer and a manual reconnect can all land here at once; with the claim
    // after the await, two of them each built a client, the second overwrote
    // the first field (leaking its socket with nobody left to cancel it) and
    // then orphaned the generation that owned it.
    final gen = ++_gen;
    await _teardown();
    if (_stopped || _finished || gen != _gen) return;

    final headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (password.isNotEmpty)
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    };

    final hc = HttpClient()
      ..connectionTimeout = _connectTimeout
      ..idleTimeout = _socketIdle;
    _http = hc;
    _client = IOClient(hc);
    _connecting = true;

    http.StreamedResponse res;
    try {
      final req = http.Request('GET', Uri.parse('$root/event'))
        ..headers.addAll(headers)
        ..persistentConnection = true;
      res = await _client!.send(req).timeout(_handshakeTimeout);
    } catch (e) {
      _connecting = false;
      if (gen == _gen) _scheduleRetry();
      debugPrint('EventStream connection error: $e');
      return;
    }

    if (gen != _gen || _stopped || _finished) {
      _connecting = false;
      // A newer connection won the race. Drain so the response body is
      // released instead of hanging on an open socket forever.
      unawaited(res.stream.drain<void>().catchError((_) {}));
      return;
    }

    if (res.statusCode != 200) {
      _connecting = false;
      // 401 after a password change, 404 on an older server. Retrying on a
      // capped backoff is still right: a Termux restart with the same config
      // recovers without the app having to be reopened.
      debugPrint('EventStream rejected: HTTP ${res.statusCode}');
      unawaited(res.stream.drain<void>().catchError((_) {}));
      _scheduleRetry();
      return;
    }

    _connecting = false;
    _attempt = 0; // a successful connect resets the backoff
    _lastData = DateTime.now();
    _probeFails = 0;
    _downReported = false;
    _setConnected(true);

    _watchdog = Timer.periodic(_probeEvery, (_) {
      if (gen != _gen) return;
      _checkLiveness(gen);
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
          onError: (Object e) {
            debugPrint('EventStream dropped: $e');
            if (gen == _gen) _scheduleRetry();
          },
          onDone: () {
            if (gen == _gen) _scheduleRetry();
          },
          cancelOnError: true,
        );
  }

  /// Silence alone is not evidence of death — a healthy server has nothing to
  /// send while the user reads or an agent runs a long tool. Only a failed
  /// probe (or silence during a run, where a token was due) is.
  void _checkLiveness(int gen) {
    if (gen != _gen || _stopped || !_connected) return;
    if (DateTime.now().difference(_lastData) <= _staleAfter) {
      _probeFails = 0;
      return;
    }
    unawaited(_probeLiveness(gen));
  }

  /// One cheap request on a *separate* socket: a pooled connection cannot be
  /// trusted to be the thing that broke, and reusing it would hide a wedged
  /// pool behind a healthy probe.
  Future<void> _probeLiveness(int gen) async {
    if (_probing) return;
    _probing = true;
    var ok = false;
    try {
      final hc = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4)
        ..idleTimeout = const Duration(seconds: 10);
      try {
        final req = await hc
            .getUrl(Uri.parse('$root/global/health'))
            .timeout(const Duration(seconds: 4));
        if (password.isNotEmpty) {
          req.headers.set(
            HttpHeaders.authorizationHeader,
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          );
        }
        final res = await req.close().timeout(const Duration(seconds: 6));
        ok = res.statusCode < 500;
        await res.drain<void>().timeout(
          const Duration(seconds: 3),
          onTimeout: () {},
        );
      } finally {
        hc.close(force: true);
      }
    } catch (e) {
      ok = false;
    } finally {
      _probing = false;
    }

    if (gen != _gen || _stopped || _finished) return;
    final busy = isBusy?.call() ?? false;
    if (ok) {
      _probeFails = 0;
      if (!busy) {
        // Server alive and nothing running: it is simply a quiet server. Do
        // not treat that as a failure, and do not let it cost a reconnect —
        // just push the next check a full window out.
        _lastData = DateTime.now();
        return;
      }
      // A run is in flight, so silence was expected to have been broken by
      // now. Only a long vacuum means the stream is dropping events.
      if (DateTime.now().difference(_lastData) >= _staleWhileBusy) {
        _scheduleRetry();
      }
      return;
    }
    // Termux is down or still booting: the stream cannot recover on its own.
    // A silent stream during a run is already conclusive, so it does not have
    // to spend the second confirmation tick.
    if (busy) _probeFails = _probeFailures;
    _probeFails++;
    if (_probeFails >= _probeFailures) {
      _scheduleRetry();
    } else {
      // Not conclusive yet — restart the quiet window rather than judging on
      // a single sample.
      _lastData = DateTime.now();
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

  /// Reports an outage exactly once per cycle. A plain `_setConnected(false)`
  /// was silent while the stream had never connected, so a UI that had already
  /// been told the server was reachable (a passing health check) kept showing a
  /// green dot while every reconnect attempt was failing in the background.
  void _markDown() {
    final was = _connected;
    _connected = false;
    _probeFails = 0;
    if (!was && _downReported) return;
    _downReported = true;
    onStatus?.call(false);
  }

  void _scheduleRetry() {
    if (_stopped || _finished) return;
    _gen++; // invalidate callbacks of the connection being torn down
    _watchdog?.cancel();
    _watchdog = null;
    _markDown();
    _connecting = false;
    // Deliberately not awaited: this runs from inside the stream's own onDone /
    // onError callback, and every further trigger (watchdog, resume, error)
    // lands here idempotently through the `_gen` bump above.
    unawaited(_sub?.cancel());
    _sub = null;
    _client?.close();
    _client = null;
    _http?.close(force: true);
    _http = null;
    _attempt++;
    final delayMs = (1000 * (1 << (_attempt.clamp(1, 5) - 1))).clamp(
      1000,
      15000,
    );
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: delayMs), _connect);
  }

  /// Releases the socket and every timer, leaving [reconnect] able to revive
  /// the stream. Used when the app goes to the background.
  Future<void> stop() async {
    _gen++;
    await _teardown();
    // Silent: pausing is our own decision, not an outage, so the owner's
    // "is the server reachable" probe must not fire on every app switch.
    _connected = false;
    _downReported = true;
    _attempt = 0;
  }

  /// Final teardown. [reconnect] refuses afterwards, so a late lifecycle
  /// callback cannot resurrect a stream into a disposed store.
  Future<void> shutdown() async {
    _finished = true;
    _stopped = true;
    _gen++;
    await _teardown();
    _connected = false;
    _downReported = true;
  }

  Future<void> _teardown() async {
    _retry?.cancel();
    _retry = null;
    _watchdog?.cancel();
    _watchdog = null;
    _connecting = false;
    // Detach the fields before awaiting so a concurrent teardown cannot double
    // cancel, and so nothing can observe a half-closed client as live.
    final sub = _sub;
    final client = _client;
    final hc = _http;
    _sub = null;
    _client = null;
    _http = null;
    await sub?.cancel();
    client?.close();
    hc?.close(force: true);
  }
}
