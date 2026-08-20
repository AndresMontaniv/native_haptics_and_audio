## 1.0.2
* **iOS:** Added Swift Package Manager (SwiftPM) support via `ios/Package.swift` (dual-mode: CocoaPods retained for backwards compatibility). Eliminates the "plugin is not using SwiftPM" warning on Flutter 3.27+.
* **Android:** Removed explicit Kotlin Gradle Plugin application. Migrated to Flutter's Built-in Kotlin paradigm. Eliminates the KGP warning on modern Flutter toolchains.
* **Metadata:** Synced `podspec` version and `README` installation snippet to `1.0.2`.

## 1.0.1
* Fix pub.dev description length warning for improved SEO scoring.

## 1.0.0

* Initial release.
* Added zero-latency 16-bit PCM mono audio playback for `scannerBeep`, `warningBeep`, `doubleWarningBeep`, and `kaching`.
* Added ultra-low latency hardware haptic feedback for `success` (crisp UI impact), `warning`, and `error`.
* Implemented graceful fallback logic to prevent runtime crashes on unsupported desktop and web platforms.