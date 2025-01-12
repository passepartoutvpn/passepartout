// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let environment: Environment
environment = .development

enum Environment {
    case development

    case production

    var dependencies: [Package.Dependency] {
        switch self {
        case .development:
            return []
        case .production:
            return [.package(path: "../PassepartoutKit")]
        }
    }

    var targets: [Target] {
        var targets: [Target] = []
        switch self {
        case .development:
            targets.append(.binaryTarget(
                name: "Target",
                path: "PassepartoutKit.xcframework.zip"
//                url: "https://github.com/passepartoutvpn/passepartoutkit/releases/download/0.0.1/PassepartoutKit.xcframework.zip",
//                checksum: "c5f07fc0d32dfbe800789c2dc276d287340fcac211186f957f414e40b622afb5"
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
