/// Ultra-low-latency native haptic and audio feedback for POS barcode scanners.
///
/// Usage:
/// ```dart
/// final repo = NativeHapticsAndAudioRepository.instance;
/// await repo.initialize();
/// await repo.playSound(PosSound.scannerBeep);
/// await repo.playHaptic(PosHaptic.success);
/// await repo.release();
/// ```
library;

export 'src/messages.g.dart' show PosSound, PosHaptic;
export 'src/native_haptics_and_audio_repository.dart';
