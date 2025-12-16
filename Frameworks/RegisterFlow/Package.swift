// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RegisterFlow",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RegisterFlow",
            targets: ["RegisterFlow"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", .upToNextMajor(from: "4.2.0")),
        .package(url: "https://github.com/optimove-tech/Optimove-SDK-iOS.git", .upToNextMajor(from: "6.3.0")),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.0"),
        .package(name: "Extensions", path: "../Extensions"),
        .package(name: "HeaderTextField", path: "../HeaderTextField"),
        .package(name: "SharedModels", path: "../SharedModels"),
        .package(name: "Theming", path: "../Theming"),
        .package(name: "ServicesProvider", path: "../ServicesProvider"),
        .package(name: "CountrySelectionFeature", path: "../CountrySelectionFeature"),
        .package(name: "AdresseFrancaise", path: "../AdresseFrancaise"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RegisterFlow",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "OptimoveSDK", package: "Optimove-SDK-iOS"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                "SharedModels",
                "HeaderTextField",
                "ServicesProvider",
                "CountrySelectionFeature",
                "AdresseFrancaise",
                "Extensions",
                "Theming",
            ],
            path: "",
            sources: ["Sources"],
            resources: [.process("Resources")]
        ),
        
        .testTarget(
            name: "RegisterFlowTests",
            dependencies: ["RegisterFlow"]),
    ]
)
