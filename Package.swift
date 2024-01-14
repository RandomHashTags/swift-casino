// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-blackjack",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "swift-blackjack",
            targets: ["swift-blackjack"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit", from: "4.14.1")
    ],
    targets: [
        .target(
            name: "swift-blackjack",
            dependencies: [
                .product(name: "ConsoleKit", package: "console-kit")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["swift-blackjack"]
        ),
        .testTarget(
            name: "swift-blackjackTests",
            dependencies: ["swift-blackjack"]
        ),
    ]
)
