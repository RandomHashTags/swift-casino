// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-casino",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftCasino",
            targets: ["SwiftCasino"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.114.0"),
        .package(url: "https://github.com/vapor/console-kit", from: "4.15.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.3")
    ],
    targets: [
        .target(
            name: "SwiftCasino",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "ConsoleKit", package: "console-kit")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["SwiftCasino"]
        ),
        .testTarget(
            name: "swift-casinoTests",
            dependencies: ["SwiftCasino"]
        ),
    ]
)
