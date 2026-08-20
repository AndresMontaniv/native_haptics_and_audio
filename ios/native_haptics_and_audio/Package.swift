// swift-tools-version: 5.9
// This Package.swift adds Swift Package Manager (SwiftPM) support alongside the
// existing CocoaPods .podspec (dual-mode). Flutter 3.27+ uses SwiftPM automatically
// when a Package.swift is detected in the plugin's ios/ directory.
import PackageDescription

let package = Package(
    name: "native_haptics_and_audio",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(
            name: "native-haptics-and-audio",
            targets: ["native_haptics_and_audio"]
        ),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "native_haptics_and_audio",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/native_haptics_and_audio",
            resources: [
                .process("Assets"),
            ]
        ),
    ]
)
