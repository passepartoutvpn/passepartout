//
//  AppConstants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

class AppConstants {
    class Domain {
        static let name = "passepartoutvpn.app"
    }
    
    class Store {
        static let serviceFilename = "ConnectionService.json"
        
        static let infrastructureCacheDirectory = "Infrastructures"

        static let providersDirectory = "Providers"

        static let hostsDirectory = "Hosts"
    }
    
    class VPN {
        static func baseConfiguration() -> TunnelKitProvider.Configuration {
            let sessionBuilder = SessionProxy.ConfigurationBuilder(ca: CryptoContainer(pem: ""))
            var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
            builder.mtu = 1250
            builder.shouldDebug = true
//            builder.debugLogFormat = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L $N.$F:$l - $M"
//            builder.debugLogFormat = "$DHH:mm:ss$d $N.$F:$l - $M"
            builder.debugLogFormat = Log.debugFormat
            return builder.build()
        }
        
        private static let connectivityStrings: [String] = [
            "https://www.amazon.com",
            "https://www.google.com",
            "https://www.twitter.com",
            "https://www.facebook.com",
            "https://www.instagram.com"
        ]
        
        static let connectivityURL = URL(string: connectivityStrings.customRandomElement())!
        
        static let connectivityTimeout: TimeInterval = 10.0
    }
    
    class Web {
        private static let version = "v2"
        
        private static let baseURL = Repos.api.appendingPathComponent("api/\(version)")
        
        static func url(path: String) -> URL {
            return baseURL.appendingPathComponent(path)
        }
        
        static let timeout: TimeInterval = 3.0
        
        static let minimumUpdateInterval: TimeInterval = 600.0 // 10 minutes
    }
    
    class Log {
        static let debugFormat = "$DHH:mm:ss$d - $M"
        
        static var debugSnapshot: () -> String = { TransientStore.shared.service.vpnLog }

        static let viewerRefreshInterval: TimeInterval = 3.0
        
        static func configure() {
            let console = ConsoleDestination()
            console.useNSLog = true
            console.minLevel = .debug
            SwiftyBeaver.addDestination(console)
        }
    }
    
    class IssueReporter {
        static let recipient = "issues@\(Domain.name)"

        class Filenames {
            static var debugLog: String {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyyMMdd-HHmmss"
                let iso = fmt.string(from: Date())
                return "debug-\(iso).txt"
            }
            
            static let configuration = "profile.ovpn"
//            static let configuration = "profile.ovpn.txt"
        }
        
        class MIME {
            static let debugLog = "text/plain"

//            static let configuration = "application/x-openvpn-profile"
            static let configuration = "text/plain"
        }
    }
    
    class URLs {
        static let website = URL(string: "https://\(Domain.name)")!
        
        static let disclaimer = website.appendingPathComponent("disclaimer")

        static let privacyPolicy = website.appendingPathComponent("privacy")
        
        static let changelog = Repos.ios.appendingPathComponent("blob/master/CHANGELOG.md")
        
        static let subreddit = URL(string: "https://www.reddit.com/r/passepartout")!
        
        private static let twitterHashtags = ["OpenVPN", "iOS", "macOS"]
        
        static var twitterIntent: URL {
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
        
        static func review(withId id: String) -> URL {
            return URL(string: "https://itunes.apple.com/app/id\(id)?action=write-review")!
        }
    }

    class Repos {
        private static let githubRoot = URL(string: "https://github.com/passepartoutvpn/")!

        private static let githubRawRoot = URL(string: "https://passepartoutvpn.github.io/")!
        
        private static func github(repo: String) -> URL {
            return githubRoot.appendingPathComponent(repo)
        }
        
        private static func githubRaw(repo: String) -> URL {
            return githubRawRoot.appendingPathComponent(repo)
        }
        
        static let ios = github(repo: "passepartout-ios")

        static let api = githubRaw(repo: "passepartout-api")
    }

    struct License {
        let name: String
        
        let type: String
        
        let url: URL
        
        init(_ name: String, _ type: String, _ urlString: String) {
            self.name = name
            self.type = type
            url = URL(string: urlString)!
        }

        static let all: [License] = [
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
                "https://raw.githubusercontent.com/SwiftGen/SwiftGen/master/LICENSE"
            ),
            License(
                "SwiftyBeaver",
                "MIT",
                "https://raw.githubusercontent.com/SwiftyBeaver/SwiftyBeaver/master/LICENSE"
            )
        ]

        static var cachedContent: [String: String] = [:]
    }
    
    struct Notice {
        let name: String
        
        let statement: String
        
        init(_ name: String, _ statement: String) {
            self.name = name
            self.statement = statement
        }
        
        static let all: [Notice] = [
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
}
