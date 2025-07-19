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
        .library(
            name: "AppAccessibility",
            targets: ["AppAccessibility"]
        ),
        .library(
            name: "AppLibrary",
            targets: ["AppLibrary"]
        ),
        .library(
            name: "AppLibraryMain",
            targets: [
                "CommonDataPreferences",
                "CommonDataProfiles",
                "CommonDataProviders",
                "AppLibraryMain"
            ]
        ),
        .library(
            name: "AppLibraryTV",
            targets: [
                "CommonDataPreferences",
                "CommonDataProfiles",
                "CommonDataProviders",
                "AppLibraryTV"
            ]
        ),
        .library(
            name: "CommonIAP",
            targets: ["CommonIAP"]
        ),
        .library(
            name: "CommonLegacyV2",
            targets: ["CommonLegacyV2"]
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
            name: "CommonWeb",
            targets: ["CommonWeb"]
        ),
        .library(
            name: "PartoutImplementations",
            targets: ["PartoutImplementations"]
        ),
        .library(
            name: "TunnelLibrary",
            targets: ["CommonLibrary"]
        )
    ],
    dependencies: [
        .package(path: "../../submodules/partout"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.83.0")
    ],
    targets: [
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
            name: "AppLibraryMain",
            dependencies: ["AppLibrary"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "AppLibraryTV",
            dependencies: [
                "AppLibrary",
                "CommonWeb"
            ]
        ),
        .target(
            name: "AppStrings",
            resources: [
                .process("Resources")
            ]
        ),
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
            name: "CommonIAP",
            dependencies: ["CommonUtils"]
        ),
        .target(
            name: "CommonLegacyV2",
            dependencies: [
                "CommonLibrary",
                "PartoutImplementations"
            ],
            resources: [
                .process("Profiles.xcdatamodeld")
            ]
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
            name: "PartoutImplementations",
            dependencies: [
                .product(name: "PartoutOpenVPN", package: "partout"),
                .product(name: "PartoutWireGuard", package: "partout")
            ],
            path: "Sources/PartoutImplementations"
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
            name: "AppLibraryTests",
            dependencies: ["AppLibrary"]
        ),
        .testTarget(
            name: "AppLibraryMainTests",
            dependencies: ["AppLibraryMain"]
        ),
        .testTarget(
            name: "CommonLegacyV2Tests",
            dependencies: ["CommonLegacyV2"]
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
            name: "CommonWebTests",
            dependencies: ["CommonWeb"]
        )
    ]
)
