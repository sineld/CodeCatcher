// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodeCatcher",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "CodeCatcher"),
        .testTarget(name: "CodeCatcherTests", dependencies: ["CodeCatcher"]),
    ]
)
