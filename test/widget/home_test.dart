import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/main.dart';
import 'package:opencode_chat/state/store.dart';
import 'package:opencode_chat/api/client.dart';

import '../helpers/fake_client.dart';

void main() {
  testWidgets('HomeShell renders basic structure', (WidgetTester tester) async {
    // Override with fake client via AppScope if needed - basic smoke test
    await tester.pumpWidget(const OpenCodeApp());
    await tester.pumpAndSettle();

    // App should render
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
