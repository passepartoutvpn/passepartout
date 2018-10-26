//
//  AppConstants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/15/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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
        
        static let filenameCharset: CharacterSet = {
            var chars: CharacterSet = .decimalDigits
            let english = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let symbols = "-_"
            chars.formUnion(CharacterSet(charactersIn: english))
            chars.formUnion(CharacterSet(charactersIn: english.lowercased()))
            chars.formUnion(CharacterSet(charactersIn: symbols))
            return chars
        }()
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
        
        private static let baseURL = Repos.passepartoutAPI.appendingPathComponent("api/\(version)")
        
        static func url(path: String) -> URL {
            return baseURL.appendingPathComponent(path)
        }
        
        static let timeout: TimeInterval = 3.0
        
        static let minimumUpdateInterval: TimeInterval = 600.0 // 10 minutes
    }
    
    class Log {
        static let debugFormat = "$DHH:mm:ss$d - $M"
        
        static var debugSnapshot: () -> String = { TransientStore.shared.service.vpnLog }

        static var debugFilename: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyMMdd-HHmmss"
            let iso = fmt.string(from: Date())
            return "debug-\(iso).txt"
        }
        
        static let viewerRefreshInterval: TimeInterval = 3.0
        
        static func configure() {
            let console = ConsoleDestination()
            console.useNSLog = true
            console.minLevel = .verbose
            SwiftyBeaver.addDestination(console)
        }
    }
    
    class IssueReporter {
        static let recipient = "issues@\(Domain.name)"

        static let attachmentMIME = "text/plain"
    }
    
    class URLs {
        static let website = URL(string: "https://\(Domain.name)")!
        
        static let changelog = Repos.passepartout.appendingPathComponent("blob/master/CHANGELOG.md")
        
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
        private static let githubRoot = URL(string: "https://github.com/keeshux/")!

        private static let githubRawRoot = URL(string: "https://keeshux.github.io/")!
        
        private static func github(repo: String) -> URL {
            return githubRoot.appendingPathComponent(repo)
        }
        
        private static func githubRaw(repo: String) -> URL {
            return githubRawRoot.appendingPathComponent(repo)
        }
        
        static let passepartout = github(repo: "passepartout-ios")

        static let passepartoutAPI = githubRaw(repo: "passepartout-api")
        
        static let tunnelKit = github(repo: "tunnelkit")
    }

    class Notices {
        private static let pia = "PIATunnel - Copyright (c) 2018-Present Private Internet Access"
        
        private static let swiftyBeaver = "SwiftyBeaver - Copyright (c) 2015 Sebastian Kreutzberger"
        
        private static let progressHUD = "MBProgressHUD - Copyright (c) 2009-2016 Matej Bukovinski"

        private static let openVPN = "© 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc."

        private static let openSSL = "This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. https://www.openssl.org/"
        
        static let all: [String] = [
            pia,
            swiftyBeaver,
            progressHUD,
            openVPN,
            openSSL
        ]
    }
}
