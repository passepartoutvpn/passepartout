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
            name: "AppLibraryMain",
            targets: [
                "CommonDataPreferences",
                "CommonDataProfiles",
                "CommonDataProviders",
                "AppLibraryMainWrapper"
            ]
        ),
        .library(
            name: "AppLibraryTV",
            targets: [
                "CommonDataPreferences",
                "CommonDataProfiles",
                "CommonDataProviders",
                "AppLibraryTVWrapper"
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
            name: "CommonUtils",
            targets: ["CommonUtils"]
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
            name: "AppAccessibility",
            targets: ["AppAccessibility"]
        ),
        .library(
            name: "AppLibrary",
            targets: ["AppLibrary"]
        ),
        .library(
            name: "CommonWeb",
            targets: ["CommonWeb"]
        )
    ],
    dependencies: [
        .package(path: "../../submodules/partout"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.83.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonData",
            dependencies: []
        ),
        .target(
            name: "CommonDataPreferences",
            dependencies: [
                "CommonData",
                "CommonLibrary"
            ],
            resources: [
                .process("Preferences.xcdatamodeld")
            ]
        ),
        .target(
            name: "CommonDataProfiles",
            dependencies: [
                "CommonData",
                "CommonLibrary"
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
        ),
        .target(
            name: "CommonDataProviders",
            dependencies: [
                "CommonData",
                "CommonLibrary"
            ],
            resources: [
                .process("Providers.xcdatamodeld")
            ]
        ),
        .target(
            name: "AppLibraryWrapper",
            dependencies: [
                .target(name: "AppLibraryMain", condition: .when(platforms: [.iOS, .macOS])),
                .target(name: "AppLibraryTV", condition: .when(platforms: [.tvOS]))
            ],
            path: "Sources/Empty/AppLibraryWrapper"
        ),
        .target(
            name: "AppLibraryMain",
            dependencies: ["AppLibrary"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppLibraryMainWrapper",
            dependencies: [
                .target(name: "AppLibraryMain", condition: .when(platforms: [.iOS, .macOS]))
            ],
            path: "Sources/Empty/AppLibraryMainWrapper"
        ),
        .target(
            name: "AppLibraryTV",
            dependencies: [
                "AppLibrary",
                "CommonWeb"
            ]
        ),
        .target(
            name: "AppLibraryTVWrapper",
            dependencies: [
                .target(name: "AppLibraryTV", condition: .when(platforms: [.tvOS]))
            ],
            path: "Sources/Empty/AppLibraryTVWrapper"
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
                .product(name: "Partout", package: "partout")
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
                .product(name: "PartoutOpenVPN", package: "partout"),
                .product(name: "PartoutWireGuard", package: "partout")
            ],
            path: "Sources/Empty/PassepartoutImplementations"
        ),
        .target(
            name: "AppStrings",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppAccessibility"
        ),
        .target(
            name: "AppLibrary",
            dependencies: [
                "CommonLibrary",
                "AppStrings",
                "AppAccessibility"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CommonWeb",
            dependencies: [
                "CommonLibrary",
                "AppStrings",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AppLibraryMainTests",
            dependencies: ["AppLibraryMain"]
        ),
        .testTarget(
            name: "CommonLibraryTests",
            dependencies: ["CommonLibrary"]
        ),
        .testTarget(
            name: "CommonUtilsTests",
            dependencies: ["CommonUtils"]
        ),
        .testTarget(
            name: "LegacyV2Tests",
            dependencies: ["LegacyV2"]
        ),
        .testTarget(
            name: "AppLibraryTests",
            dependencies: ["AppLibrary"]
        ),
        .testTarget(
            name: "CommonWebTests",
            dependencies: ["CommonWeb"]
        )
    ]
)
