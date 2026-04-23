// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:native_haptics_and_audio/native_haptics_and_audio.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initialize and release lifecycle', (WidgetTester tester) async {
    final repo = NativeHapticsAndAudioRepository.instance;
    await repo.initialize();
    expect(repo.isInitialized, true);
    await repo.release();
    expect(repo.isInitialized, false);
  });
}
