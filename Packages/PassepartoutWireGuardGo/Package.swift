// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutWireGuardGo",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PassepartoutWireGuardGo",
            targets: ["PassepartoutWireGuardGo"]
        )
    ],
    dependencies: [
        .package(path: "../Partout-Framework"),
        .package(url: "https://github.com/passepartoutvpn/wireguard-apple", from: "1.1.2")
    ],
    targets: [
        .target(
            name: "PassepartoutWireGuardGo",
            dependencies: [
                "Partout-Framework",
                .product(name: "WireGuardKit", package: "wireguard-apple")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PassepartoutWireGuardGoTests",
            dependencies: ["PassepartoutWireGuardGo"]
        )
    ]
)
