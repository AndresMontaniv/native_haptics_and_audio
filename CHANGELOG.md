## 1.1.0

### Ecosystem & Modernization Migrations
* **iOS Swift Package Manager (SwiftPM):** Fully migrated iOS platform code to the official SwiftPM layout (`ios/native_haptics_and_audio/Package.swift`) while maintaining dual-mode CocoaPods compatibility. Configured explicit `FlutterFramework` dependency and asset loading for Flutter 3.27+.
* **Android Built-in Kotlin:** Removed legacy Kotlin Gradle Plugin (KGP) dependencies from `build.gradle.kts` in alignment with Flutter's "Built-in Kotlin" initiative and cleaned up redundant source set definitions.

### Concurrency & Stability Fixes
* **Dart Initialization Race Condition:** Hardened `NativeHapticsAndAudioRepository.initialize()` using `Future<void>?` caching. Concurrent callers now wait for the active initialization to complete instead of risking in-flight execution races.
* **Android SoundPool Callback Guard:** Protected `SoundPool.setOnLoadCompleteListener` with an `AtomicBoolean` to guarantee the Pigeon `Result` callback is invoked exactly once regardless of asynchronous multi-asset load callbacks.

### Developer Experience & Testing
* **Testing Reset Hook:** Added `@visibleForTesting` `NativeHapticsAndAudioRepository.resetForTesting()` to facilitate test isolation in consuming applications and plugin tests.
* **Native Android Unit Tests:** Added JUnit 4 test suite with Mockito to verify native haptic motor triggers and waveform pattern dispatches.
* **Strict Static Analysis:** Enabled `strict-casts` and `strict-inference` in `analysis_options.yaml`.


## 1.0.1
* Fix pub.dev description length warning for improved SEO scoring.

## 1.0.0

* Initial release.
* Added zero-latency 16-bit PCM mono audio playback for `scannerBeep`, `warningBeep`, `doubleWarningBeep`, and `kaching`.
* Added ultra-low latency hardware haptic feedback for `success` (crisp UI impact), `warning`, and `error`.
* Implemented graceful fallback logic to prevent runtime crashes on unsupported desktop and web platforms.