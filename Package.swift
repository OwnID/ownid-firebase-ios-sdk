// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "OwnIDFirebaseSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "OwnIDFirebaseSDK",
            targets: ["OwnIDFirebaseSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git",
                 from: "8.0.0"),
        .package(url: "https://github.com/OwnID/ownid-core-ios-sdk.git",
                 from: "0.0.0"),
    ],
    targets: [
        .target(name: "OwnIDFirebaseSDK",
                dependencies: [
                    .product(name: "OwnIDCoreSDK", package: "ownid-core-ios-sdk"),
                    .product(name: "OwnIDFlowsSDK", package: "ownid-core-ios-sdk"),
                    .product(name: "OwnIDUISDK", package: "ownid-core-ios-sdk"),
                    .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                ],
                path: "./"),
    ]
)
