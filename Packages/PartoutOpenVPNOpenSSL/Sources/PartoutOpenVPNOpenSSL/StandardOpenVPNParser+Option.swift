//
//  StandardOpenVPNParser+Option.swift
//  Partout
//
//  Created by Davide De Rosa on 11/30/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

extension StandardOpenVPNParser {
    enum Option: String, CaseIterable {

        // MARK: Continuation

        case continuation = "^push-continuation [12]"

        // MARK: Unsupported

        // check blocks first
        case connectionBlock = "^<connection>"

        case fragment = "^fragment"

        case connectionProxy = "^\\w+-proxy"

        case externalFiles = "^(ca|cert|key|tls-auth|tls-crypt) "

        // MARK: General

        case cipher = "^cipher +[^,\\s]+"

        case dataCiphers = "^(data-ciphers|ncp-ciphers) +[^,\\s]+(:[^,\\s]+)*"

        case dataCiphersFallback = "^data-ciphers-fallback +[^,\\s]+"

        case auth = "^auth +[\\w\\-]+"

        case compLZO = "^comp-lzo.*"

        case compress = "^compress.*"

        case keyDirection = "^key-direction +\\d"

        case ping = "^ping +\\d+"

        case pingRestart = "^ping-restart +\\d+"

        case keepAlive = "^keepalive +\\d+ ++\\d+"

        case renegSec = "^reneg-sec +\\d+"

        case blockBegin = "^<[\\w\\-]+>"

        case blockEnd = "^<\\/[\\w\\-]+>"

        // MARK: Client

        case proto = "^proto +(udp[46]?|tcp[46]?)"

        case port = "^port +\\d+"

        case remote = "^remote +[^ ]+( +\\d+)?( +(udp[46]?|tcp[46]?))?"

        case authUserPass = "^auth-user-pass"

        case staticChallenge = "^static-challenge"

        case eku = "^remote-cert-tls +server"

        case remoteRandom = "^remote-random"

        case remoteRandomHostname = "^remote-random-hostname"

        case mtu = "^tun-mtu +\\d+"

        // MARK: Server

        case authToken = "^auth-token +[a-zA-Z0-9/=+]+"

        case peerId = "^peer-id +[0-9]+"

        // MARK: Routing

        case topology = "^topology +(net30|p2p|subnet)"

        case ifconfig = "^ifconfig +[\\d\\.]+ [\\d\\.]+"

        case ifconfig6 = "^ifconfig-ipv6 +[\\da-fA-F:]+/\\d+ [\\da-fA-F:]+"

        case route = "^route +[\\d\\.]+( +[\\d\\.]+){0,2}"

        case route6 = "^route-ipv6 +[\\da-fA-F:]+/\\d+( +[\\da-fA-F:]+){0,2}"

        case gateway = "^route-gateway +[\\d\\.]+"

        case dns = "^dhcp-option +DNS6? +[\\d\\.a-fA-F:]+"

        case domain = "^dhcp-option +DOMAIN +[^ ]+"

        case domainSearch = "^dhcp-option +DOMAIN-SEARCH +[^ ]+"

        case proxy = "^dhcp-option +PROXY_(HTTPS? +[^ ]+ +\\d+|AUTO_CONFIG_URL +[^ ]+)"

        case proxyBypass = "^dhcp-option +PROXY_BYPASS +.+"

        case redirectGateway = "^redirect-gateway.*"

        case routeNoPull = "^route-nopull"

        // MARK: Extra

        case xorInfo = "^scramble +(xormask|xorptrpos|reverse|obfuscate)[\\s]?([^\\s]+)?"

        func regularExpression() throws -> NSRegularExpression {
            try NSRegularExpression(pattern: rawValue)
        }
    }
}

extension StandardOpenVPNParser.Option {
    var isServerOnly: Bool {
        switch self {
        case .authToken, .peerId:
            return true
        default:
            return false
        }
    }
}
