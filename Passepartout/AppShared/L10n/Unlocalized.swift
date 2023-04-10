//
//  Unlocalized.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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
import PassepartoutLibrary

enum Unlocalized {
    static let appName = Constants.Global.appName

    enum Placeholders {
        static let empty = ""

        static let address = "0.0.0.0"

        static let port = "8080"

        static let hostname = "example.com"

        static let dohURL = "https://example.com/dns-query"

        static let dotServerName = hostname

        static let dnsAddress = address

        static let dnsDomain = hostname

        static let pacURL = "https://proxy/auto-conf"

        static let proxyBypassDomain = hostname
    }

    enum DNS {
        static let plain = "Cleartext"
    }

    enum Keychain {
        static func passwordLabel(_ profileName: String, vpnProtocol: VPNProtocolType) -> String {
            "\(Constants.Global.appName): \(profileName) (\(vpnProtocol.description))"
        }
    }

    enum Issues {
        static let recipient = "issues@\(Constants.Domain.name)"

        static let subject = "\(appName) - Report issue"

        static func body(_ description: String, _ metadata: String) -> String {
            "Hi,\n\n\(description)\n\n\(metadata)\n\nRegards"
        }

        static let template = "description of the issue: "

        static let maxLogBytes = UInt64(20000)

        enum Filenames {
            static var debugLog: String {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyyMMdd-HHmmss"
                let iso = fmt.string(from: Date())
                return "debug-\(iso).txt"
            }

            static let configuration = "profile.ovpn"
//            static let configuration = "profile.ovpn.txt"

            static let template = "description of the issue: "
        }

        enum MIME {
            static let debugLog = "text/plain"

//            static let configuration = "application/x-openvpn-profile"
            static let configuration = "text/plain"
        }
    }

    enum Social {
        static let reddit = "Reddit"

        private static let twitterHashtags = ["OpenVPN", "WireGuard", "iOS", "macOS"]

        static func twitterIntent(withMessage message: String) -> URL {
            var text = message
            for ht in twitterHashtags {
                text = text.replacingOccurrences(of: ht, with: "#\(ht)")
            }
            var comps = URLComponents(string: "https://twitter.com/intent/tweet")!
            comps.queryItems = [
                URLQueryItem(name: "url", value: Constants.URLs.website.absoluteString),
                URLQueryItem(name: "via", value: "keeshux"),
                URLQueryItem(name: "text", value: text)
            ]
            return comps.url!
        }
    }

    enum Translations {
        enum Email {
            static let recipient = "translate@\(Constants.Domain.name)"

            static let subject = "\(appName) - Translations"

            static func body(_ description: String) -> String {
                "Hi,\n\n\(description)\n\nRegards"
            }

            static let template = "I offer to translate to: "
        }

        static let translators: [String: String] = [
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
            "ua": "Dmitry Chirkin",
            "zh-Hans": "OnlyThen"
        ]
    }

    enum Credits {
        static let author = "Davide De Rosa"

        static let licenses: [GenericCreditsView.License] = [.init(
            "Kvitto",
            "BSD",
            URL(string: "https://raw.githubusercontent.com/Cocoanetics/Kvitto/develop/LICENSE")!
        ), .init(
            "lzo",
            "GPLv2",
            URL(string: "https://www.gnu.org/licenses/gpl-2.0.txt")!
        ), .init(
            "OpenSSL",
            "OpenSSL",
            URL(string: "https://raw.githubusercontent.com/openssl/openssl/master/LICENSE.txt")!
        ), .init(
            "PIATunnel",
            "MIT",
            URL(string: "https://raw.githubusercontent.com/pia-foss/tunnel-apple/master/LICENSE")!
        ), .init(
            "SwiftGen",
            "MIT",
            URL(string: "https://raw.githubusercontent.com/SwiftGen/SwiftGen/master/LICENCE")!
        ), .init(
            "SwiftyBeaver",
            "MIT",
            URL(string: "https://raw.githubusercontent.com/SwiftyBeaver/SwiftyBeaver/master/LICENSE")!
        )]

        static let notices: [GenericCreditsView.Notice] = [.init(
            "Circle Icons",
            "The logo is taken from the awesome Circle Icons set by Nick Roach."
        ), .init(
            "Country flags",
            "The country flags are taken from: https://github.com/lipis/flag-icon-css/"
        ), .init(
            "OpenVPN",
            "© Copyright 2022 OpenVPN | OpenVPN is a registered trademark of OpenVPN, Inc."
        ), .init(
            "WireGuard",
            "© Copyright 2015-2022 Jason A. Donenfeld. All Rights Reserved. \"WireGuard\" and the \"WireGuard\" logo are registered trademarks of Jason A. Donenfeld."
        )]
    }

    enum About {
        static let github = "GitHub"

        static let readme = "README"

        static let changelog = "CHANGELOG"

        static let faq = "FAQ"
    }

    enum VPN {
        static let vpn = "VPN"

        static let certificateAuthority = "CA"

        static let xor = "XOR"
    }

    enum OpenVPN {
        static let compLZO = "--comp-lzo"

        static let compress = "--compress"

        static let lzo = "LZO"

        enum XOR: String {
            case xormask

            case xorptrpos

            case reverse

            case obfuscate
        }
    }

    enum Network {
        static let dns = "DNS"

        static let tls = "TLS"

        static let https = "HTTPS"

        static let url = "URL"

        static let mtu = "MTU"

        static let ipv4 = "IPv4"

        static let ipv6 = "IPv6"

        static let ssid = "SSID"

        static let proxyAutoConfiguration = "PAC"
    }

    enum Other {
        static let siri = "Siri"

        static let totp = "TOTP"
    }
}
