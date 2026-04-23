import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_haptics_and_audio_method_channel.dart';

abstract class NativeHapticsAndAudioPlatform extends PlatformInterface {
  /// Constructs a NativeHapticsAndAudioPlatform.
  NativeHapticsAndAudioPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeHapticsAndAudioPlatform _instance = MethodChannelNativeHapticsAndAudio();

  /// The default instance of [NativeHapticsAndAudioPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeHapticsAndAudio].
  static NativeHapticsAndAudioPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeHapticsAndAudioPlatform] when
  /// they register themselves.
  static set instance(NativeHapticsAndAudioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
