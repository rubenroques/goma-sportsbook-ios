// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GomaUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GomaUI",
            targets: ["GomaUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(name: "SharedModels", path: "../SharedModels"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GomaUI",
            dependencies: [
                "Kingfisher",
                "SharedModels",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GomaUITests",
            dependencies: [
                "GomaUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
