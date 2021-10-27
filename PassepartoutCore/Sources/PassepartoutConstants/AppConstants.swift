//
//  AppConstants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

public class AppConstants {
    public class App {
        public static let appLauncherId = GroupConstants.App.config?["app_launcher_id"] as? String ?? "DUMMY_app_launcher_id"

        public static let appStoreId = GroupConstants.App.config?["appstore_id"] as? String ?? "DUMMY_appstore_id"

        public static let tunnelBundleId: String = {
            guard let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String else {
                fatalError("Missing kCFBundleIdentifierKey from Info.plist")
            }
            return "\(identifier).Tunnel"
        }()
    }

    public class Domain {
        public static let name = "passepartoutvpn.app"
    }
    
    public class Store {
        public static let serviceFilename = "ConnectionService.json"

        public static let apiDirectory = "API/\(Services.version)"

        public static let providersDirectory = "Providers"

        public static let hostsDirectory = "Hosts"
    }

    public class Services {
        public static let version = "v4"

        public static func apiURL(version: String, path: String) -> URL {
            return Repos.api.appendingPathComponent(version).appendingPathComponent(path)
        }
        
        public static let timeout: TimeInterval = 3.0
        
        public static let minimumUpdateInterval: TimeInterval = 600.0 // 10 minutes

        private static let connectivityStrings: [String] = [
            "https://www.amazon.com",
            "https://www.google.com",
            "https://www.twitter.com",
            "https://www.facebook.com",
            "https://www.instagram.com"
        ]
        
        public static let connectivityURL = URL(string: connectivityStrings.randomElement()!)!
        
        public static let connectivityTimeout: TimeInterval = 10.0
    }
    
    public class Log {
        public static let debugFormat = "$DHH:mm:ss$d - $M"
        
        public static let viewerRefreshInterval: TimeInterval = 3.0

        private static let fileName = "Debug.log"
        
        public static var fileURL: URL {
            return GroupConstants.App.cachesURL.appendingPathComponent(fileName)
        }
    }
    
    public class IssueReporter {
        public class Email {
            public static let recipient = "issues@\(Domain.name)"
            
            public static let subject = "\(GroupConstants.App.name) - Report issue"
            
            public static func body(_ description: String, _ metadata: String) -> String {
                return "Hi,\n\n\(description)\n\n\(metadata)\n\nRegards"
            }
            
            public static let template = "description of the issue: "
        }

        public class Filenames {
            public static var debugLog: String {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyyMMdd-HHmmss"
                let iso = fmt.string(from: Date())
                return "debug-\(iso).txt"
            }
            
            public static let configuration = "profile.ovpn"
//            public static let configuration = "profile.ovpn.txt"
        }
        
        public class MIME {
            public static let debugLog = "text/plain"

//            public static let configuration = "application/x-openvpn-profile"
            public static let configuration = "text/plain"
        }
    }

    public class Translations {
        public class Email {
            public static let recipient = "translate@\(Domain.name)"

            public static let subject = "\(GroupConstants.App.name) - Translations"
            
            public static func body(_ description: String) -> String {
                return "Hi,\n\n\(description)\n\nRegards"
            }

            public static let template = "I offer to translate to: "
        }

        public static let translators: [String: String] = [
            "de": "Christian Lederer, Theodor Tietze",
            "el": "Konstantinos Koukoulakis",
            "en-US": "Davide De Rosa",
            "es": "Davide De Rosa, Elena Vivó",
            "fr-FR": "Julien Laniel",
            "it": "Davide De Rosa",
            "nl": "Norbert de Vreede",
            "pl": "Piotr Książek",
            "pt-BR": "Helder Santana",
            "ru": "Alexander Korobynikov",
            "sv": "Henry Gross-Hellsen",
            "zh-Hans": "OnlyThen"
        ]
    }

    public class URLs {
        public static let readme = Repos.apple.appendingPathComponent("blob/master/README.md")
        
        public class iOS {
            public static let changelog = Repos.apple.appendingPathComponent("blob/master/Passepartout/App/iOS/CHANGELOG.md")
        }

        public class macOS {
            public static let changelog = Repos.apple.appendingPathComponent("blob/master/Passepartout/App/macOS/CHANGELOG.md")
        }
        
        public static let filetypes = ["public.content", "public.data"]

        public static let website = URL(string: "https://\(Domain.name)")!
        
        public static let faq = website.appendingPathComponent("faq")

        public static let disclaimer = website.appendingPathComponent("disclaimer")

        public static let privacyPolicy = website.appendingPathComponent("privacy")
        
        public static let donate = website.appendingPathComponent("donate")
        
        public static let subreddit = URL(string: "https://www.reddit.com/r/passepartout")!
        
