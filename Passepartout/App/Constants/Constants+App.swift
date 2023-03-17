//
//  Constants+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import UniformTypeIdentifiers
import SwiftyBeaver

extension Constants {
    enum App {
        static var appId: String {
            guard let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String else {
                fatalError("Missing kCFBundleIdentifierKey from Info.plist")
            }
            return identifier
        }

        static let appStoreId: String = bundleConfig("appstore_id")

        static let appGroupId: String = bundleConfig("group_id")

        static let isBeta: Bool = {
            Bundle.main.isTestFlight
        }()
    }

    enum Plugins {
        static let macBridgeName = "PassepartoutMac.bundle"
    }

    enum InApp {
        static var appType: ProductManager.AppType {
            if let envString = ProcessInfo.processInfo.environment["APP_TYPE"],
               let envValue = Int(envString),
               let testAppType = ProductManager.AppType(rawValue: envValue) {

                return testAppType
            }
            if let infoValue: Int = bundleConfig("app_type"),
               let testAppType = ProductManager.AppType(rawValue: infoValue) {

                return testAppType
            }
            return App.isBeta ? .beta : .freemium
        }

        #if targetEnvironment(macCatalyst)
        static let buildProducts = BuildProducts {
            if $0 <= 3000 {
                return [.networkSettings]
            }
            return []
        }
        #else
        static let buildProducts = BuildProducts {
            if $0 <= 2016 {
                return [.fullVersion_iOS]
            } else if $0 <= 3000 {
                return [.networkSettings]
            }
            return []
        }
        #endif
    }
}

extension Constants {
    enum Activities {
        static let enableVPN = "EnableVPNIntent"

        static let disableVPN = "DisableVPNIntent"

        static let connectVPN = "ConnectVPNIntent"

        static let moveToLocation = "MoveToLocationIntent"

        static let trustCellularNetwork = "TrustCellularNetworkIntent"

        static let trustCurrentNetwork = "TrustCurrentNetworkIntent"

        static let untrustCellularNetwork = "UntrustCellularNetworkIntent"

        static let untrustCurrentNetwork = "UntrustCurrentNetworkIntent"
    }
}

extension Constants {
    enum Domain {
        static let name = "passepartoutvpn.app"
    }

    enum Services {
        static let version = "v5"

        private static let connectivityStrings: [String] = [
            "https://www.amazon.com",
            "https://www.google.com",
            "https://www.twitter.com",
            "https://www.facebook.com",
            "https://www.instagram.com"
        ]

        static let connectivityURL = URL(string: connectivityStrings.randomElement()!)!

        static let connectivityTimeout: TimeInterval = 10.0
    }

    enum Persistence {
        static let profilesContainerName = "Profiles"

        static let providersContainerName = "Providers"
    }

    // milliseconds
    enum RateLimit {
        static let providerManager = 10000

        static let vpnToggle = 500
    }

    enum Log {
        enum App {
            static let url = containerURL(filename: "App.log")

            static let format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        }

        enum Tunnel {
            static let path = containerPath(filename: "Tunnel.log")

            static let format = "$DHH:mm:ss$d - $M"
        }

        private static let parentPath = "Library/Caches"

        static let level: SwiftyBeaver.Level = {
            guard let levelString = ProcessInfo.processInfo.environment["LOG_LEVEL"], let levelNum = Int(levelString) else {
                return .info
            }
            return .init(rawValue: levelNum) ?? .info
        }()

        static let maxBytes = 100000

        static let refreshInterval: TimeInterval = 5.0

        private static func containerURL(filename: String) -> URL {
            Files.containerURL
                .appendingPathComponent(parentPath)
                .appendingPathComponent(filename)
        }

        private static func containerPath(filename: String) -> String {
            "\(parentPath)/\(filename)"
        }
    }

    enum URLs {
        static let readme = Repos.apple.appendingPathComponent("blob/master/README.md")

        static let changelog = Repos.apple.appendingPathComponent("blob/master/CHANGELOG.md")

        static let filetypes: [UTType] = [.item]

        static let website = URL(string: "https://\(Domain.name)")!

        static let faq = website.appendingPathComponent("faq")

        static let disclaimer = website.appendingPathComponent("disclaimer")

        static let privacyPolicy = website.appendingPathComponent("privacy")

        static let donate = website.appendingPathComponent("donate")

        static let subreddit = URL(string: "https://www.reddit.com/r/passepartout")!

        static let twitch = URL(string: "twitch://stream/keeshux")!

        static let twitchFallback = URL(string: "https://twitch.tv/keeshux")!

        static let githubSponsors = URL(string: "https://www.github.com/sponsors/passepartoutvpn")!
    }

    enum Repos {
        private static let githubRoot = URL(string: "https://github.com/passepartoutvpn/")!

        private static let githubRawRoot = URL(string: "https://\(Domain.name)/")!

        private static func github(repo: String) -> URL {
            githubRoot.appendingPathComponent(repo)
        }

        private static func githubRaw(repo: String) -> URL {
            githubRawRoot.appendingPathComponent(repo)
        }

        static let apple = github(repo: "passepartout-apple")

        static let api = githubRaw(repo: "api")
    }

    // milliseconds
    enum Delays {
        static let scrolling = 100

//        @available(*, deprecated, message: "file importer stops showing again after closing with swipe down")
        static let xxxPresentFileImporter = 200

//        @available(*, deprecated, message: "edited shortcut is outdated in delegate")
        static let xxxReloadEditedShortcut = 200
    }

    enum Rating {
        #if targetEnvironment(macCatalyst)
        static let eventCount = 10
        #else
        static let eventCount = 3
        #endif
    }
}

extension Constants {
    enum Files {
        fileprivate static var containerURL: URL {
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: App.appGroupId) else {
                print("Unable to access App Group container")
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            }
            return url
        }
    }
}
