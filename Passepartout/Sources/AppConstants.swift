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
    public class Flags {
        public static let isBeta = false
    }

    public class Domain {
        public static let name = "passepartoutvpn.app"
    }
    
    public class Store {
        public static let serviceFilename = "ConnectionService.json"
        
        public static let webCacheDirectory = "Web"

        public static let providersDirectory = "Providers"

        public static let hostsDirectory = "Hosts"
    }
    
    public class VPN {
        public static var baseConfiguration: TunnelKitProvider.ConfigurationBuilder = {
            let sessionBuilder = SessionProxy.ConfigurationBuilder(ca: CryptoContainer(pem: ""))
            var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
            builder.mtu = 1250
            builder.shouldDebug = true
//            builder.debugLogFormat = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L $N.$F:$l - $M"
//            builder.debugLogFormat = "$DHH:mm:ss$d $N.$F:$l - $M"
            builder.debugLogFormat = Log.debugFormat
            return builder
        }()

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
    
    public class Web {
        private static let version = "v1"
        
        private static let baseURL = Repos.api.appendingPathComponent(version)
        
        public static func url(path: String) -> URL {
            return baseURL.appendingPathComponent(path)
        }
        
        public static let timeout: TimeInterval = 3.0
        
        public static let minimumUpdateInterval: TimeInterval = 600.0 // 10 minutes
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
        public static let recipient = "issues@\(Domain.name)"

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
    
    public class URLs {
        public static let website = URL(string: "https://\(Domain.name)")!
        
        public static let faq = website.appendingPathComponent("faq")

        public static let disclaimer = website.appendingPathComponent("disclaimer")

        public static let privacyPolicy = website.appendingPathComponent("privacy")
        
        public static let changelog = Repos.ios.appendingPathComponent("blob/master/CHANGELOG.md")
        
        public static let subreddit = URL(string: "https://www.reddit.com/r/passepartout")!
        
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
        
        public static let referrals: [Infrastructure.Name: String] = [
            .pia: "https://www.privateinternetaccess.com/pages/buy-vpn/",
            .tunnelBear: "https://click.tunnelbear.com/aff_c?offer_id=2&aff_id=7464"
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
                "SwiftGen",
                "MIT",
                "https://raw.githubusercontent.com/SwiftGen/SwiftGen/master/LICENCE"
            ),
            License(
                "SwiftyBeaver",
                "MIT",
                "https://raw.githubusercontent.com/SwiftyBeaver/SwiftyBeaver/master/LICENSE"
            ),
            License(
                "lzo",
                "GPLv2",
                "https://www.gnu.org/licenses/gpl-2.0.txt"
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
                "OpenVPN",
                "© 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc."
            )
        ]
    }
    
    public struct Rating {
        public static let eventCount = 3
    }
}
