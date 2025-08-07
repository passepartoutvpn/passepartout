// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrossApp",
    targets: [
        .executableTarget(
            name: "Passepartout",
            dependencies: ["CrossApp"]
        ),
        .target(
            name: "CrossApp"
        ),
        .testTarget(
            name: "CrossAppTests",
            dependencies: ["CrossApp"]
        ),
    ]
)
