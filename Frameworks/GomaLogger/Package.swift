// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GomaLogger",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GomaLogger",
            targets: ["GomaLogger"]
        ),
    ],
    targets: [
        .target(
            name: "GomaLogger",
            dependencies: []
        ),
        .testTarget(
            name: "GomaLoggerTests",
            dependencies: ["GomaLogger"]
        ),
    ]
)
