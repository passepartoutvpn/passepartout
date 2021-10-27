// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PassepartoutCore",
            targets: ["PassepartoutCore"]),
        .library(
            name: "PassepartoutOpenVPNTunnel",
            targets: ["PassepartoutOpenVPNTunnel"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TunnelKit", url: "https://github.com/passepartoutvpn/tunnelkit", revision: "3a546ebfbb4cde41496cc719781dbf11477ae161"),
        .package(name: "Convenience", url: "https://github.com/keeshux/convenience", revision: "c7399a59539308db5a05b6b83fb10e23fcc81426"),
        .package(url: "https://github.com/Cocoanetics/Kvitto", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PassepartoutConstants",
            dependencies: []),
        .target(
            name: "PassepartoutCore",
            dependencies: [
                "PassepartoutConstants",
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
                .product(name: "TunnelKitLZO", package: "TunnelKit"),
                "Convenience",
                .product(name: "ConvenienceUI", package: "Convenience", condition: .when(platforms: [.iOS])),
                "Kvitto"
            ],
            resources: [
                .copy("API")
            ]),
        .target(
            name: "PassepartoutOpenVPNTunnel",
            dependencies: [
                "PassepartoutConstants",
                .product(name: "TunnelKitOpenVPN", package: "TunnelKit"),
                .product(name: "TunnelKitLZO", package: "TunnelKit")
            ]),
        .testTarget(
            name: "PassepartoutCoreTests",
            dependencies: ["PassepartoutCore"],
            resources: [
                .process("Resources")
            ])
    ]
)
