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
            name: "AppUIMain",
            targets: ["AppUIMainWrapper"]
        ),
        .library(
            name: "AppUITV",
            targets: ["AppUITVWrapper"]
        ),
        .library(
            name: "CommonIAP",
            targets: ["CommonIAP"]
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
            name: "PassepartoutImplementations",
            targets: ["PassepartoutImplementations"]
        ),
        .library(
            name: "TunnelLibrary",
            targets: ["CommonLibrary"]
        ),
        .library(
            name: "UILibrary",
            targets: ["UILibrary"]
        ),
        .library(
            name: "UITesting",
            targets: ["UITesting"]
        )
    ],
    dependencies: [
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source", from: "0.12.0"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source", revision: "51288509f90b0d4dd2c4ceee2af5cfb36e6319f1"),
//        .package(path: "../../passepartoutkit-source"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-openvpn-openssl", from: "0.9.1"),
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-openvpn-openssl", revision: "031863a1cd683962a7dfe68e20b91fa820a1ecce"),
//        .package(path: "../../passepartoutkit-source-openvpn-openssl"),
        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-wireguard-go", from: "0.12.0"),
//        .package(url: "git@github.com:passepartoutvpn/passepartoutkit-source-wireguard-go", revision: "68fceaa664913988b2d9053405738682a30b87b8"),
//        .package(path: "../../passepartoutkit-source-wireguard-go"),
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
            dependencies: ["UILibrary"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppUIMainWrapper",
            dependencies: [
                .target(name: "AppUIMain", condition: .when(platforms: [.iOS, .macOS]))
            ]
        ),
        .target(
            name: "AppUITV",
            dependencies: ["UILibrary"]
        ),
        .target(
            name: "AppUITVWrapper",
            dependencies: [
                .target(name: "AppUITV", condition: .when(platforms: [.tvOS]))
            ]
        ),
        .target(
            name: "CommonAPI",
            dependencies: ["CommonLibrary"],
            resources: [
                .copy("API")
            ]
        ),
        .target(
            name: "CommonIAP",
            dependencies: ["CommonUtils"]
        ),
        .target(
            name: "CommonLibrary",
            dependencies: [
                "CommonIAP",
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
                "PassepartoutImplementations"
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "PassepartoutImplementations",
            dependencies: [
                .product(name: "PassepartoutKit", package: "passepartoutkit-source"),
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
                "CommonLibrary",
                "UITesting"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "UITesting"
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
