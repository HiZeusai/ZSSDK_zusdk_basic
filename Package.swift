// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZSSDK_zusdk_basic",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZUSDK_basic",
            targets: ["ZUSDKBasicWrapper"]),
    ],
    targets: [
        .binaryTarget(
            name: "ZSSDK",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/ZSSDK.xcframework.zip",
            checksum: "de412947d75939892244342ad7d8edfdc8892a9d349d1dd4544e0e13a0c97524"
        ),
        .binaryTarget(
            name: "ZSCoreKit",
            url: "https://github.com/HiZeusai/SDKPackage/releases/download/2.1.6/ZSCoreKit.xcframework.zip",
            checksum: "be9c7708546f0eaae6f51925da449d29b6d287dce662cf8ab0730436b8d40f7f"
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
                "ZSCoreKit",
                "GApple",
                "GGameCenter",
            ],
            path: "Sources",
            resources: [
                .copy("ZUSDK.bundle"),  // bundle 文件在 Sources 目录下
            ]
        ),

    ]
)
