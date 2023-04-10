// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutLibrary",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PassepartoutLibrary",
            targets: ["PassepartoutLibrary"]),
        .library(
            name: "OpenVPNAppExtension",
            targets: ["OpenVPNAppExtension"]),
        .library(
            name: "WireGuardAppExtension",
            targets: ["WireGuardAppExtension"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", from: "6.0.0"),
//        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", .revision("ac362f90ef1c8b64fca113be8521312d85248b48")),
//        .package(name: "TunnelKit", path: "../../tunnelkit"),
        .package(url: "https://github.com/zoul/generic-json-swift", from: "2.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PassepartoutLibrary",
            dependencies: [
                "PassepartoutVPN"
            ]),
        .target(
            name: "PassepartoutVPN",
            dependencies: [
                "PassepartoutProfiles",
                .product(name: "TunnelKitLZO", package: "TunnelKit")
            ]),
        .target(
            name: "PassepartoutProfiles",
            dependencies: [
                "PassepartoutProviders"
            ],
            resources: [
                .process("DataModels/Profiles.xcdatamodeld")
            ]),
        .target(
            name: "PassepartoutProviders",
            dependencies: [
                "PassepartoutCore",
                "PassepartoutServices"
            ],
            resources: [
                .process("DataModels/Providers.xcdatamodeld")
            ]),
        .target(
            name: "PassepartoutCore",
            dependencies: [
                .product(name: "TunnelKit", package: "TunnelKit"),
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
                .product(name: "TunnelKitWireGuard", package: "TunnelKit"),
                .product(name: "GenericJSON", package: "generic-json-swift")
            ]),
        //
        .target(
            name: "PassepartoutServices",
            dependencies: [
                "PassepartoutUtils"
            ],
            resources: [
                .copy("API")
            ]),
        .target(
            name: "PassepartoutUtils",
            dependencies: [
                .product(name: "GenericJSON", package: "generic-json-swift"),
                "SwiftyBeaver"
            ]),
        //
        .target(
            name: "OpenVPNAppExtension",
            dependencies: [
                .product(name: "TunnelKitOpenVPNAppExtension", package: "TunnelKit"),
                .product(name: "TunnelKitLZO", package: "TunnelKit")
            ]),
        .target(
            name: "WireGuardAppExtension",
            dependencies: [
                .product(name: "TunnelKitWireGuardAppExtension", package: "TunnelKit")
            ]),
        .testTarget(
            name: "PassepartoutLibraryTests",
            dependencies: ["PassepartoutLibrary"]),
        .testTarget(
            name: "PassepartoutVPNTests",
            dependencies: ["PassepartoutVPN"]),
        .testTarget(
            name: "PassepartoutProfilesTests",
            dependencies: ["PassepartoutProfiles"]),
        .testTarget(
            name: "PassepartoutProvidersTests",
            dependencies: ["PassepartoutProviders"]),
        .testTarget(
            name: "PassepartoutCoreTests",
            dependencies: ["PassepartoutCore"]),
        .testTarget(
            name: "PassepartoutServicesTests",
            dependencies: ["PassepartoutServices"]),
        .testTarget(
            name: "PassepartoutUtilsTests",
            dependencies: ["PassepartoutUtils"],
            resources: [
                .process("Resources")
            ])
    ]
)
