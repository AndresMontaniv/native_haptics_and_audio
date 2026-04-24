import 'dart:io';

import 'package:flutter/foundation.dart';

import 'messages.g.dart';

/// Singleton repository that wraps the Pigeon-generated [HapticsAndAudioApi].
///
/// This class is the **only** public API for consumers of this plugin.
/// It guards against double-initialization, logs errors gracefully,
/// and silently no-ops on unsupported platforms (Web, Windows, macOS, Linux).
class NativeHapticsAndAudioRepository {
  NativeHapticsAndAudioRepository._();

  /// The single shared instance.
  static final instance = NativeHapticsAndAudioRepository._();

  final HapticsAndAudioApi _api = HapticsAndAudioApi();
  bool _initialized = false;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _initialized;

  /// Returns `true` only on Android and iOS — the platforms with native bridge listeners.
  bool get _isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void _logUnsupported() {
    debugPrint('NativeHapticsAndAudio: Platform not supported. Ignoring hardware feedback call.');
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
    try {
      await _api.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint('NativeHapticsAndAudio: init failed — $e');
    }
  }

  /// Plays the given [sound] instantly on the native audio engine.
  ///
  /// Silently no-ops if [initialize] has not been called or platform is unsupported.
  Future<void> playSound(PosSound sound) async {
    if (!_isSupported) {
      _logUnsupported();
      return;
    }
    if (!_initialized) return;
    try {
      await _api.playSound(sound);
    } catch (e) {
      debugPrint('NativeHapticsAndAudio: playSound failed — $e');
    }
  }

  /// Triggers the given [haptic] pattern on the native vibration engine.
  ///
  /// Silently no-ops if [initialize] has not been called or platform is unsupported.
  Future<void> playHaptic(PosHaptic haptic) async {
    if (!_isSupported) {
      _logUnsupported();
      return;
    }
    if (!_initialized) return;
    try {
      await _api.playHaptic(haptic);
    } catch (e) {
      debugPrint('NativeHapticsAndAudio: playHaptic failed — $e');
    }
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
