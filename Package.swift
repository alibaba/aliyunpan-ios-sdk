// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AliyunpanSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AliyunpanSDK",
            targets: [
                "AliyunpanSDK"])
    ],
    targets: [
        .target(
            name: "AliyunpanSDK"),
        .testTarget(
            name: "AliyunpanSDKTests",
            dependencies: ["AliyunpanSDK"])
    ]
)
