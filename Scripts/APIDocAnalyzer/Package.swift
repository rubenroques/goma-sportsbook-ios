// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "APIDocAnalyzer",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ModelParser",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "Sources/ModelParser",
            sources: ["swift_parser.swift"]
        ),
        .executableTarget(
            name: "DocGenerator",
            dependencies: [],
            path: "Sources/DocGenerator"
        )
    ]
) 