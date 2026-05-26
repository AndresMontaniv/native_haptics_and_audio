import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio.dart';
import 'package:native_haptics_and_audio/src/messages.g.dart';

/// A fake [HapticsAndAudioApi] that records every call in-memory
/// without touching the platform channel.
class FakeHapticsAndAudioApi extends HapticsAndAudioApi {
  FakeHapticsAndAudioApi()
      : super(binaryMessenger: _NoOpBinaryMessenger());

  bool initializeCalled = false;
  bool releaseCalled = false;
  final List<PosSound> soundsPlayed = [];
  final List<PosHaptic> hapticsPlayed = [];
  bool shouldThrow = false;

  @override
  Future<void> initialize() async {
    if (shouldThrow) throw PlatformException(code: 'TEST_ERROR');
    initializeCalled = true;
  }

  @override
  Future<void> playSound(PosSound sound) async {
    if (shouldThrow) throw PlatformException(code: 'TEST_ERROR');
    soundsPlayed.add(sound);
  }

  @override
  Future<void> playHaptic(PosHaptic haptic) async {
    if (shouldThrow) throw PlatformException(code: 'TEST_ERROR');
    hapticsPlayed.add(haptic);
  }

  @override
  Future<void> release() async {
    if (shouldThrow) throw PlatformException(code: 'TEST_ERROR');
    releaseCalled = true;
  }
}

/// A [BinaryMessenger] that never sends messages — used only to
/// satisfy the [HapticsAndAudioApi] constructor in test.
class _NoOpBinaryMessenger extends BinaryMessenger {
  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {}

  @override
  Future<ByteData?>? send(String channel, ByteData? message) => null;

  @override
  void setMessageHandler(
    String channel,
    MessageHandler? handler,
  ) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeHapticsAndAudioApi fakeApi;
  late NativeHapticsAndAudioRepository repo;

  setUp(() {
    fakeApi = FakeHapticsAndAudioApi();
    repo = NativeHapticsAndAudioRepository.forTesting(fakeApi);
  });

  group('initialize', () {
    test('calls the native API and sets isInitialized', () async {
      await repo.initialize();

      expect(fakeApi.initializeCalled, isTrue);
      expect(repo.isInitialized, isTrue);
    });

    test('is idempotent — second call is a no-op', () async {
      await repo.initialize();
      fakeApi.initializeCalled = false;

      await repo.initialize();

      expect(fakeApi.initializeCalled, isFalse,
          reason: 'Should not call native initialize() twice');
    });

    test('catches and logs native exceptions without rethrowing', () async {
      fakeApi.shouldThrow = true;

      await repo.initialize();

      expect(repo.isInitialized, isFalse);
    });
  });

  group('playSound', () {
    test('fires the native call when initialized', () async {
      await repo.initialize();

      repo.playSound(PosSound.scannerBeep);
      // Give the fire-and-forget future a tick to complete.
      await Future<void>.delayed(Duration.zero);

      expect(fakeApi.soundsPlayed, [PosSound.scannerBeep]);
    });

    test('no-ops silently when not initialized', () async {
      repo.playSound(PosSound.kaching);
      await Future<void>.delayed(Duration.zero);

      expect(fakeApi.soundsPlayed, isEmpty);
    });

    test('catches errors without crashing', () async {
      await repo.initialize();
      fakeApi.shouldThrow = true;

      // Should not throw.
      repo.playSound(PosSound.warningBeep);
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('playHaptic', () {
    test('fires the native call when initialized', () async {
      await repo.initialize();

      repo.playHaptic(PosHaptic.success);
      await Future<void>.delayed(Duration.zero);

      expect(fakeApi.hapticsPlayed, [PosHaptic.success]);
    });

    test('no-ops silently when not initialized', () async {
      repo.playHaptic(PosHaptic.error);
      await Future<void>.delayed(Duration.zero);

      expect(fakeApi.hapticsPlayed, isEmpty);
    });

    test('catches errors without crashing', () async {
      await repo.initialize();
      fakeApi.shouldThrow = true;

      repo.playHaptic(PosHaptic.warning);
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('release', () {
    test('calls the native API and resets isInitialized', () async {
      await repo.initialize();
      expect(repo.isInitialized, isTrue);

      await repo.release();

      expect(fakeApi.releaseCalled, isTrue);
      expect(repo.isInitialized, isFalse);
    });

    test('no-ops silently when not initialized', () async {
      await repo.release();

      expect(fakeApi.releaseCalled, isFalse);
    });

    test('allows re-initialization after release', () async {
      await repo.initialize();
      await repo.release();
      expect(repo.isInitialized, isFalse);

      fakeApi.initializeCalled = false;
      await repo.initialize();

      expect(fakeApi.initializeCalled, isTrue);
      expect(repo.isInitialized, isTrue);
    });

    test('catches errors without crashing', () async {
      await repo.initialize();
      fakeApi.shouldThrow = true;

      await repo.release();

      // isInitialized stays true because release failed.
      expect(repo.isInitialized, isTrue);
    });
  });
}
