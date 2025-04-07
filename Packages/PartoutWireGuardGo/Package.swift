// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PartoutWireGuardGo",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PartoutWireGuardGo",
            targets: ["PartoutWireGuardGo"]
        )
    ],
    dependencies: [
        .package(path: "../Partout-Framework"),
        .package(url: "https://github.com/passepartoutvpn/wireguard-apple", from: "1.1.2")
    ],
    targets: [
        .target(
            name: "PartoutWireGuardGo",
            dependencies: [
                "Partout-Framework",
                .product(name: "WireGuardKit", package: "wireguard-apple")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PartoutWireGuardGoTests",
            dependencies: ["PartoutWireGuardGo"]
        )
    ]
)
