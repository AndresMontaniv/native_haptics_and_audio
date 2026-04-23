import Flutter
import UIKit
import AudioToolbox
import AVFoundation

/// iOS implementation of the `HapticsAndAudioApi` Pigeon protocol.
///
/// Uses `AudioServicesCreateSystemSoundID` for zero-latency PCM playback
/// and `UINotificationFeedbackGenerator` for native haptic feedback.
public class NativeHapticsAndAudioPlugin: NSObject, FlutterPlugin, HapticsAndAudioApi {

    // MARK: - Properties

    private var soundIds: [PosSound: SystemSoundID] = [:]
    private var feedbackGenerator: UINotificationFeedbackGenerator?

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

    /// Pre-loads all `.wav` assets into RAM via `AudioServicesCreateSystemSoundID`
    /// and prepares the haptic feedback generator.
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

            // --- Prepare the haptic generator ---
            feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator?.prepare()

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

    /// Triggers a native haptic notification matching the given [haptic] type.
    func playHaptic(haptic: PosHaptic) throws {
        guard let generator = feedbackGenerator else {
            throw PigeonError(
                code: "HAPTIC_NOT_READY",
                message: "Feedback generator is nil. Call initialize() first.",
                details: nil
            )
        }

        let feedbackType: UINotificationFeedbackGenerator.FeedbackType
        switch haptic {
        case .success:
            feedbackType = .success
        case .warning:
            feedbackType = .warning
        case .error:
            feedbackType = .error
        }

        generator.notificationOccurred(feedbackType)
        generator.prepare() // Re-prime for next immediate use.
    }

    /// Disposes all loaded `SystemSoundID` handles and nils the haptic generator.
    func release() throws {
        for (_, systemSoundId) in soundIds {
            AudioServicesDisposeSystemSoundID(systemSoundId)
        }
        soundIds.removeAll()
        feedbackGenerator = nil
    }

    // MARK: - Private helpers

    /// Resolves the CocoaPods resource bundle for this plugin, with a
    /// `Bundle.main` fallback in case assets were flattened by the host build.
    private func resolveResourceBundle() -> Bundle {
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
    }
}
