// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// Select how to import the dependency on wxWidgets. The .system
// environment uses dynamic linking and requires wxWidgets to be
// installed on the destination machine. The .vendored value expects
// .a libraries to link to wxWidgets statically (better for release).
// All executables still require the Swift runtime (dynamic).
let wxEnvironment: Wx = .system

let package = Package(
    name: "Passepartout",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../submodules/partout")
    ],
    targets: [
        .target(
            name: "wxWidgets",
            publicHeadersPath: ".",
            cxxSettings: wxEnvironment.cxxSettings,
            linkerSettings: wxEnvironment.linkerSettings
        )
    ]
)

// The UI of the app. The UI does not depend on Partout
// because it relies on OS IPC to communicate with the tunnel.
package.targets.append(contentsOf: [
    .executableTarget(
        name: "ppapp",
        dependencies: ["wxWidgets"],
        cxxSettings: wxEnvironment.cxxSettings,
        linkerSettings: wxEnvironment.linkerSettings
    )
])

// The CLI target and dependencies. Like the UI, the CLI
// does not depend on Partout.
package.targets.append(contentsOf: [
    .executableTarget(
        name: "ppcli"
    )
])

// The tunnel daemon target, the platform-specific bindings
// and dependencies, plus the full Partout library.
package.targets.append(contentsOf: [
    .executableTarget(
        name: "pptunnel",
        dependencies: [
            "Tunnel_C",
            .target(name: "TunnelLinux", condition: .when(platforms: [.linux])),
            .target(name: "TunnelMock_C", condition: .when(platforms: [.macOS])),
            .target(name: "TunnelWindows", condition: .when(platforms: [.windows]))
        ]
    ),
    .target(
        name: "Tunnel_C"
    ),
    .target(
        name: "TunnelLinux",
        dependencies: [
            .target(name: "TunnelLinux_C", condition: .when(platforms: [.linux])),
        ]
    ),
    .target(
        name: "TunnelLinux_C",
        dependencies: [
            "Tunnel_C",
            .product(name: "Partout", package: "partout")
        ]
    ),
    .target(
        name: "TunnelMock_C",
        dependencies: [
            "Tunnel_C",
            .product(name: "Partout", package: "partout")
        ]
    ),
    .target(
        name: "TunnelWindows",
        dependencies: [
            .target(name: "TunnelWindows_C", condition: .when(platforms: [.windows])),
        ]
    ),
    .target(
        name: "TunnelWindows_C",
        dependencies: [
            "Tunnel_C",
            .product(name: "Partout", package: "partout")
        ]
    )
])

// MARK: -

#if arch(arm64)
let arch = "arm64"
#else
let arch = "x86_64"
#endif

#if os(Linux)
let mappedArch = arch == "arm64" ? "aarch64" : arch
#elseif os(Windows)
let mappedArch = arch == "x86_64" ? "x64" : arch
#else
let mappedArch = arch
#endif

// FIXME: ###, arch is hardcoded because unsafeFlags doesn't tolerate interpolation, at least on Windows

enum Wx {
    case system
    case vendored

    // As seen in "wx-config --cxxflags".
    var cxxSettings: [CXXSetting] {
#if os(Linux)
        [
            .unsafeFlags({
                var list: [String] = []
                list.append("-pthread")
                switch self {
                case .system:
                    list.append("-I/usr/include/wx-3.2")
                    list.append("-I/usr/lib/aarch64-linux-gnu/wx/include/gtk3-unicode-3.2")
                case .vendored:
                    list.append("-Ivendors/include")
                    list.append("-Ivendors/lib/linux/include")
                }
                return list
            }()),
            .define("__WXGTK__"),
            .define("_FILE_OFFSET_BITS=64")
        ]
#elseif os(Windows)
        [
            .unsafeFlags({
                var list: [String] = []
                switch self {
                case .system:
                    list.append("-IC:/wxWidgets-3.2.8/include")
                    list.append("-IC:/wxWidgets-3.2.8/arm64/lib/mswu")
                case .vendored:
                    list.append("-Ivendors/include")
                    list.append("-Ivendors/include/msvc")
                }
                return list
            }()),
            .define("__WXMSW__"),
            .define("_FILE_OFFSET_BITS=64"),
            .define("_UNICODE"),
            .define("NDEBUG"),
            .define("wxDEBUG_LEVEL=0")
        ]
#else
        [
            .unsafeFlags({
                var list: [String] = []
                switch self {
                case .system:
                    list.append("-I/opt/homebrew/include/wx-3.3")
                    list.append("-I/opt/homebrew/lib/wx/include/osx_cocoa-unicode-3.3")
                case .vendored:
                    list.append("-Ivendors/include")
                    list.append("-Ivendors/lib/mac/include")
                }
                return list
            }()),
            .define("__WXMAC__"),
            .define("__WXOSX__"),
            .define("__WXOSX_COCOA__"),
            .define("_FILE_OFFSET_BITS=64"),
            .define("wxDEBUG_LEVEL=0")
        ]
#endif
    }

    // As seen in "wx-config --libs".
    var linkerSettings: [LinkerSetting] {
#if os(Linux)
        [
            .unsafeFlags({
                var list: [String] = []
                switch self {
                case .system:
                    list.append("-L/usr/lib/aarch64-linux-gnu")
                case .vendored:
                    list.append("-Lvendors/lib/linux/\(arch)")
                }
                return list
            }()),
            .linkedLibrary("pthread"),
            .linkedLibrary("wx_baseu-3.2"),
            .linkedLibrary("wx_baseu_net-3.2"),
            .linkedLibrary("wx_gtk3u_core-3.2")
        ]
#elseif os(Windows)
        [
            .unsafeFlags({
                var list: [String] = []
                switch self {
                case .system:
                    list.append("-LC:/wxWidgets-3.2.8/arm64/lib")
                case .vendored:
                    list.append("-Lvendors/lib/windows/\(arch)")
                }
                let otherLibs = "wxtiff wxjpeg wxpng wxzlib wxregexu wxexpat"
                otherLibs.split(separator: " ").forEach {
                    list.append("-l\($0)")
                }
                let winLibs = "advapi32 comctl32 comdlg32 gdi32 gdiplus imm32 kernel32 msimg32 ole32 oleacc oleaut32 opengl32 rpcrt4 shell32 shlwapi user32 uuid uxtheme version wininet winmm winspool ws2_32"
                winLibs.split(separator: " ").forEach {
                    list.append("-l\($0)")
                }
                return list
            }()),
            .linkedLibrary("wxbase32u"),
            .linkedLibrary("wxbase32u_net"),
            .linkedLibrary("wxmsw32u_core"),
            .linkedLibrary("swiftCore") // complains about swift_addNewDSOImage
        ]
#else
        [
            .unsafeFlags({
                var list: [String] = []
                switch self {
                case .system:
                    list.append("-L/opt/homebrew/lib")
                case .vendored:
                    list.append("-Lvendors/lib/mac/\(arch)")
                }
                return list
            }()),
            .linkedLibrary("pthread"),
            .linkedLibrary("wx_baseu-3.3"),
            .linkedLibrary("wx_baseu_net-3.3"),
            .linkedLibrary("wx_osx_cocoau_core-3.3")
        ]
#endif
    }
}
