## 1.0.0

* Initial release.
* Added zero-latency 16-bit PCM mono audio playback for `scannerBeep`, `warningBeep`, `doubleWarningBeep`, and `kaching`.
* Added ultra-low latency hardware haptic feedback for `success` (crisp UI impact), `warning`, and `error`.
* Implemented graceful fallback logic to prevent runtime crashes on unsupported desktop and web platforms.