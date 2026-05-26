/// Ultra-low-latency native haptic and audio feedback for POS barcode scanners.
///
/// Usage:
/// ```dart
/// final repo = NativeHapticsAndAudioRepository.instance;
/// await repo.initialize();
/// repo.playSound(PosSound.scannerBeep);  // fire-and-forget
/// repo.playHaptic(PosHaptic.success);    // fire-and-forget
/// await repo.release();
/// ```
library;

export 'src/messages.g.dart' show PosSound, PosHaptic;
export 'src/native_haptics_and_audio_repository.dart';

