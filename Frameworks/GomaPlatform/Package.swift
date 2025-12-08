// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "GomaPlatform",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GomaPlatform",
            targets: ["GomaPlatform"]),
    ],
    dependencies: [
        .package(path: "../GomaUI/GomaUI"),
    ],
    targets: [
        .target(
            name: "GomaPlatform",
            dependencies: ["GomaUI"]
        ),
        .testTarget(
            name: "GomaPlatformTests",
            dependencies: ["GomaPlatform"]
        ),
    ]
)
