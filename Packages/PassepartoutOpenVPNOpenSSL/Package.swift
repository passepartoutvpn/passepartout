// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutOpenVPNOpenSSL",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "CPassepartoutCryptoOpenSSL",
            targets: ["CPassepartoutCryptoOpenSSL"]
        ),
        .library(
            name: "CPassepartoutOpenVPNOpenSSL",
            targets: ["CPassepartoutOpenVPNOpenSSL"]
        ),
        .library(
            name: "PassepartoutOpenVPNOpenSSL",
            targets: ["PassepartoutOpenVPNOpenSSL"]
        )
    ],
    dependencies: [
        .package(path: "../PassepartoutKit-Framework"),
        .package(url: "https://github.com/passepartoutvpn/openssl-apple", from: "3.4.200")
    ],
    targets: [
        .target(
            name: "CPassepartoutCryptoOpenSSL",
            dependencies: ["openssl-apple",]
        ),
        .target(
            name: "CPassepartoutOpenVPNOpenSSL",
            dependencies: [
                "CPassepartoutCryptoOpenSSL",
                "PassepartoutKit-Framework"
            ],
            exclude: [
                "lib/COPYING",
                "lib/Makefile",
                "lib/README.LZO",
                "lib/testmini.c"
            ]
        ),
        .target(
            name: "PassepartoutCryptoOpenSSL",
            dependencies: ["CPassepartoutCryptoOpenSSL"]
        ),
        .target(
            name: "PassepartoutOpenVPNOpenSSL",
            dependencies: [
                "CPassepartoutOpenVPNOpenSSL",
                "PassepartoutCryptoOpenSSL"
            ]
        ),
        .testTarget(
            name: "CPassepartoutCryptoOpenSSLTests",
            dependencies: ["PassepartoutCryptoOpenSSL"]
        ),
        .testTarget(
            name: "PassepartoutOpenVPNOpenSSLTests",
            dependencies: ["PassepartoutOpenVPNOpenSSL"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
