import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatDB {
  static final ChatDB instance = ChatDB._();
  ChatDB._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/opencode_chat.db';
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE messages(
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          data TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_messages_session ON messages(session_id, created_at)');
    });
  }

  Future<void> upsertMessage(String sessionId, Map<String, dynamic> data) async {
    final d = await db;
    final id = data['info']?['id'] as String?;
    if (id == null) return;
    await d.insert('messages', {
      'id': id,
      'session_id': sessionId,
      'data': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertMessages(String sessionId, List<Map<String, dynamic>> list) async {
    final d = await db;
    final batch = d.batch();
    for (final data in list) {
      final id = data['info']?['id'] as String?;
      if (id == null) continue;
      batch.insert('messages', {
        'id': id,
        'session_id': sessionId,
        'data': jsonEncode(data),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> loadMessages(String sessionId, {int limit = 200}) async {
    final d = await db;
    final res = await d.query('messages', where: 'session_id=?', whereArgs: [sessionId], orderBy: 'created_at ASC', limit: limit);
    return res.map((e) => jsonDecode(e['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> clearSession(String sessionId) async {
    final d = await db;
    await d.delete('messages', where: 'session_id=?', whereArgs: [sessionId]);
  }
}
