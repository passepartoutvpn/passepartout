//
//  Shared.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/16/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PassepartoutKit
import PassepartoutWireGuardGo

enum Demo {
}

// MARK: Constants

extension Demo {
    private static let appConfig = BundleConfiguration(.main, key: "AppConfig")!

    static var teamIdentifier: String {
        appConfig.value(forKey: "team_id")!
    }

    static var appIdentifier: String {
        appConfig.value(forKey: "app_id")!
    }

    static var appGroupIdentifier: String {
        appConfig.value(forKey: "group_id")!
    }

    static var tunnelBundleIdentifier: String {
        appConfig.value(forKey: "tunnel_id")!
    }

    static var cachesURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("Unable to access App Group container")
        }
        return url.appending(components: "Library", "Caches")
    }

    static func moduleURL(for name: String) -> URL {
        do {
            let url = cachesURL.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        } catch {
            fatalError("No access to caches directory")
        }
    }
}

extension Demo {
    enum Log {
        static let tunnelURL = Demo.cachesURL.appending(component: "tunnel.log")

        static let maxNumberOfLines = 2000

        static let maxLevel: DebugLog.Level = .info

        static let saveInterval = 60000

        static func formattedLine(_ line: DebugLog.Line) -> String {
            let ts = line.timestamp
                .formatted(
                    .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute()
                        .second()
                )

            return "\(ts) - \(line.message)"
        }
    }
}

// MARK: - Implementations

extension Demo {
    static var neProtocolCoder: KeychainNEProtocolCoder {
        KeychainNEProtocolCoder(
            tunnelBundleIdentifier: Demo.tunnelBundleIdentifier,
            registry: .shared,
            coder: CodableProfileCoder(),
            keychain: AppleKeychain(group: "\(teamIdentifier).\(appGroupIdentifier)")
        )
    }

    static var environment: AppGroupEnvironment {
        AppGroupEnvironment(appGroup: appGroupIdentifier)
    }
}

extension TunnelEnvironment where Self == AppGroupEnvironment {
    static var shared: Self {
        Demo.environment
    }
}
