// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZSSDK_zusdk_basic",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZUSDK",
            targets: ["ZUSDKBasicWrapper"]),
    ],
    targets: [
        .binaryTarget(
            name: "ZUSDK",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/ZUSDK_2.1.8_fixbundle.zip",
            checksum: "800376a860a538e0837a081d347670d328cfb3800a33ad9fe66330118407a8af"
        ),
        .binaryTarget(
            name: "ZSSDK",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/ZSSDK.xcframework.zip",
            checksum: "ea15641ea51036e64c74b8a18d2d9c06e5451698c741901bd4c21b0433634b12"
        ),
        .binaryTarget(
            name: "ZSCoreKit",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/ZSCoreKit.xcframework.zip",
            checksum: "e8a951b0a8eb203af442c7b28a6f59f5546d34eb38cdd117eeff92abd5e34732"
        ),
        .binaryTarget(
            name: "channel_zeus",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/channel_zeus_2.1.8_fixbundle.zip",
            checksum: "b6bd37f7d9f934358d4f9f19e7c12ca95a432d8ddbf5479931dd30e53c598722"
        ),
        .binaryTarget(
            name: "GApple",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/GApple_2.1.8_fixbundle.zip",
            checksum: "bd26ca1f782244e2c09e38fa1964247ddd18181f36492d751e41cf8587547166"
        ),
        .binaryTarget(
            name: "GGameCenter",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/GGameCenter_2.1.8_fixbundle.zip",
            checksum: "c3be7d42b3a577addf0ce453823d78587640144ae9c004259fbfc274f890488f"
        ),
        .target(
            name: "ZUSDKBasicWrapperOC",
            path: "Sources/ZUSDKBasicWrapperOC",
            publicHeadersPath: "."
        ),
        .target(
            name: "ZUSDKBasicWrapper",
            dependencies: [
                "ZUSDKBasicWrapperOC",  // 依赖 Objective-C target
                "ZSSDK",
                "ZUSDK",
                "ZSCoreKit",
                "GApple",
                "GGameCenter",
                "channel_zeus"
            ],
            path: "Sources",
            exclude: ["ZUSDK.bundle", "ZUSDKBasicWrapperOC"],  // 排除 bundle 和 OC 目录
            sources: ["ZUSDKBasicWrapper.swift"],  // 只包含 Swift 文件
            resources: [
                .copy("ZUSDK.bundle"),  // bundle 文件在 Sources 目录下
            ]
        ),

    ]
)
