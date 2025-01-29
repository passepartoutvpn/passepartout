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
                .package(url: "https://github.com/passepartoutvpn/passepartoutkit", from: "0.99.7")
            ]
        case .production:
            return [
                .package(path: "../PassepartoutKit-Source")
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
                path: "PassepartoutKit.xcframework.zip"
            ))
        case .onlineDevelopment:
            targets.append(.target(
                name: targetName,
                dependencies: [
                    .product(name: "PassepartoutKit-Binary", package: "passepartoutkit")
                ]
            ))
        case .production:
            targets.append(.target(
                name: targetName,
                dependencies: [
                    .product(name: "PassepartoutKit", package: "PassepartoutKit-Source")
                ]
            ))
        }
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
            targets: [environment.targetName]
        )
    ],
    dependencies: environment.dependencies,
    targets: environment.targets
)
