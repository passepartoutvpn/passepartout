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
            name: "AppUI",
            targets: [
                "AppUI",
                "PassepartoutImplementations"
            ]
        ),
        .library(
            name: "AppUIMain",
            targets: ["AppUIMain"]
        ),
        .library(
            name: "AppUITV",
            targets: ["AppUITV"]
        ),
        .library(
            name: "CommonLibrary",
            targets: ["CommonLibrary"]
        ),
        .library(
            name: "LegacyV2",
            targets: ["LegacyV2"]
        ),
        .library(
            name: "TunnelLibrary",
            targets: [
                "CommonLibrary",
                "PassepartoutImplementations"
            ]
        ),
        .library(
            name: "UILibrary",
            targets: ["UILibrary"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source", from: "0.11.0"),
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source", revision: "3a4c78af67dfe181acc657a5539ee3d62d1c9361"),
//        .package(path: "../../../passepartoutkit-source"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-openvpn-openssl", from: "0.9.1"),
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-openvpn-openssl", revision: "031863a1cd683962a7dfe68e20b91fa820a1ecce"),
//        .package(path: "../../../passepartoutkit-source-openvpn-openssl"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-wireguard-go", from: "0.9.2"),
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-wireguard-go", revision: "ea39fa396e98cfd2b9a235f0a801aaf03a37e30a"),
//        .package(path: "../../../passepartoutkit-source-wireguard-go"),
        .package(url: "https://github.com/Cocoanetics/Kvitto", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppData",
            dependencies: []
        ),
        .target(
            name: "AppDataProfiles",
            dependencies: [
                "AppData",
                "CommonLibrary"
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "AppDataProviders",
            dependencies: [
                "AppData",
                "CommonLibrary"
            ],
            resources: [
                .process("Providers.xcdatamodeld")
            ]
        ),
        .target(
            name: "AppUI",
            dependencies: [
                .target(name: "AppUIMain", condition: .when(platforms: [.iOS, .macOS])),
                .target(name: "AppUITV", condition: .when(platforms: [.tvOS]))
            ]
        ),
        .target(
            name: "AppUIMain",
            dependencies: [
                "LegacyV2",
                "UILibrary"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppUITV",
            dependencies: ["UILibrary"]
        ),
        .target(
            name: "CommonAPI",
            dependencies: ["CommonLibrary"],
            resources: [
                .copy("API")
            ]
        ),
        .target(
            name: "CommonLibrary",
            dependencies: [
                "CommonUtils",
                .product(name: "PassepartoutKit", package: "passepartoutkit-source")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CommonUtils",
            dependencies: ["Kvitto"]
        ),
        .target(
            name: "LegacyV2",
            dependencies: [
                "CommonLibrary",
                "PassepartoutImplementations",
                .product(name: "PassepartoutKit", package: "passepartoutkit-source")
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "PassepartoutImplementations",
            dependencies: [
                .product(name: "PassepartoutOpenVPNOpenSSL", package: "passepartoutkit-source-openvpn-openssl"),
                .product(name: "PassepartoutWireGuardGo", package: "passepartoutkit-source-wireguard-go")
            ]
        ),
        .target(
            name: "UILibrary",
            dependencies: [
                "AppDataProfiles",
                "AppDataProviders",
                "CommonAPI",
                "CommonLibrary"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AppUIMainTests",
            dependencies: ["AppUIMain"]
        ),
        .testTarget(
            name: "CommonLibraryTests",
            dependencies: ["CommonLibrary"]
        ),
        .testTarget(
            name: "LegacyV2Tests",
            dependencies: ["LegacyV2"]
        ),
        .testTarget(
            name: "UILibraryTests",
            dependencies: ["UILibrary"]
        )
    ]
)
