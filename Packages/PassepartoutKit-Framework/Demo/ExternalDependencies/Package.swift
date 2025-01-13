// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExternalDependencies",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "ExternalDependencies",
            targets: ["ExternalDependencies"]
        )
    ],
    dependencies: [
//        .package(path: "../../passepartoutkit-source"),
        .package(path: ".."),
        .package(path: "../../passepartoutkit-source-openvpn-openssl"),
        .package(path: "../../passepartoutkit-source-wireguard-go")
    ],
    targets: [
        .target(
            name: "ExternalDependencies",
            dependencies: [
                .product(name: "PassepartoutKit", package: "passepartoutkit"),
//                .product(name: "PassepartoutKit", package: "passepartoutkit-source"),
                .product(name: "PassepartoutOpenVPNOpenSSL", package: "passepartoutkit-source-openvpn-openssl"),
                .product(name: "PassepartoutWireGuardGo", package: "passepartoutkit-source-wireguard-go")
            ]
        ),
        .testTarget(
            name: "ExternalDependenciesTests",
            dependencies: ["ExternalDependencies"]
        )
    ]
)
