
import 'native_haptics_and_audio_platform_interface.dart';

class NativeHapticsAndAudio {
  Future<String?> getPlatformVersion() {
    return NativeHapticsAndAudioPlatform.instance.getPlatformVersion();
  }
}
