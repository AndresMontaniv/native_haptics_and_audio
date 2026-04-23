import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNativeHapticsAndAudio platform = MethodChannelNativeHapticsAndAudio();
  const MethodChannel channel = MethodChannel('native_haptics_and_audio');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
