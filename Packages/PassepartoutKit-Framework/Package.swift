// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let environment: Environment
//environment = .production
environment = .onlineDevelopment

enum Environment {
    case localDevelopment

    case onlineDevelopment

    case production

    var dependencies: [Package.Dependency] {
        switch self {
        case .localDevelopment, .onlineDevelopment:
            return []
        case .production:
            return [.package(path: "../PassepartoutKit")]
        }
    }

    var targets: [Target] {
        var targets: [Target] = []
        switch self {
        case .localDevelopment:
            targets.append(.binaryTarget(
                name: "Target",
                path: "PassepartoutKit.xcframework.zip"
            ))
        case .onlineDevelopment:
            targets.append(.binaryTarget(
                name: "Target",
                url: "https://github.com/passepartoutvpn/passepartoutkit/releases/download/0.99.0/PassepartoutKit.xcframework.zip",
                checksum: "9b75b289e6043de0044b691b1518a595bd7a7dba0b40be3125ca82d3e528a8e4"
            ))
        case .production:
            targets.append(.target(
                name: "Target",
                dependencies: ["PassepartoutKit"]
            ))
        }
        targets.append(.testTarget(
            name: "TargetTests",
            dependencies: ["Target"]
        ))
        return targets
    }
}

let package = Package(
    name: "PassepartoutKit-Framework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PassepartoutKit-Framework",
            targets: ["Target"]
        )
    ],
    dependencies: environment.dependencies,
    targets: environment.targets
)
