import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_haptics_and_audio_platform_interface.dart';

/// An implementation of [NativeHapticsAndAudioPlatform] that uses method channels.
class MethodChannelNativeHapticsAndAudio extends NativeHapticsAndAudioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_haptics_and_audio');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
