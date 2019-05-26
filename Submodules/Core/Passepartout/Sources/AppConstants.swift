//
//  AppConstants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import TunnelKit
import SwiftyBeaver

public class AppConstants {
    public class App {
        public static let appStoreId: String = {
            guard let identifier = GroupConstants.App.config["appstore_id"] as? String else {
                fatalError("Missing appstore_id from Info.plist config")
            }
            return identifier
        }()

        public static let tunnelBundleId: String = {
            guard let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String else {
                fatalError("Missing kCFBundleIdentifierKey from Info.plist")
            }
            return "\(identifier).Tunnel"
        }()
    }

    public class Flags {
        public static let isBeta = false
    }

    public class Domain {
        public static let name = "passepartoutvpn.app"
    }
    
    public class API {
        public static let version = "v2"
    }
    
    public class Store {
        public static let serviceFilename = "ConnectionService.json"

        public static let apiDirectory = "API/\(API.version)"

        public static let webCacheDirectory = "Web"

        public static let providersDirectory = "Providers"

        public static let hostsDirectory = "Hosts"
    }
    
    public class Web {
        private static let baseURL = Repos.api.appendingPathComponent(API.version)
        
        public static func url(path: String) -> URL {
            return baseURL.appendingPathComponent(path)
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
        
        public static let connectivityURL = URL(string: connectivityStrings.customRandomElement())!
        
        public static let connectivityTimeout: TimeInterval = 10.0
    }
    
    public class Log {
        public static let level: SwiftyBeaver.Level = .debug

        public static let debugFormat = "$DHH:mm:ss$d - $M"
        
        public static var debugSnapshot: () -> String = { TransientStore.shared.service.vpnLog }

        public static let viewerRefreshInterval: TimeInterval = 3.0

        private static let fileName = "Debug.log"
        
        public static var fileURL: URL {
            return GroupConstants.App.cachesURL.appendingPathComponent(fileName)
        }

        private static let console: ConsoleDestination = {
            let dest = ConsoleDestination()
            dest.minLevel = level
            dest.useNSLog = true
            return dest
        }()

        private static let file: FileDestination = {
            let dest = FileDestination()
            dest.minLevel = level
            dest.logFileURL = fileURL
            _ = dest.deleteLogFile()
            return dest
        }()
        
        public static func configure() {
            SwiftyBeaver.addDestination(console)
            SwiftyBeaver.addDestination(file)
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

        public static let authorByLanguage: [String: String] = [
            "de": "Christian Lederer",
            "el": "Konstantinos Koukoulakis",
            "es": "Davide De Rosa, Elena Vivó",
            "fr-FR": "Julien Laniel",
            "it": "Davide De Rosa",
            "nl": "Norbert de Vreede",
            "pt-BR": "Helder Santana",
            "ru": "Alexander Korobynikov",
            "sv": "Henry Gross-Hellsen"
        ]
    }

    public class URLs {
        public static let website = URL(string: "https://\(Domain.name)")!
        
        public static let faq = website.appendingPathComponent("faq")

        public static let disclaimer = website.appendingPathComponent("disclaimer")

        public static let privacyPolicy = website.appendingPathComponent("privacy")
        
        public static let readme = Repos.ios.appendingPathComponent("blob/master/README.md")
        
        public static let changelog = Repos.ios.appendingPathComponent("blob/master/CHANGELOG.md")
        
        public static let subreddit = URL(string: "https://www.reddit.com/r/passepartout")!
        
        public static let patreon = URL(string: "https://www.patreon.com/keeshux")!
        
        private static let twitterHashtags = ["OpenVPN", "iOS", "macOS"]
        
        public static var twitterIntent: URL {
            var text = L10n.Share.message
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
        
        public static func review(withId id: String) -> URL {
            return URL(string: "https://itunes.apple.com/app/id\(id)?action=write-review")!
        }
        
        public static let guidances: [Infrastructure.Name: String] = [
            .protonVPN: "https://account.protonvpn.com/settings",
            .windscribe: "https://windscribe.com/getconfig/openvpn"
        ]

        public static let referrals: [Infrastructure.Name: String] = [
            .mullvad: "https://mullvad.net/en/account/create/",
            .nordVPN: "https://go.nordvpn.net/SH21Z",
            .pia: "https://www.privateinternetaccess.com/pages/buy-vpn/",
            .protonVPN: "https://protonvpn.net/?aid=keeshux",
            .tunnelBear: "https://click.tunnelbear.com/SHb8",
            .vyprVPN: "https://www.vyprvpn.com/",
            .windscribe: "https://secure.link/kCsD0prd"
        ]

        public static let externalResources: [Infrastructure.Name: String] = [
            .nordVPN: "https://downloads.nordcdn.com/configs/archives/certificates/servers.zip" // 9MB
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
        
        public static let ios = github(repo: "passepartout-ios")

        public static let api = githubRaw(repo: "api")
    }

    public struct License {
        public let name: String
        
        public let type: String
        
        public let url: URL
        
        public init(_ name: String, _ type: String, _ urlString: String) {
            self.name = name
            self.type = type
            url = URL(string: urlString)!
        }

        public static let all: [License] = [
            License(
                "lzo",
                "GPLv2",
                "https://www.gnu.org/licenses/gpl-2.0.txt"
            ),
            License(
                "MBProgressHUD",
                "MIT",
                "https://raw.githubusercontent.com/jdg/MBProgressHUD/master/LICENSE"
            ),
            License(
                "OpenSSL",
                "OpenSSL",
                "https://www.openssl.org/source/license.txt"
            ),
            License(
                "PIATunnel",
                "MIT",
                "https://raw.githubusercontent.com/pia-foss/tunnel-apple/master/LICENSE"
            ),
            License(
                "SSZipArchive",
                "MIT",
                "https://raw.githubusercontent.com/samsoffes/ssziparchive/master/LICENSE"
            ),
            License(
                "SwiftGen",
                "MIT",
                "https://raw.githubusercontent.com/SwiftGen/SwiftGen/master/LICENCE"
            ),
            License(
                "SwiftyBeaver",
                "MIT",
                "https://raw.githubusercontent.com/SwiftyBeaver/SwiftyBeaver/master/LICENSE"
            )
        ]

        public static var cachedContent: [String: String] = [:]
    }
    
    public struct Notice {
        public let name: String
        
        public let statement: String
        
        public init(_ name: String, _ statement: String) {
            self.name = name
            self.statement = statement
        }
        
        public static let all: [Notice] = [
            Notice(
                "Circle Icons",
                "The logo is taken from the awesome Circle Icons set by Nick Roach."
            ),
            Notice(
                "Country flags",
                "The country flags are taken from: https://github.com/lipis/flag-icon-css/"
            ),
            Notice(
                "OpenVPN",
                "© 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc."
            )
        ]
    }
    
    public struct Rating {
        public static let eventCount = 3
    }
}
