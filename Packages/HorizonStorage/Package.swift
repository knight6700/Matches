// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HorizonStorage",
    defaultLocalization: .init("en"),
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "HorizonStorage",
            targets: ["HorizonStorage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", branch: "master"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "HorizonStorage",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
            ],
            path: "Sources"),
        .testTarget(
            name: "HorizonStorageTests",
            dependencies: [
                "HorizonStorage",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]),
    ]
)
