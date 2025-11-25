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
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/ZUSDK_2.1.8.zip",
            checksum: "9d99e59750b15aa9ef4d87ba6fa4f80101e5d84f360d090ecfefc0c827cc70c6"
        ),
        .binaryTarget(
            name: "channel_zeus",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/channel_zeus_2.1.8.zip",
            checksum: "2185fd2651376c04537e01b95e5ec6f140dfd325218d192f9863909a9f377646"
        ),
        .binaryTarget(
            name: "GApple",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/GApple_2.1.8.zip",
            checksum: "8aede9c1259415cf9fabb608899770a2c45bdc11adb57a7c1aedcc4f64f3e9d6"
        ),
        .binaryTarget(
            name: "GGameCenter",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.8/GGameCenter_2.1.8.zip",
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
                "ZUSDK",
                "GApple",
                "GGameCenter",
                "channel_zeus"
            ],
            path: "Sources",
            exclude: ["ZUSDKBasicWrapperOC"],  // 只排除 OC 目录，bundle 需要包含在 resources 中
            sources: ["ZUSDKBasicWrapper.swift"],  // 只包含 Swift 文件
            resources: [
                .copy("ZUSDK.bundle"),  // bundle 文件在 Sources 目录下
            ]
        ),

    ]
)
