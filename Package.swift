// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "commitPrefix",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        // 📁 John Sundell's Files Package is great for easy file reading/writing/moving/etc.
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        // 🧰 SPMUtilities for CLI Argument Parsing.
        .package(url: "https://github.com/apple/swift-package-manager", .exact("0.5.0")),
        // 🖥 Consler for Styled outputs to the Console
        .package(url: "https://github.com/enuance/consler", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "FoundationExt",
            dependencies: [],
            path: "Sources/FoundationExt"),
        .target(
            name: "CLInterface",
            dependencies: ["SPMUtility", "Consler"],
            path: "Sources/CLInterface"),
        .target(
            name: "commitPrefix",
            dependencies: ["Files", "Consler", "CLInterface", "FoundationExt"],
            path: "Sources/CommitPrefix"),
        .testTarget(
            name: "CommitPrefixTests",
            dependencies: ["CLInterface","commitPrefix", "FoundationExt"]
        )
    ]
)
