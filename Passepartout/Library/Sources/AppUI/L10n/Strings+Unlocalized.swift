//
//  Strings+Unlocalized.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/2/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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
import PassepartoutKit

extension Strings {
    enum Unlocalized {
        enum OpenVPN {
            enum XOR: String {
                case xormask

                case xorptrpos

                case reverse

                case obfuscate
            }

            static let compLZO = "--comp-lzo"

            static let compress = "--compress"

            static let lzo = "LZO"
        }

        enum Placeholders {
            static let hostname = "example.com"

            static let dohURL = "https://1.2.3.4/some-query"

            static let dotHostname = "dns-hostname.com"

            static let ipV4DNS = "1.1.1.1"

            static func ipDestination(forFamily family: Address.Family) -> String {
                switch family {
                case .v4:
                    return "192.168.15.0/24"

                case .v6:
                    return "fdbd:dcf8:d811:af73::/64"
                }
            }

            static func ipGateway(forFamily family: Address.Family) -> String {
                switch family {
                case .v4:
                    return "192.168.15.1"

                case .v6:
                    return "fdbd:dcf8:d811:af73::1"
                }
            }

            static let mtu = "1500"

            static let proxyIPv4Address = "192.168.1.1"

            static let proxyPort = "1080"

            static let pacURL = "http://proxy.com/pac.url"
        }

        enum Issues {
            static let subject = "\(appName) - Report issue"

            static let attachmentMimeType = "text/plain"

            static let appLogFilename = "app.log"

            static let tunnelLogFilename = "tunnel.log"
        }

        static let appName = "Passepartout"

        static let ca = "CA"

        static let dns = "DNS"

        static let faq = "FAQ"

        static let http = "HTTP"

        static let https = "HTTPS"

        static let httpProxy = "HTTP Proxy"

        static let ip = "IP"

        static let ipv4 = "IPv4"

        static let ipv6 = "IPv6"

        static let mtu = "MTU"

        static let openVPN = "OpenVPN"

        static let otp = "OTP"

        static let pac = "PAC"

        static let proxy = "Proxy"

        static let tls = "TLS"

        static let url = "URL"

        static let uuid = "UUID"

        static let wifi = "Wi-Fi"

        static let wireGuard = "WireGuard"

        static let xor = "XOR"
    }
}
