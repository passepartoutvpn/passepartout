// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutCore",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PassepartoutCore",
            targets: ["PassepartoutCore"]),
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
//        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", from: "4.1.0"),
//        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", .revision("871e51517c5678d9c683104bd6b0617d5eb2641e")),
        .package(name: "TunnelKit", path: "../../tunnelkit"),
        .package(url: "https://github.com/zoul/generic-json-swift", from: "2.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PassepartoutCore",
            dependencies: [
                "PassepartoutProfiles",
                "PassepartoutProviders"
            ]),
        .target(
            name: "PassepartoutProfiles",
            dependencies: [
                "PassepartoutProviders",
                .product(name: "TunnelKit", package: "TunnelKit"),
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
                .product(name: "TunnelKitWireGuard", package: "TunnelKit"),
                .product(name: "TunnelKitLZO", package: "TunnelKit")
            ]),
        .target(
            name: "PassepartoutProviders",
            dependencies: ["PassepartoutServices"]),
        .target(
            name: "PassepartoutServices",
            dependencies: ["PassepartoutUtils"],
            resources: [
                .copy("API")
            ]),
        .target(
            name: "PassepartoutUtils",
            dependencies: [
                .product(name: "GenericJSON", package: "generic-json-swift"),
                "SwiftyBeaver"
            ]),
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
//        .testTarget(
//            name: "PassepartoutCoreTests",
//            dependencies: ["PassepartoutCore"]),
        .testTarget(
            name: "PassepartoutProfilesTests",
            dependencies: ["PassepartoutProfiles"]),
        .testTarget(
            name: "PassepartoutProvidersTests",
            dependencies: ["PassepartoutProviders"]),
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
