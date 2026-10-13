import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/db/chat_db.dart';
import 'package:opencode_chat/models/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('ChatDB basic operations', () {
    test('open, write and read session/messages', () async {
      final db = ChatDB.instance;
      // Clear existing data for a clean test
      await db.clearAll();

      final session = Session.fromJson({
        'id': 'test-session-1',
        'title': 'Test',
        'time': {'created': 1000},
        'version': '1',
      });

      await db.writeSession(session);

      final msg = Message.fromJson({
        'id': 'm1',
        'role': 'user',
        'sessionID': 'test-session-1',
        'time': {'created': 2000},
        'info': {
          'time': {'created': 2000}
        }
      });
      msg.content = 'hello world';

      await db.writeMessage(msg, 'test-session-1');

      final sessions = await db.sessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'test-session-1');

      final messages = await db.messages('test-session-1');
      expect(messages.length, 1);
      expect(messages.first.id, 'm1');
      expect(messages.first.content, 'hello world');

      await db.clearAll();
    });

    test('clearAll empties tables', () async {
      await ChatDB.instance.clearAll();
      final sessions = await ChatDB.instance.sessions();
      expect(sessions, isEmpty);
    });
  });
}
