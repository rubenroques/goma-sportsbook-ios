// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GomaPerformanceKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GomaPerformanceKit",
            targets: ["GomaPerformanceKit"]
        ),
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .target(
            name: "GomaPerformanceKit",
            dependencies: []
        )
    ]
)
