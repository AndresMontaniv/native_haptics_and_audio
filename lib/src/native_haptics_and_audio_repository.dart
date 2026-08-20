import 'dart:io';

import 'package:flutter/foundation.dart';

import 'messages.g.dart';

/// Singleton repository that wraps the Pigeon-generated [HapticsAndAudioApi].
///
/// This class is the **only** public API for consumers of this plugin.
/// It guards against double-initialization, logs errors gracefully,
/// and silently no-ops on unsupported platforms (Web, Windows, macOS, Linux).
///
/// {@template native_haptics_and_audio.usage}
/// ```dart
/// final repo = NativeHapticsAndAudioRepository.instance;
/// await repo.initialize();
/// repo.playSound(PosSound.scannerBeep);  // fire-and-forget
/// repo.playHaptic(PosHaptic.success);    // fire-and-forget
/// await repo.release();
/// ```
/// {@endtemplate}
class NativeHapticsAndAudioRepository {
  NativeHapticsAndAudioRepository._({
    HapticsAndAudioApi? api,
    bool? platformOverride,
  })  : _api = api ?? HapticsAndAudioApi(),
        _platformOverride = platformOverride;

  /// The single shared instance used by production code.
  static NativeHapticsAndAudioRepository get instance => _instance;
  static NativeHapticsAndAudioRepository _instance = NativeHapticsAndAudioRepository._();

  /// Resets the singleton instance to a clean state.
  @visibleForTesting
  static void resetForTesting() {
    _instance = NativeHapticsAndAudioRepository._();
  }

  /// Creates an isolated instance backed by the given [api].
  ///
  /// The optional [platformOverride] lets tests pretend the platform is
  /// supported (`true`) or unsupported (`false`) without running on a
  /// real device.
  @visibleForTesting
  factory NativeHapticsAndAudioRepository.forTesting(
    HapticsAndAudioApi api, {
    bool platformOverride = true,
  }) =>
      NativeHapticsAndAudioRepository._(
        api: api,
        platformOverride: platformOverride,
      );

  final HapticsAndAudioApi _api;
  final bool? _platformOverride;
  bool _initialized = false;
  Future<void>? _initFuture;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _initialized;

  /// Returns `true` only on Android and iOS — the platforms with
  /// native bridge implementations.
  bool get _isSupported {
    if (_platformOverride != null) return _platformOverride;
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void _logUnsupported() {
    debugPrint(
      'NativeHapticsAndAudio: Platform not supported. '
      'Ignoring hardware feedback call.',
    );
  }

  /// Pre-loads all native audio assets and prepares the haptic engine.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  /// Silently returns on unsupported platforms.
  Future<void> initialize() async {
    if (!_isSupported) {
      _logUnsupported();
      return;
    }
    if (_initialized) return;

    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _api.initialize();
    try {
      await _initFuture;
      _initialized = true;
    } catch (e) {
      debugPrint('NativeHapticsAndAudio: init failed — $e');
    } finally {
      _initFuture = null;
    }
  }

  /// Plays the given [sound] instantly on the native audio engine.
  ///
  /// This is a **fire-and-forget** call — it returns immediately while the
  /// platform channel message is still in flight, matching the plugin's
  /// zero-latency promise. Errors are caught and logged via [debugPrint].
  ///
  /// Silently no-ops if [initialize] has not been called or the platform
  /// is unsupported.
  void playSound(PosSound sound) {
    if (!_isSupported) {
      _logUnsupported();
      return;
    }
    if (!_initialized) return;
    _api.playSound(sound).catchError((Object e) {
      debugPrint('NativeHapticsAndAudio: playSound failed — $e');
    });
  }

  /// Triggers the given [haptic] pattern on the native vibration engine.
  ///
  /// This is a **fire-and-forget** call — it returns immediately while the
  /// platform channel message is still in flight. Errors are caught and
  /// logged via [debugPrint].
  ///
  /// Silently no-ops if [initialize] has not been called or the platform
  /// is unsupported.
  void playHaptic(PosHaptic haptic) {
    if (!_isSupported) {
      _logUnsupported();
      return;
    }
    if (!_initialized) return;
    _api.playHaptic(haptic).catchError((Object e) {
      debugPrint('NativeHapticsAndAudio: playHaptic failed — $e');
    });
  }

  /// Releases all native audio and haptic resources from memory.
  ///
  /// After calling this, [initialize] must be called again before playback.
  /// Silently no-ops on unsupported platforms.
  Future<void> release() async {
    if (!_isSupported) return;
    if (!_initialized) return;
    try {
      await _api.release();
      _initialized = false;
    } catch (e) {
      debugPrint('NativeHapticsAndAudio: release failed — $e');
    }
  }
}
