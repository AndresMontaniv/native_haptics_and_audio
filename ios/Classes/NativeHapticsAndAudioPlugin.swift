import Flutter
import UIKit
import AudioToolbox
import AVFoundation

/// iOS implementation of the `HapticsAndAudioApi` Pigeon protocol.
///
/// Uses `AudioServicesCreateSystemSoundID` for zero-latency PCM playback
/// and `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator` for native haptic feedback.
public class NativeHapticsAndAudioPlugin: NSObject, FlutterPlugin, HapticsAndAudioApi {

    // MARK: - Properties

    private var soundIds: [PosSound: SystemSoundID] = [:]

    /// Maps each `PosSound` enum value to its corresponding `.wav` filename.
    private static let soundFileNames: [PosSound: String] = [
        .scannerBeep: "store_scanner_beep",
        .warningBeep: "beep_warning",
        .doubleWarningBeep: "double_beep_warning",
        .kaching: "ka-ching",
    ]

    // MARK: - FlutterPlugin registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeHapticsAndAudioPlugin()
        HapticsAndAudioApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: instance
        )
    }

    // MARK: - HapticsAndAudioApi

    /// Pre-loads all `.wav` assets into RAM via `AudioServicesCreateSystemSoundID`.
    ///
    /// The resource bundle lookup follows a two-tier strategy:
    /// 1. Look in the CocoaPods-generated resource bundle (`native_haptics_and_audio`).
    /// 2. Fall back to `Bundle.main` if the assets were flattened by the host build system.
    func initialize(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // --- Resolve the resource bundle ---
            let resourceBundle = resolveResourceBundle()

            // --- Load each .wav into an AudioServices SystemSoundID ---
            for (sound, fileName) in Self.soundFileNames {
                guard let url = resourceBundle.url(
                    forResource: fileName,
                    withExtension: "wav"
                ) else {
                    throw PigeonError(
                        code: "ASSET_NOT_FOUND",
                        message: "Could not locate \(fileName).wav in the plugin bundle.",
                        details: nil
                    )
                }

                var systemSoundId: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &systemSoundId)
                guard status == kAudioServicesNoError else {
                    throw PigeonError(
                        code: "AUDIO_LOAD_FAILED",
                        message: "AudioServicesCreateSystemSoundID failed for \(fileName).wav with status \(status).",
                        details: nil
                    )
                }

                soundIds[sound] = systemSoundId
            }

            // Haptic generators are lightweight and instantiated on demand in playHaptic().

            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    /// Instantly plays the pre-loaded system sound for the given [sound].
    func playSound(sound: PosSound) throws {
        guard let systemSoundId = soundIds[sound] else {
            throw PigeonError(
                code: "SOUND_NOT_LOADED",
                message: "Sound \(sound) has not been loaded. Call initialize() first.",
                details: nil
            )
        }
        AudioServicesPlaySystemSound(systemSoundId)
    }

    /// Triggers a native haptic pattern matching the given [haptic] type.
    ///
    /// Uses `UIImpactFeedbackGenerator(.rigid)` for a crisp `success` tick,
    /// and `UINotificationFeedbackGenerator` for heavier `warning` / `error` pulses.
    func playHaptic(haptic: PosHaptic) throws {
        switch haptic {
        case .success:
            // Single, ultra-crisp mechanical tick.
            let impactGen = UIImpactFeedbackGenerator(style: .rigid)
            impactGen.prepare()
            impactGen.impactOccurred()

        case .warning:
            // Heavier notification pulse.
            let notifGen = UINotificationFeedbackGenerator()
            notifGen.prepare()
            notifGen.notificationOccurred(.warning)

        case .error:
            // Sustained, heavy double-pulse.
            let notifGen = UINotificationFeedbackGenerator()
            notifGen.prepare()
            notifGen.notificationOccurred(.error)
        }
    }

    /// Disposes all loaded `SystemSoundID` handles.
    func release() throws {
        for (_, systemSoundId) in soundIds {
            AudioServicesDisposeSystemSoundID(systemSoundId)
        }
        soundIds.removeAll()
    }

    // MARK: - Private helpers

    /// Resolves the resource bundle for this plugin.
    ///
    /// - Under **SwiftPM**: uses `Bundle.module`, which is synthesized automatically
    ///   by the Swift build system for the package's declared resources.
    /// - Under **CocoaPods**: uses the `resource_bundles` nested bundle strategy,
    ///   with a `Bundle.main` fallback for hosts that flatten assets.
    private func resolveResourceBundle() -> Bundle {
        #if SWIFT_PACKAGE
        // SwiftPM synthesizes Bundle.module for the package target's resources.
        return Bundle.module
        #else
        // The CocoaPods `resource_bundles` directive creates a nested bundle
        // named after the key in the podspec (`native_haptics_and_audio`).
        let frameworkBundle = Bundle(for: NativeHapticsAndAudioPlugin.self)
        if let resourceBundleURL = frameworkBundle.url(
            forResource: "native_haptics_and_audio",
            withExtension: "bundle"
        ), let resourceBundle = Bundle(url: resourceBundleURL) {
            return resourceBundle
        }

        // Fallback: assets may have been flattened into the main app bundle.
        return Bundle.main
        #endif
    }
}
