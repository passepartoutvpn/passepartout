// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let environment: Environment
//environment = .localDevelopment
//environment = .onlineDevelopment
environment = .production

enum Environment {
    case localDevelopment

    case onlineDevelopment

    case production

    var dependencies: [Package.Dependency] {
        switch self {
        case .localDevelopment:
            return []
        case .onlineDevelopment:
            return [
                .package(url: "https://github.com/passepartoutvpn/partout", from: "0.99.50")
            ]
        case .production:
            return [
                .package(path: "../Partout-Source")
            ]
        }
    }

    var targetName: String {
        switch self {
        case .localDevelopment:
            return "LocalDevelopment"
        case .onlineDevelopment:
            return "OnlineDevelopment"
        case .production:
            return "Production"
        }
    }

    var targets: [Target] {
        var targets: [Target] = []
        switch self {
        case .localDevelopment:
            targets.append(.binaryTarget(
                name: targetName,
                path: "Partout.xcframework.zip"
            ))
        case .onlineDevelopment:
            targets.append(.target(
                name: targetName,
                dependencies: [
                    .product(name: "Partout-Binary", package: "partout")
                ]
            ))
        case .production:
            targets.append(.target(
                name: targetName,
                dependencies: [
                    .product(name: "Partout", package: "Partout-Source")
                ]
            ))
        }
        return targets
    }
}

let package = Package(
    name: "Partout-Framework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "Partout-Framework",
            targets: [environment.targetName]
        )
    ],
    dependencies: environment.dependencies,
    targets: environment.targets
)
