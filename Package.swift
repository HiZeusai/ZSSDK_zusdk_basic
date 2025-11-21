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
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/ZUSDK.xcframework.zip",
            checksum: "ad193d671bb4aea711ab29649ac275ad633e4f10a678099eba4a576d452c3fef"
        ),
        .binaryTarget(
            name: "channel_zeus",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/channel_zeus.xcframework.zip",
            checksum: "b6bd37f7d9f934358d4f9f19e7c12ca95a432d8ddbf5479931dd30e53c598722"
        ),
        .binaryTarget(
            name: "ZSSDK",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/ZSSDK.xcframework.zip",
            checksum: "ea15641ea51036e64c74b8a18d2d9c06e5451698c741901bd4c21b0433634b12"
        ),
        .binaryTarget(
            name: "ZSCoreKit",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/ZSCoreKit.xcframework.zip",
            checksum: "e8a951b0a8eb203af442c7b28a6f59f5546d34eb38cdd117eeff92abd5e34732"
        ),
        .binaryTarget(
            name: "GApple",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/GApple.xcframework.zip",
            checksum: "bd26ca1f782244e2c09e38fa1964247ddd18181f36492d751e41cf8587547166"
        ),
        .binaryTarget(
            name: "GGameCenter",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/GGameCenter.xcframework.zip",
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
