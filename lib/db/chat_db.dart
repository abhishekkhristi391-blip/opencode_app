import 'dart:async';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Local chat history cache.
///
/// The server is the source of truth; this only exists so a session opens with
/// its history already on screen (and stays readable with the server down).
///
/// Two rules keep the cache trustworthy:
///
/// * **Ordering is taken from the server's own `info.time.created`**, never from
///   write time. Writing `DateTime.now()` used to collapse every timestamp in a
///   session to "now" on each rewrite, which made `ORDER BY` return the
///   messages in arbitrary order on the next load.
/// * **Writes are serialised through [_queue].** Streaming fires a write per
///   token; running them concurrently let a stale snapshot commit *after* a
///   newer one and silently roll the cached text back.
class ChatDB {
  static final ChatDB instance = ChatDB._();
  ChatDB._();

  Database? _db;
  Future<Database>? _opening;

  /// Tail of the write chain. Every mutation is appended to it.
  Future<void> _queue = Future<void>.value();

  /// Monotonic fallback for messages the server gave no `created` for, so they
  /// still sort after whatever is already stored instead of jumping to 1970.
  int _seq = DateTime.now().millisecondsSinceEpoch;

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;
    // Guard against two concurrent callers each opening the file.
    return _opening ??= _init();
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/opencode_chat.db';
    final opened = await openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await _createMessages(db);
        await _createSessions(db);
      },
      onUpgrade: (db, old, _) async {
        // v1 stored write-time in `created_at`, so its rows are already in an
        // arbitrary order and cannot be repaired without re-reading every
        // `data` blob. Drop it; the next open repopulates from the server.
        if (old < 2) await db.execute('DROP TABLE IF EXISTS messages');
        await _createMessages(db);
        await _createSessions(db);
      },
    );
    _db = opened;
    return opened;
  }

  Future<void> _createMessages(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages(
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_session '
      'ON messages(session_id, created_at)',
    );
  }

  Future<void> _createSessions(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions(
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_updated ON sessions(updated_at)',
    );
  }

  /// Runs [op] after every previously queued write, so writes never interleave.
  Future<T> _enqueue<T>(Future<T> Function() op) {
    final done = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        done.complete(await op());
      } catch (e, st) {
        // A failed write must not poison the chain for every later one.
        done.completeError(e, st);
      }
    });
    return done.future;
  }

  int _sortKey(Map<String, dynamic> row) {
    final info = row['info'];
    if (info is Map) {
      final time = info['time'];
      final created = time is Map ? time['created'] : null;
      if (created is int && created > 0) return created;
      if (created is num && created.toInt() > 0) return created.toInt();
    }
    return ++_seq;
  }

  bool _writeRow(Batch batch, String sessionId, Map<String, dynamic> row) {
    final info = row['info'];
    final id = info is Map ? info['id'] : null;
    if (id is! String || id.isEmpty) return false;
    batch.insert('messages', {
      'id': id,
      'session_id': sessionId,
      'data': jsonEncode(row),
      'created_at': _sortKey(row),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  /// Stores a batch of messages, preserving their server ordering.
  Future<void> upsertMessages(
    String sessionId,
    List<Map<String, dynamic>> rows,
  ) {
    if (rows.isEmpty) return Future<void>.value();
    return _enqueue(() async {
      final d = await db;
      final batch = d.batch();
      var n = 0;
      for (final row in rows) {
        if (_writeRow(batch, sessionId, row)) n++;
      }
      if (n == 0) return;
      await batch.commit(noResult: true);
    });
  }

  /// Deletes one message. Streaming edits a single message at a time, so the
  /// cache has to be able to drop one without rewriting the session.
  Future<void> deleteMessage(String sessionId, String messageId) {
    if (messageId.isEmpty) return Future<void>.value();
    return _enqueue(() async {
      final d = await db;
      await d.delete(
        'messages',
        where: 'session_id=? AND id=?',
        whereArgs: [sessionId, messageId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> loadMessages(
    String sessionId, {
    int limit = 500,
  }) {
    return _enqueue(() async {
      final d = await db;
      final res = await d.query(
        'messages',
        where: 'session_id=?',
        whereArgs: [sessionId],
        // rowid breaks ties between messages sharing a timestamp, and follows
        // insertion order within a session.
        orderBy: 'created_at ASC, rowid ASC',
        limit: limit,
      );
      return res
          .map((e) => jsonDecode(e['data'] as String) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> clearSession(String sessionId) {
    return _enqueue(() async {
      final d = await db;
      await d.delete('messages', where: 'session_id=?', whereArgs: [sessionId]);
    });
  }

  // ---------- session list (makes history reachable with the server down) ----------

  /// [rows] are `{'id': String, 'raw': Map<String, dynamic>, 'updated': int}`.
  Future<void> saveSessions(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return Future<void>.value();
    return _enqueue(() async {
      final d = await db;
      final batch = d.batch();
      for (final r in rows) {
        final id = r['id'];
        if (id is! String || id.isEmpty) continue;
        batch.insert('sessions', {
          'id': id,
          'data': jsonEncode(r['raw']),
          'updated_at': r['updated'] is int ? r['updated'] as int : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> saveSession(String id, Map<String, dynamic> raw, int updated) =>
      saveSessions([
        {'id': id, 'raw': raw, 'updated': updated},
      ]);

  Future<void> deleteSessionRow(String sessionId) {
    return _enqueue(() async {
      final d = await db;
      await d.delete('sessions', where: 'id=?', whereArgs: [sessionId]);
    });
  }

  /// Returns session payloads newest-first, as stored.
  Future<List<Map<String, dynamic>>> loadSessions() {
    return _enqueue(() async {
      final d = await db;
      final res = await d.query('sessions', orderBy: 'updated_at DESC');
      return res
          .map((e) => jsonDecode(e['data'] as String) as Map<String, dynamic>)
          .toList();
    });
  }
}
