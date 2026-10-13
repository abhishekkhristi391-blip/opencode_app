import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/models/models.dart';

void main() {
  group('JSON parsing helpers', () {
    test('asMap/asList/asStr/asInt handle basic cases', () {
      expect(asMap({'a': 1}), {'a': 1});
      expect(asMap(null), {});
      expect(asMap(<dynamic, dynamic>{}), {});

      expect(asList([1, 2, 3]), [1, 2, 3]);
      expect(asList(null), []);
      expect(asList(<dynamic>[]), []);

      expect(asStr('hi'), 'hi');
      expect(asStr(null), '');
      expect(asStr(123), '123');

      expect(asInt(5), 5);
      expect(asInt('10'), 10);
      expect(asInt(null), 0);
      expect(asInt(5.6), 5);

      expect(asBool(true), true);
      expect(asBool(false), false);
      expect(asBool(null), false);
      expect(asBool(''), false);
      // asBool accepts only a real bool; every non-bool falls back to the
      // default (false). Unlike asInt/asStr it does not coerce numbers or
      // strings, because the server always sends real JSON booleans.
      expect(asBool(1), false);
      expect(asBool('true'), false);
      expect(asBool('yes'), false);
    });

    test('ModelInfo basic fields', () {
      final m = ModelInfo.fromJson('test', 'model', {
        'id': 'm1',
        'name': 'test/model',
        'family': 'test-family',
        'capabilities': {'reasoning': true, 'attachment': true},
        'limit': {'context': 1000, 'output': 500},
      });
      expect(m.name, 'test/model');
      expect(m.providerId, 'test');
      expect(m.contextLimit, 1000);
    });

    test('Session from minimal JSON', () {
      final s = Session.fromJson({
        'id': 's1',
        'title': 'hello',
        'time': {'created': 1000000},
        'version': '1',
        'messages': 0,
        'index': 0,
        'tokens': {'input': 0, 'output': 0, 'reasoning': 0, 'cache': 0, 'total': 0},
      });
      expect(s.id, 's1');
      expect(s.title, 'hello');
      expect(s.created, 1000000);
    });
  });
}
