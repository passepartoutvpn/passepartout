// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Library",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppLibrary",
            targets: [
                "AppLibrary",
                "LegacyV2"
            ]
        ),
        .library(
            name: "AppUI",
            targets: [
                "AppDataProfiles",
                "AppUI"
            ]
        ),
        .library(
            name: "TunnelLibrary",
            targets: ["CommonLibrary"]
        )
    ],
    dependencies: [
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit", from: "0.7.0"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit", revision: "2e61214462dcf6ad9e211d8fdbd611c6755845c4"),
//        .package(path: "../../../passepartoutkit"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-openvpn-openssl", from: "0.6.0"),
//        .package(path: "../../../passepartoutkit-openvpn-openssl"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-wireguard-go", from: "0.6.2"),
//        .package(path: "../../../passepartoutkit-wireguard-go"),
        .package(url: "https://github.com/Cocoanetics/Kvitto", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppData",
            dependencies: [
                .product(name: "PassepartoutKit", package: "passepartoutkit")
            ]
        ),
        .target(
            name: "AppDataProfiles",
            dependencies: [
                "AppData",
                "UtilsLibrary",
                .product(name: "PassepartoutKit", package: "passepartoutkit")
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "AppLibrary",
            dependencies: [
                "AppData",
                "CommonLibrary",
                "Kvitto",
                "UtilsLibrary"
            ]
        ),
        .target(
            name: "AppUI",
            dependencies: ["AppLibrary"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CommonLibrary",
            dependencies: [
                .product(name: "PassepartoutKit", package: "passepartoutkit"),
                .product(name: "PassepartoutOpenVPNOpenSSL", package: "passepartoutkit-openvpn-openssl"),
                .product(name: "PassepartoutWireGuardGo", package: "passepartoutkit-wireguard-go")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "LegacyV2",
            dependencies: [
                .product(name: "PassepartoutKit", package: "passepartoutkit")
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "UtilsLibrary"
        ),
        .testTarget(
            name: "AppLibraryTests",
            dependencies: ["AppLibrary"]
        ),
        .testTarget(
            name: "AppUITests",
            dependencies: ["AppUI"]
        )
    ]
)
