// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "GomaUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GomaUI",
            targets: ["GomaUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.12.0")),
        .package(name: "GomaAssets", path: "../GomaAssets"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GomaUI",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                "GomaAssets",
            ],
            path: "",
            sources: ["Sources"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GomaUITests",
            dependencies: ["GomaUI"]),
    ]
)
