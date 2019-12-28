// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "commitPrefix",
    dependencies: [
        // 📁 John Sundell's Files Package is great for easy file reading/writing/moving/etc.
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        // 🧰 SPMUtilities for CLI Argument Parsing.
        .package(url: "https://github.com/apple/swift-package-manager", from: "0.5.0"),
        // Consler for Styled outputs to the Console
        .package(url: "https://github.com/enuance/consler", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "commitPrefix",
            dependencies: ["Files", "SPMUtility", "Consler"],
            // Normally don't have to specify the path, but I wan't the actual executable to be
            // lowercase and SPM brings folders in Uppercased by default.
            path: "Sources/CommitPrefix"),
        .testTarget(
            name: "CommitPrefixTests",
            dependencies: ["commitPrefix"]),
    ]
)
