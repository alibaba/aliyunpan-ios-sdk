// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AliyunpanSDK",
    platforms: [
        .iOS(.v13), 
        .macOS(.v10_15), 
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "AliyunpanSDK",
            targets: [
                "AliyunpanSDK"
            ]
        )
    ],
    targets: [
        .target(
            name: "AliyunpanSDK"
        ),
        .testTarget(
            name: "AliyunpanSDKTests",
            dependencies: ["AliyunpanSDK"]
        )
    ]
)
