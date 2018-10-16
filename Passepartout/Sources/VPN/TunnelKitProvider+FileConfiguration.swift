//
//  TunnelKitProvider+FileConfiguration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/5/18.
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

private let log = SwiftyBeaver.self

extension TunnelKitProvider.Configuration {
    private struct Regex {
        static let proto = Utils.regex("proto +(udp6?|tcp6?)")

        static let port = Utils.regex("port +\\d+")
        
        static let remote = Utils.regex("remote +[^ ]+( +\\d+)?( +(udp6?|tcp6?))?")

        static let cipher = Utils.regex("cipher +[\\w\\-]+")

        static let auth = Utils.regex("auth +[\\w\\-]+")
        
        static let compLZO = Utils.regex("comp-lzo")

        static let compress = Utils.regex("compress")
        
        static let ping = Utils.regex("ping +\\d+")

        static let renegSec = Utils.regex("reneg-sec +\\d+")

        static let fragment = Utils.regex("fragment +\\d+")

        static let keyDirection = Utils.regex("key-direction +\\d")
        
        static let blockBegin = Utils.regex("<[\\w\\-]+>")
        
        static let blockEnd = Utils.regex("<\\/[\\w\\-]+>")
    }
    
    static func parsed(from url: URL) throws -> (String, TunnelKitProvider.Configuration) {
        let content = try String(contentsOf: url)
        let lines = content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

        var defaultProto: TunnelKitProvider.SocketType?
        var defaultPort: UInt16?
        var remotes: [(String, UInt16?, TunnelKitProvider.SocketType?)] = []

        var cipher: SessionProxy.Cipher?
        var digest: SessionProxy.Digest?
        var compressionFraming: SessionProxy.CompressionFraming = .disabled
        var optCA: CryptoContainer?
        var clientCertificate: CryptoContainer?
        var clientKey: CryptoContainer?
        var keepAliveSeconds: Int?
        var renegotiateAfterSeconds: Int?

        var currentBlockName: String?
        var currentBlock: [String] = []
        var unsupportedError: ApplicationError? = nil

        log.verbose("Configuration file:")
        for line in lines {
            log.verbose(line)

            Regex.blockBegin.enumerateComponents(in: line) {
                let tag = $0.first!
                let from = tag.index(after: tag.startIndex)
                let to = tag.index(before: tag.endIndex)

                currentBlockName = String(tag[from..<to])
                currentBlock = []
            }
            Regex.blockEnd.enumerateComponents(in: line) {
                let tag = $0.first!
                let from = tag.index(tag.startIndex, offsetBy: 2)
                let to = tag.index(before: tag.endIndex)

                let blockName = String(tag[from..<to])
                guard blockName == currentBlockName else {
                    return
                }

                // first is opening tag
                currentBlock.removeFirst()
                switch blockName {
                case "ca":
                    optCA = CryptoContainer(pem: currentBlock.joined(separator: "\n"))
                    
                case "cert":
                    clientCertificate = CryptoContainer(pem: currentBlock.joined(separator: "\n"))
                    
                case "key":
                    clientKey = CryptoContainer(pem: currentBlock.joined(separator: "\n"))
                    
                case "tls-auth", "tls-crypt":
                    unsupportedError = ApplicationError.unsupportedConfiguration(option: blockName)
                    
                default:
                    break
                }
                currentBlockName = nil
                currentBlock = []
            }
            if let _ = currentBlockName {
                currentBlock.append(line)
                continue
            }

            Regex.proto.enumerateArguments(in: line) {
                guard let str = $0.first else {
                    return
                }
                defaultProto = TunnelKitProvider.SocketType(protoString: str)
            }
            Regex.port.enumerateArguments(in: line) {
                guard let str = $0.first else {
                    return
                }
                defaultPort = UInt16(str)
            }
            Regex.remote.enumerateArguments(in: line) {
                guard let hostname = $0.first else {
                    return
                }
                var port: UInt16?
                var proto: TunnelKitProvider.SocketType?
                if $0.count > 1 {
                    port = UInt16($0[1])
                }
                if $0.count > 2 {
                    proto = TunnelKitProvider.SocketType(protoString: $0[2])
                }
                remotes.append((hostname, port, proto))
            }
            Regex.cipher.enumerateArguments(in: line) {
                guard let rawValue = $0.first else {
                    return
                }
                cipher = SessionProxy.Cipher(rawValue: rawValue.uppercased())
            }
            Regex.auth.enumerateArguments(in: line) {
                guard let rawValue = $0.first else {
                    return
                }
                digest = SessionProxy.Digest(rawValue: rawValue.uppercased())
            }
            Regex.compLZO.enumerateComponents(in: line) { _ in
                compressionFraming = .compLZO
            }
            Regex.compress.enumerateComponents(in: line) { _ in
                compressionFraming = .compress
            }
            Regex.ping.enumerateArguments(in: line) {
                guard let arg = $0.first else {
                    return
                }
                keepAliveSeconds = Int(arg)
            }
            Regex.renegSec.enumerateArguments(in: line) {
                guard let arg = $0.first else {
                    return
                }
                renegotiateAfterSeconds = Int(arg)
            }
            Regex.fragment.enumerateArguments(in: line) { (_) in
                unsupportedError = ApplicationError.unsupportedConfiguration(option: "fragment")
            }

            if let error = unsupportedError {
                throw error
            }
        }
        
        guard let ca = optCA else {
            throw ApplicationError.missingCA
        }
        
        // XXX: only reads first remote
//        hostnames = remotes.map { $0.0 }
        guard !remotes.isEmpty else {
            throw ApplicationError.emptyRemotes
        }
        let hostname = remotes[0].0
        
        defaultProto = defaultProto ?? .udp
        defaultPort = defaultPort ?? 1194

        // XXX: reads endpoints from remotes with matching hostname
        var endpointProtocols: [TunnelKitProvider.EndpointProtocol] = []
        remotes.forEach {
            guard $0.0 == hostname else {
                return
            }
            guard let port = $0.1 ?? defaultPort else {
                return
            }
            guard let socketType = $0.2 ?? defaultProto else {
                return
            }
            endpointProtocols.append(TunnelKitProvider.EndpointProtocol(socketType, port))
        }
        
        assert(!endpointProtocols.isEmpty, "Must define an endpoint protocol")

        var builder = TunnelKitProvider.ConfigurationBuilder(ca: ca)
        builder.endpointProtocols = endpointProtocols
        builder.cipher = cipher ?? .aes128cbc
        builder.digest = digest ?? .sha1
        builder.compressionFraming = compressionFraming
        builder.clientCertificate = clientCertificate
        builder.clientKey = clientKey
        builder.keepAliveSeconds = keepAliveSeconds
        builder.renegotiatesAfterSeconds = renegotiateAfterSeconds

        return (hostname, builder.build())
    }
}

private extension TunnelKitProvider.SocketType {
    init?(protoString: String) {
        var str = protoString
        if str.hasSuffix("6") {
            str.removeLast()
        }
        self.init(rawValue: str.uppercased())
    }
}

private extension NSRegularExpression {
    func enumerateComponents(in string: String, using block: ([String]) -> Void) {
        enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.count)) { (result, flags, stop) in
            guard let range = result?.range else {
                return
            }
            let match = (string as NSString).substring(with: range)
            let tokens = match.components(separatedBy: " ")
            block(tokens)
        }
    }

    func enumerateArguments(in string: String, using block: ([String]) -> Void) {
        enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.count)) { (result, flags, stop) in
            guard let range = result?.range else {
                return
            }
            let match = (string as NSString).substring(with: range)
            var tokens = match.components(separatedBy: " ")
            tokens.removeFirst()
            block(tokens)
        }
    }
}
