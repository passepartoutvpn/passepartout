// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassepartoutKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PassepartoutKit",
            targets: ["PassepartoutKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "PassepartoutKit",
            path: "PassepartoutKit.xcframework.zip"
//            url: "https://github.com/passepartoutvpn/passepartoutkit/releases/download/0.0.1/PassepartoutKit.xcframework.zip",
//            checksum: "c5f07fc0d32dfbe800789c2dc276d287340fcac211186f957f414e40b622afb5"
        ),
        .testTarget(
            name: "PassepartoutKitTests",
            dependencies: ["PassepartoutKit"]
        )
    ]
)
