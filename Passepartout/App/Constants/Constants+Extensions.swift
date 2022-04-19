//
//  Constants+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutCore
import SwiftyBeaver

extension Constants {
    private static let bundleConfig = Bundle.main.infoDictionary?["com.algoritmico.Passepartout.config"] as? [String: Any]
}

extension Constants {
    enum App {
        static let appLauncherId = bundleConfig?["app_launcher_id"] as? String ?? "DUMMY_app_launcher_id"

        static let appStoreId = bundleConfig?["appstore_id"] as? String ?? "DUMMY_appstore_id"

        static let appGroupId = bundleConfig?["group_id"] as? String ?? "DUMMY_group_id"

        static func tunnelBundleId(_ vpnProtocol: VPNProtocolType) -> String {
            guard let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String else {
                fatalError("Missing kCFBundleIdentifierKey from Info.plist")
            }
            switch vpnProtocol {
            case .openVPN:
                return "\(identifier).OpenVPNTunnel"

            case .wireGuard:
                return "\(identifier).WireGuardTunnel"
            }
        }
    }

    enum InApp {
        static var appType: ProductManager.AppType {
            if let envString = ProcessInfo.processInfo.environment["APP_TYPE"],
               let envValue = Int(envString),
               let testAppType = ProductManager.AppType(rawValue: envValue) {

                return testAppType
            }
            if let infoValue = bundleConfig?["app_type"] as? Int,
               let testAppType = ProductManager.AppType(rawValue: infoValue) {

                return testAppType
            }
            return isBeta ? .beta : .freemium
        }

        #if targetEnvironment(macCatalyst)
        static let lastFullVersionBuild: (Int, LocalProduct) = (0, .fullVersion_macOS)
        #else
        static let lastFullVersionBuild: (Int, LocalProduct) = (2016, .fullVersion_iOS)
        #endif
        
        static let lastNetworkSettingsBuild = 2999

        private static var isBeta: Bool {
            #if targetEnvironment(simulator)
            return true
            #else
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
            #endif
        }
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
        
        static let vpnManager = 500
    }
    
    enum Log {
        static let logLevel: SwiftyBeaver.Level = {
            guard let levelString = ProcessInfo.processInfo.environment["LOG_LEVEL"], let levelNum = Int(levelString) else {
                return .info
            }
            return .init(rawValue: levelNum) ?? .info
        }()
        
        static let appLogFormat = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        
        private static let appFileName = "Debug.log"
        
        static var appFileURL: URL {
            return Files.cachesURL.appendingPathComponent(appFileName)
        }

        static let tunnelLogFormat = "$DHH:mm:ss$d - $M"
        
        static let tunnelLogMaxBytes = 15000
        
        static let tunnelLogRefreshInterval: TimeInterval = 5.0
    }
    
    enum URLs {
        static let readme = Repos.apple.appendingPathComponent("blob/master/README.md")
        
        enum iOS {
            static let changelog = Repos.apple.appendingPathComponent("blob/master/Passepartout/App/iOS/CHANGELOG.md")
        }

        enum macOS {
            static let changelog = Repos.apple.appendingPathComponent("blob/master/Passepartout/App/macOS/CHANGELOG.md")
        }
        
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
        
        static let alternativeTo = URL(string: "https://alternativeto.net/software/passepartout-vpn/about/")!
        
        static let openVPNGuidances: [ProviderName: String] = [
            .protonvpn: "https://account.protonvpn.com/settings",
            .surfshark: "https://my.surfshark.com/vpn/manual-setup/main",
            .torguard: "https://torguard.net/clientarea.php?action=changepw",
            .windscribe: "https://windscribe.com/getconfig/openvpn"
        ]

        static let referrals: [ProviderName: String] = [
            .hideme: "https://member.hide.me/en/checkout?plan=new_default_prices&coupon=6CB-BDB-802&duration=24",
            .mullvad: "https://mullvad.net/en/account/create/",
            .nordvpn: "https://go.nordvpn.net/SH21Z",
            .pia: "https://www.privateinternetaccess.com/pages/buy-vpn/",
            .protonvpn: "https://proton.go2cloud.org/SHZ",
            .torguard: "https://torguard.net/",
            .tunnelbear: "https://www.tunnelbear.com/",
            .vyprvpn: "https://www.vyprvpn.com/",
            .windscribe: "https://secure.link/kCsD0prd"
        ]
    }

    enum Repos {
        private static let githubRoot = URL(string: "https://github.com/passepartoutvpn/")!

        private static let githubRawRoot = URL(string: "https://\(Domain.name)/")!
        
        private static func github(repo: String) -> URL {
            return githubRoot.appendingPathComponent(repo)
        }
        
        private static func githubRaw(repo: String) -> URL {
            return githubRawRoot.appendingPathComponent(repo)
        }
        
        static let apple = github(repo: "passepartout-apple")
        
        static let api = githubRaw(repo: "api")
    }

    // milliseconds
    enum Delays {
        static let scrolling = 100
        
//        @available(*, deprecated, message: "for weird animation when using withAnimation() in View.onAppear")
        static let xxxAnimateOnAppear = 200
        
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
        private static var containerURL: URL {
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: App.appGroupId) else {
                print("Unable to access App Group container")
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            }
            return url
        }

        static let cachesURL: URL = {
            let url = containerURL.appendingPathComponent("Library/Caches", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        }()
    }
}
