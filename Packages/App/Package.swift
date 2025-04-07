// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
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
            targets: [
                "AppDataPreferences",
                "AppDataProfiles",
                "AppDataProviders",
                "AppUIMainWrapper"
            ]
        ),
        .library(
            name: "AppUITV",
            targets: [
                "AppDataPreferences",
                "AppDataProfiles",
                "AppDataProviders",
                "AppUITVWrapper"
            ]
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
            name: "UIAccessibility",
            targets: ["UIAccessibility"]
        ),
        .library(
            name: "UILibrary",
            targets: ["UILibrary"]
        )
    ],
    dependencies: [
        .package(path: "../Partout-Framework"),
        .package(path: "../PassepartoutOpenVPNOpenSSL"),
        .package(path: "../PartoutWireGuardGo")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppData",
            dependencies: []
        ),
        .target(
            name: "AppDataPreferences",
            dependencies: [
                "AppData",
                "CommonLibrary"
            ],
            resources: [
                .process("Preferences.xcdatamodeld")
            ]
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
            ],
            path: "Sources/Empty/AppUI"
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
            ],
            path: "Sources/Empty/AppUIMainWrapper"
        ),
        .target(
            name: "AppUITV",
            dependencies: ["UILibrary"]
        ),
        .target(
            name: "AppUITVWrapper",
            dependencies: [
                .target(name: "AppUITV", condition: .when(platforms: [.tvOS]))
            ],
            path: "Sources/Empty/AppUITVWrapper"
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
                "Partout-Framework"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CommonUtils"
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
                "PassepartoutOpenVPNOpenSSL",
                "PartoutWireGuardGo"
            ],
            path: "Sources/Empty/PassepartoutImplementations"
        ),
        .target(
            name: "UIAccessibility"
        ),
        .target(
            name: "UILibrary",
            dependencies: [
                "CommonAPI",
                "CommonLibrary",
                "UIAccessibility"
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
