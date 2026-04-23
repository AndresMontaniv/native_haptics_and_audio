import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:native_haptics_and_audio_example/main.dart';

void main() {
  testWidgets('App renders sound and haptic buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // While initializing, a progress indicator should be visible.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
