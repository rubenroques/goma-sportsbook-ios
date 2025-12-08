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
        .package(path: "../GomaPerformanceKit"),
        .package(path: "../ServicesProvider"),
    ],
    targets: [
        .target(
            name: "GomaPlatform",
            dependencies: ["GomaUI", "GomaPerformanceKit", "ServicesProvider"]
        ),
        .testTarget(
            name: "GomaPlatformTests",
            dependencies: ["GomaPlatform"]
        ),
    ]
)
