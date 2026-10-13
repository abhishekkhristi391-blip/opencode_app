import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/ui/primitives.dart';
import 'package:opencode_chat/ui/theme.dart';

void main() {
  // NOTE: this is deliberately a leaf-widget smoke test. Pumping the whole app
  // (`OpenCodeApp`) is not testable under `flutter test`: its boot path needs
  // plugins (shared_preferences, path_provider) that are not registered in the
  // test environment, and it opens a live network connection. Both surface as
  // unhandled errors / pending timers and fail the suite, which is why the
  // earlier full-app smoke test never went green.
  testWidgets('OCButton renders its label and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: OCButton(
              label: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('buildAppTheme returns a dark ThemeData', (tester) async {
    final theme = buildAppTheme();
    expect(theme.brightness, Brightness.dark);
  });
}
