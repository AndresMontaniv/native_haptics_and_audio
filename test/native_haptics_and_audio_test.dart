import 'package:flutter_test/flutter_test.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio_platform_interface.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeHapticsAndAudioPlatform
    with MockPlatformInterfaceMixin
    implements NativeHapticsAndAudioPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeHapticsAndAudioPlatform initialPlatform = NativeHapticsAndAudioPlatform.instance;

  test('$MethodChannelNativeHapticsAndAudio is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeHapticsAndAudio>());
  });

  test('getPlatformVersion', () async {
    NativeHapticsAndAudio nativeHapticsAndAudioPlugin = NativeHapticsAndAudio();
    MockNativeHapticsAndAudioPlatform fakePlatform = MockNativeHapticsAndAudioPlatform();
    NativeHapticsAndAudioPlatform.instance = fakePlatform;

    expect(await nativeHapticsAndAudioPlugin.getPlatformVersion(), '42');
  });
}
