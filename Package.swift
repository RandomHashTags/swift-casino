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
        .package(url: "https://github.com/vapor/console-kit", from: "4.14.1")
    ],
    targets: [
        .target(
            name: "SwiftCasino",
            dependencies: [
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