        public static let twitch = URL(string: "twitch://stream/keeshux")!
        
        public static let twitchFallback = URL(string: "https://twitch.tv/keeshux")!
        
        public static let githubSponsors = URL(string: "https://www.github.com/sponsors/passepartoutvpn")!
        
        public static let alternativeTo = URL(string: "https://alternativeto.net/software/passepartout-vpn/about/")!
        
        private static let twitterHashtags = ["OpenVPN", "iOS", "macOS"]
        
        public static func twitterIntent(withMessage message: String) -> URL {
            var text = message
            for ht in twitterHashtags {
                text = text.replacingOccurrences(of: ht, with: "#\(ht)")
            }
            var comps = URLComponents(string: "https://twitter.com/intent/tweet")!
            comps.queryItems = [
                URLQueryItem(name: "url", value: website.absoluteString),
                URLQueryItem(name: "via", value: "keeshux"),
                URLQueryItem(name: "text", value: text)
            ]
            return comps.url!
        }
        
        public static let guidances: [InfrastructureName: String] = [
            .protonvpn: "https://account.protonvpn.com/settings",
            .surfshark: "https://my.surfshark.com/vpn/manual-setup/main",
            .torguard: "https://torguard.net/clientarea.php?action=changepw",
            .windscribe: "https://windscribe.com/getconfig/openvpn"
        ]

        public static let referrals: [InfrastructureName: String] = [
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

        public static let externalResources: [InfrastructureName: String] = [
            .nordvpn: "https://downloads.nordcdn.com/configs/archives/certificates/servers.zip" // 9MB
        ]
    }

    public class Repos {
        private static let githubRoot = URL(string: "https://github.com/passepartoutvpn/")!

        private static let githubRawRoot = URL(string: "https://\(Domain.name)/")!
        
        private static func github(repo: String) -> URL {
            return githubRoot.appendingPathComponent(repo)
        }
        
        private static func githubRaw(repo: String) -> URL {
            return githubRawRoot.appendingPathComponent(repo)
        }
        
        public static let apple = github(repo: "passepartout-apple")
        
        public static let api = githubRaw(repo: "api")
    }

    public struct Placeholders {
        public static let empty = ""

        public static let address = "0.0.0.0"

        public static let hostname = "example.com"

        public static let dohURL = "https://example.com/dns-query"
        
        public static let dotServerName = hostname

        public static let dnsAddress = address

        public static let dnsDomain = empty
    }

    public struct Credits {
        public static let author = "Davide De Rosa"

        public static let softwareArrays: [[String]] = [[
            "Kvitto",
            "BSD",
            "https://raw.githubusercontent.com/Cocoanetics/Kvitto/develop/LICENSE"
        ], [
            "lzo",
            "GPLv2",
            "https://www.gnu.org/licenses/gpl-2.0.txt"
        ], [
            "MBProgressHUD",
            "MIT",
            "https://raw.githubusercontent.com/jdg/MBProgressHUD/master/LICENSE"
        ], [
            "OpenSSL",
            "OpenSSL",
            "https://www.openssl.org/source/license.txt"
        ], [
            "PIATunnel",
            "MIT",
            "https://raw.githubusercontent.com/pia-foss/tunnel-apple/master/LICENSE"
        ], [
            "SSZipArchive",
            "MIT",
            "https://raw.githubusercontent.com/samsoffes/ssziparchive/master/LICENSE"
        ], [
            "SwiftGen",
            "MIT",
            "https://raw.githubusercontent.com/SwiftGen/SwiftGen/master/LICENCE"
        ], [
            "SwiftyBeaver",
            "MIT",
            "https://raw.githubusercontent.com/SwiftyBeaver/SwiftyBeaver/master/LICENSE"
        ], [
            "Circle Icons",
            "The logo is taken from the awesome Circle Icons set by Nick Roach."
        ], [
            "Country flags",
            "The country flags are taken from: https://github.com/lipis/flag-icon-css/"
        ], [
            "OpenVPN",
            "© 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc."
        ]]
    }

    public struct Rating {
        #if os(iOS)
        public static let eventCount = 3
        #else
        public static let eventCount = 10
        #endif
    }

    public struct InApp {
        public static let locksBetaFeatures = true

        #if os(iOS)
        public static var isBetaFullVersion: Bool {
            return ProcessInfo.processInfo.environment["FULL_VERSION"] != nil
        }

        public static let lastFullVersionBuild: (Int, LocalProduct) = (2016, .fullVersion_iOS)
        #else
        public static let isBetaFullVersion = false

        public static let lastFullVersionBuild: (Int, LocalProduct) = (0, .fullVersion_macOS)
        #endif
    }
}
