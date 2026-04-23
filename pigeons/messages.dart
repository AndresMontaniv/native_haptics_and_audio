import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/andresmontano/native_haptics_and_audio/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.andresmontano.native_haptics_and_audio'),
    swiftOut: 'ios/Classes/Messages.g.swift',
    dartPackageName: 'native_haptics_and_audio',
  ),
)
/// The set of pre-bundled POS audio assets.
enum PosSound { scannerBeep, warningBeep, doubleWarningBeep, kaching }

/// The set of native haptic feedback types for POS interactions.
enum PosHaptic { success, warning, error }

/// Host API for ultra-low-latency native haptic and audio feedback.
///
/// All communication flows from Flutter → Native.
@HostApi()
abstract class HapticsAndAudioApi {
  /// Pre-loads all audio assets into native RAM and prepares
  /// the haptic engine. Must complete before any playback calls.
  @async
  void initialize();

  /// Instantly plays the specified pre-loaded audio asset.
  void playSound(PosSound sound);

  /// Instantly triggers the specified native haptic pattern.
  void playHaptic(PosHaptic haptic);

  /// Releases all native audio resources and haptic generators
  /// from memory. Call when the scanner is disposed.
  void release();
}
