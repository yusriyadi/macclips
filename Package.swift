// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ClipboardManagerCore",
            targets: ["ClipboardManagerCore"]
        ),
        .executable(
            name: "ClipboardManagerApp",
            targets: ["ClipboardManagerApp"]
        ),
    ],
    targets: [
        .target(
            name: "ClipboardManagerCore"
        ),
        .executableTarget(
            name: "ClipboardManagerApp",
            dependencies: ["ClipboardManagerCore"]
        ),
        .testTarget(
            name: "ClipboardManagerCoreTests",
            dependencies: ["ClipboardManagerCore"]
        ),
        .testTarget(
            name: "ClipboardManagerAppTests",
            dependencies: ["ClipboardManagerApp", "ClipboardManagerCore"]
        ),
    ]
)
