// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZSSDK_zusdk_basic",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZUSDK",
            targets: ["ZUSDKBasicWrapper"]),
    ],
    targets: [
        .binaryTarget(
            name: "ZUSDK",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/ZUSDK.xcframework.zip",
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
                    checksum: "729f445d4c14d917f72a4b594e4d3717b74d00ff63ef5afc8398f4089c134bdd"
        ),
        .binaryTarget(
            name: "channel_zeus",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/channel_zeus.xcframework.zip",
            checksum: "b6bd37f7d9f934358d4f9f19e7c12ca95a432d8ddbf5479931dd30e53c598722"
        ),
        .binaryTarget(
            name: "GApple",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/GApple.xcframework.zip",
            checksum: "bd26ca1f782244e2c09e38fa1964247ddd18181f36492d751e41cf8587547166"
        ),
        .binaryTarget(
            name: "GGameCenter",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.7/GGameCenter.xcframework.zip",
            checksum: "c3be7d42b3a577addf0ce453823d78587640144ae9c004259fbfc274f890488f"
        ),
        .target(
            name: "ZUSDKBasicWrapper",
            dependencies: [
                "ZSSDK",
                "ZUSDK",
                "ZSCoreKit",
                "GApple",
                "GGameCenter",
                "channel_zeus"
            ],
            path: "Sources",
            resources: [
                .copy("ZUSDK.bundle"),  // bundle 文件在 Sources 目录下
            ]
        ),

    ]
)
