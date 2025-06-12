// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EveryMatrixProviderClient",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EveryMatrixProviderClient",
            targets: ["EveryMatrixProviderClient"]),
    ],
    dependencies: [
        // Add OrderedCollections here
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.2.0"),
        .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
        .package(url: "https://github.com/rroques/Starscream.git", from: "4.0.6")

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EveryMatrixProviderClient",
            dependencies: [
                // Link OrderedCollections to your target
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "DictionaryCoding", package: "DictionaryCoding"),
                .product(name: "Starscream", package: "Starscream")
            ],
            path: "",
            sources: ["Sources"]
        ),
        .testTarget(
            name: "EveryMatrixProviderClientTests",
            dependencies: ["EveryMatrixProviderClient"]
        ),
    ]
)
