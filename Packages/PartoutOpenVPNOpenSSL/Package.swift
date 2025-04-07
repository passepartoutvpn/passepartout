// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PartoutOpenVPNOpenSSL",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "CPartoutCryptoOpenSSL",
            targets: ["CPartoutCryptoOpenSSL"]
        ),
        .library(
            name: "CPartoutOpenVPNOpenSSL",
            targets: ["CPartoutOpenVPNOpenSSL"]
        ),
        .library(
            name: "PartoutOpenVPNOpenSSL",
            targets: ["PartoutOpenVPNOpenSSL"]
        )
    ],
    dependencies: [
        .package(path: "../Partout-Framework"),
        .package(url: "https://github.com/passepartoutvpn/openssl-apple", from: "3.4.200")
    ],
    targets: [
        .target(
            name: "CPartoutCryptoOpenSSL",
            dependencies: ["openssl-apple",]
        ),
        .target(
            name: "CPartoutOpenVPNOpenSSL",
            dependencies: [
                "CPartoutCryptoOpenSSL",
                "Partout-Framework"
            ],
            exclude: [
                "lib/COPYING",
                "lib/Makefile",
                "lib/README.LZO",
                "lib/testmini.c"
            ]
        ),
        .target(
            name: "PartoutCryptoOpenSSL",
            dependencies: ["CPartoutCryptoOpenSSL"]
        ),
        .target(
            name: "PartoutOpenVPNOpenSSL",
            dependencies: [
                "CPartoutOpenVPNOpenSSL",
                "PartoutCryptoOpenSSL"
            ]
        ),
        .testTarget(
            name: "CPartoutCryptoOpenSSLTests",
            dependencies: ["PartoutCryptoOpenSSL"]
        ),
        .testTarget(
            name: "PartoutOpenVPNOpenSSLTests",
            dependencies: ["PartoutOpenVPNOpenSSL"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
