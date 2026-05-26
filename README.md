# native_haptics_and_audio

[![pub package](https://img.shields.io/pub/v/native_haptics_and_audio.svg)](https://pub.dev/packages/native_haptics_and_audio)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A high-performance Flutter plugin delivering ultra-low latency audio and haptic feedback for POS (Point of Sale) barcode scanners. 

By bypassing heavy standard audio packages and leveraging raw native hardware APIs with pre-bundled, uncompressed 16-bit PCM sounds, it guarantees instant, zero-lag physical and auditory responses on Android and iOS.

## Why this package?

Standard Flutter audio plugins rely on heavy bridge serialization and decompression, which introduces a microscopic but noticeable lag. If a cashier is scanning 50 items a minute, even a 100ms audio delay feels sluggish. 

This plugin solves that by:
1. **Pre-loading** uncompressed `.wav` assets directly into native RAM (using Android's `SoundPool` and iOS's `AudioServices`).
2. **Utilizing Native Hardware:** Triggering raw ERM motor APIs on Android and the `UIImpactFeedbackGenerator` on iOS for perfectly crisp, mechanical haptic "ticks".
3. **Type Safety:** Using `pigeon` to guarantee stable, crash-free bridge communication.

## Features

* **Zero-Latency Audio:** Instantly play POS-specific sounds (`scannerBeep`, `warningBeep`, `doubleWarningBeep`, `kaching`).
* **Optimized Haptics:** Trigger mathematically tuned POS haptic profiles (`success`, `warning`, `error`).
* **Platform Safe:** Safely swallows method calls on unsupported desktop/web platforms without crashing your cross-platform app.
* **Fire-and-Forget:** `playSound()` and `playHaptic()` return immediately — no `await` needed in your scan loop.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  native_haptics_and_audio: ^1.0.0
```

## Quick Start

You only need to interact with the singleton `NativeHapticsAndAudioRepository`. 

### 1. Initialization
You **must** initialize the repository before playing sounds. This allows the native background threads to load the audio files into RAM. A great place to do this is in your scanner screen's `initState`.

```dart
import 'package:native_haptics_and_audio/native_haptics_and_audio.dart';

@override
void initState() {
  super.initState();
  // Pre-loads native hardware. Safe to call multiple times.
  NativeHapticsAndAudioRepository.instance.initialize();
}
```

### 2. Triggering Feedback
Trigger the ultra-low latency feedback based on your business logic:

```dart
// A successful scan
void onScanSuccess() {
  NativeHapticsAndAudioRepository.instance.playSound(PosSound.scannerBeep);
  NativeHapticsAndAudioRepository.instance.playHaptic(PosHaptic.success);
}

// A failed or unrecognized scan
void onScanError() {
  NativeHapticsAndAudioRepository.instance.playSound(PosSound.doubleWarningBeep);
  NativeHapticsAndAudioRepository.instance.playHaptic(PosHaptic.error);
}
```

### 3. Cleanup (Optional but Recommended)
To free up native RAM, release the hardware bindings when your scanner screen is disposed.

```dart
@override
void dispose() {
  NativeHapticsAndAudioRepository.instance.release();
  super.dispose();
}
```

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Supported | API 24+ (SoundPool + Vibrator) |
| **iOS** | ✅ Supported | iOS 13.0+ (AudioServices + UIFeedbackGenerator) |
| **Web** | ⚪ No-op | Calls return silently |
| **macOS** | ⚪ No-op | Calls return silently |
| **Windows** | ⚪ No-op | Calls return silently |
| **Linux** | ⚪ No-op | Calls return silently |

## Permissions

### Android
The plugin declares the `VIBRATE` permission in its own `AndroidManifest.xml`. No additional setup is required — it is merged automatically during your app's build.

### iOS
No special permissions are required. Audio playback uses system sounds and haptic feedback uses the standard `UIFeedbackGenerator` APIs.

## Available Sounds

| Enum Value | Description |
|---|---|
| `PosSound.scannerBeep` | Standard checkout scanner confirmation beep |
| `PosSound.warningBeep` | Single warning tone for attention-needed events |
| `PosSound.doubleWarningBeep` | Urgent double-beep for errors or duplicate scans |
| `PosSound.kaching` | Cash register "ka-ching" for completed transactions |

## Available Haptics

| Enum Value | Description |
|---|---|
| `PosHaptic.success` | Crisp, short mechanical tick — confirms a successful scan |
| `PosHaptic.warning` | Medium-intensity pulse — signals a non-critical warning |
| `PosHaptic.error` | Heavy double-buzz — signals an error or rejected scan |

## Contributing

Contributions are welcome! Please open an issue first to discuss what you would like to change.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Run `dart analyze` and `dart test` before committing
4. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.