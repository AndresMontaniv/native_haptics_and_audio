// swift-tools-version: 5.9
// This Package.swift adds Swift Package Manager (SwiftPM) support alongside the
// existing CocoaPods .podspec (dual-mode). Flutter will use SwiftPM automatically
// on Flutter 3.27+ when swiftPackageManagerEnabled is set in pubspec.yaml.
import PackageDescription

let package = Package(
    name: "native_haptics_and_audio",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(
            name: "native_haptics_and_audio",
            targets: ["native_haptics_and_audio"]
        ),
    ],
    targets: [
        .target(
            name: "native_haptics_and_audio",
            dependencies: [],
            path: ".",
            exclude: [
                "native_haptics_and_audio.podspec",
                "Resources",
                ".gitignore",
            ],
            sources: ["Classes"],
            resources: [
                // .process allows Xcode to optimize the audio files for the target platform.
                .process("Assets"),
            ],
            publicHeadersPath: "Classes"
        ),
    ]
)
