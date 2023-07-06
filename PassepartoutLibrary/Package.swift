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
//        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", from: "6.1.0"),
        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", .revision("d69899bbc032dac0a7218ba160d3a85c16cd8506")),
//        .package(name: "TunnelKit", path: "../../tunnelkit"),
        .package(url: "https://github.com/zoul/generic-json-swift", from: "2.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.

        // MARK: Implementations

        .target(
            name: "PassepartoutLibrary",
            dependencies: [
                "PassepartoutVPNImpl",
                "PassepartoutProvidersImpl"
            ]),
        .target(
            name: "PassepartoutVPNImpl",
            dependencies: [
                "PassepartoutVPN",
                "SwiftyBeaver",
                .product(name: "TunnelKitLZO", package: "TunnelKit")
            ],
            resources: [
                .process("Data/Profiles.xcdatamodeld")
            ]),
        .target(
            name: "PassepartoutProvidersImpl",
            dependencies: [
                "PassepartoutProviders",
                "PassepartoutServices"
            ],
            resources: [
                .copy("API"),
                .process("Data/Providers.xcdatamodeld")
            ]),

        // MARK: Interfaces

        .target(
            name: "PassepartoutVPN",
            dependencies: [
                "PassepartoutProviders",
                .product(name: "TunnelKit", package: "TunnelKit"),
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
                .product(name: "TunnelKitWireGuard", package: "TunnelKit"),
            ]),
        .target(
            name: "PassepartoutProviders",
            dependencies: [
                "PassepartoutCore"
            ]),
        .target(
            name: "PassepartoutServices",
            dependencies: [
                "PassepartoutCore"
            ]),
        .target(
            name: "PassepartoutCore",
            dependencies: [
                .product(name: "GenericJSON", package: "generic-json-swift")
            ]),

        // MARK: App extensions

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

        // MARK: Tests

        .testTarget(
            name: "PassepartoutVPNTests",
            dependencies: ["PassepartoutVPNImpl"]),
        .testTarget(
            name: "PassepartoutProvidersTests",
            dependencies: ["PassepartoutProvidersImpl"]),
        .testTarget(
            name: "PassepartoutCoreTests",
            dependencies: ["PassepartoutCore"],
            resources: [
                .process("Resources")
            ])
    ]
)
