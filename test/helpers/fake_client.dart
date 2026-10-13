import 'dart:async';

import 'package:opencode_chat/api/client.dart';
import 'package:opencode_chat/models/models.dart';

class FakeOcClient extends OcClient {
  FakeOcClient()
      : super(baseUrl: 'http://test.local', username: 'test', password: '');

  @override
  Future<List<Session>> sessions() async {
    return <Session>[];
  }

  @override
  Future<Map<String, dynamic>> sessionStatus() async {
    return <String, dynamic>{};
  }

  @override
  void close() {}
}
