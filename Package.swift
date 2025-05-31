// swift-tools-version:5.7
import PackageDescription

let packageName = "Sportsbook"

let commonDependencies: [Target.Dependency] = [
    .product(name: "Reachability", package: "Reachability.swift"),
    .product(name: "DictionaryCoding", package: "DictionaryCoding"),
    .product(name: "Starscream", package: "Starscream"),
    .product(name: "CombineCocoa", package: "CombineCocoa"),
    .product(name: "Kingfisher", package: "Kingfisher"),
    .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
    .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
    .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
    .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
    .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
    .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
    .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
    .product(name: "Collections", package: "swift-collections"),
    .product(name: "OrderedCollections", package: "swift-collections"),
    .product(name: "SweeterSwift", package: "SweeterSwift"),
    .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
    .product(name: "SocketIO", package: "socket.io-client-swift"),
    .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
    .product(name: "Adyen", package: "adyen-ios"),
    .product(name: "AdyenActions", package: "adyen-ios"),
    .product(name: "AdyenCard", package: "adyen-ios"),
    .product(name: "AdyenComponents", package: "adyen-ios"),
    .product(name: "AdyenDropIn", package: "adyen-ios"),
    .product(name: "AdyenEncryption", package: "adyen-ios"),
    .product(name: "AdyenSession", package: "adyen-ios"),
    .product(name: "AdyenSwiftUI", package: "adyen-ios"),
    .product(name: "AdyenWeChatPay", package: "adyen-ios"),
    .product(name: "Lottie", package: "lottie-spm"),
    .product(name: "PhraseSDK", package: "ios-sdk"),
    .product(name: "IdensicMobileSDK", package: "IdensicMobileSDK-iOS"),
    .product(name: "OptimoveCore", package: "Optimove-SDK-iOS"),
    .product(name: "OptimoveNotificationServiceExtension", package: "Optimove-SDK-iOS"),
    .product(name: "OptimoveSDK", package: "Optimove-SDK-iOS"),
    .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint"),
    .product(name: "Adjust", package: "ios_sdk"),
    .product(name: "Criteo", package: "Criteo"),
    .product(name: "Sociomantic", package: "Sociomantic"),
    .product(name: "Trademob", package: "Trademob"),
    .product(name: "WebBridge", package: "WebBridge"),
    // Local
    .product(name: "ServicesProvider", package: "ServicesProvider"),
    .product(name: "RegisterFlow", package: "RegisterFlow"),
    .product(name: "HeaderTextField", package: "HeaderTextField"),
    .product(name: "CountrySelectionFeature", package: "CountrySelectionFeature"),
    .product(name: "SharedModels", package: "SharedModels"),
    .product(name: "Extensions", package: "Extensions"),
    .product(name: "GomaUI", package: "GomaUI"),
]

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "Betsson PROD", targets: ["Betsson PROD"]),
        .library(name: "Betsson UAT", targets: ["Betsson UAT"]),
        .library(name: "SportRadar PROD", targets: ["SportRadar PROD"]),
        .library(name: "SportRadar UAT", targets: ["SportRadar UAT"]),
        .library(name: "GomaSportRadar", targets: ["GomaSportRadar"]),
        .library(name: "GOMASports", targets: ["GOMASports"]),
        .library(name: "Crocobet", targets: ["Crocobet"]),
        .library(name: "EveryMatrix", targets: ["EveryMatrix"]),
        .library(name: "DAZN", targets: ["DAZN"]),
        .library(name: "NotificationsService", targets: ["NotificationsService"]),
        .library(name: "SportsbookTests", targets: ["SportsbookTests"])
    ],
    dependencies: [
        .package(url: "https://github.com/Adyen/adyen-ios", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", .upToNextMajor(from: "1.0.9")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/SumSubstance/IdensicMobileSDK-iOS.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/adjust/ios_sdk", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/phrase/ios-sdk/", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/airbnb/lottie-spm.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/optimove-tech/Optimove-SDK-iOS", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/ashleymills/Reachability.swift", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMajor(from: "16.0.0")),
        .package(url: "https://github.com/yonat/SweeterSwift", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint.git", .upToNextMajor(from: "1.4.0")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "SharedModels", path: "../SharedModels"),
        .package(name: "Extensions", path: "../Extensions"),
        .package(name: "ServicesProvider", path: "../ServicesProvider"),
        .package(name: "RegisterFlow", path: "../RegisterFlow"),
        .package(name: "HeaderTextField", path: "../HeaderTextField"),
        .package(name: "CountrySelectionFeature", path: "../CountrySelectionFeature"),
        .package(name: "GomaUI", path: "./GomaUI"),
    ],
    targets: [
        .target(name: "Betsson PROD", dependencies: commonDependencies),
        .target(name: "Betsson UAT", dependencies: commonDependencies),
        .target(name: "SportRadar PROD", dependencies: commonDependencies),
        .target(name: "SportRadar UAT", dependencies: commonDependencies),
        .target(name: "GomaSportRadar", dependencies: commonDependencies),
        .target(name: "GOMASports", dependencies: commonDependencies),
        .target(name: "Crocobet", dependencies: commonDependencies),
        .target(name: "EveryMatrix", dependencies: commonDependencies),
        .target(name: "DAZN", dependencies: commonDependencies),
        .target(
            name: "NotificationsService",
            dependencies: [
                .product(name: "OptimoveNotificationServiceExtension", package: "Optimove-SDK-iOS")
            ]
        ),
        .testTarget(name: "SportsbookTests", dependencies: commonDependencies)
    ]
)