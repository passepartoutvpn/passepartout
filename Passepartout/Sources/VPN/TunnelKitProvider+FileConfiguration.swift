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

struct ParsedFile {
    let url: URL
    
    let hostname: String
    
    let configuration: TunnelKitProvider.Configuration
    
    let strippedLines: [String]?
    
    let warning: ApplicationError?
}

extension TunnelKitProvider.Configuration {
    private struct Regex {
        static let proto = Utils.regex("^proto +(udp6?|tcp6?)")

        static let port = Utils.regex("^port +\\d+")
        
        static let remote = Utils.regex("^remote +[^ ]+( +\\d+)?( +(udp6?|tcp6?))?")

        static let cipher = Utils.regex("^cipher +[\\w\\-]+")

        static let auth = Utils.regex("^auth +[\\w\\-]+")
        
        static let compLZO = Utils.regex("^comp-lzo.*")

        static let compress = Utils.regex("^compress.*")
        
        static let ping = Utils.regex("^ping +\\d+")

        static let renegSec = Utils.regex("^reneg-sec +\\d+")

        static let keyDirection = Utils.regex("^key-direction +\\d")
        
        static let blockBegin = Utils.regex("^<[\\w\\-]+>")
        
        static let blockEnd = Utils.regex("^<\\/[\\w\\-]+>")

        // unsupported

//        static let fragment = Utils.regex("^fragment +\\d+")
        static let fragment = Utils.regex("^fragment")

        static let proxy = Utils.regex("^\\w+-proxy")

        static let externalFiles = Utils.regex("^(ca|cert|key|tls-auth|tls-crypt) ")
    }
    
    static func parsed(from url: URL, returnsStripped: Bool = false) throws -> ParsedFile {
        let lines = try String(contentsOf: url).trimmedLines()
        var strippedLines: [String]? = returnsStripped ? [] : nil
        var warning: ApplicationError? = nil

        var defaultProto: TunnelKitProvider.SocketType?
        var defaultPort: UInt16?
        var remotes: [(String, UInt16?, TunnelKitProvider.SocketType?)] = []

        var cipher: SessionProxy.Cipher?
        var digest: SessionProxy.Digest?
        var compressionFraming: SessionProxy.CompressionFraming = .disabled
        var optCA: CryptoContainer?
        var clientCertificate: CryptoContainer?
        var clientKey: CryptoContainer?
        var keepAliveSeconds: TimeInterval?
        var renegotiateAfterSeconds: TimeInterval?
        var keyDirection: StaticKey.Direction?
        var tlsStrategy: SessionProxy.TLSWrap.Strategy?
        var tlsKeyLines: [Substring]?
        var tlsWrap: SessionProxy.TLSWrap?

        var currentBlockName: String?
        var currentBlock: [String] = []
        var unsupportedError: ApplicationError? = nil

        log.verbose("Configuration file:")
        for line in lines {
            log.verbose(line)

            var isHandled = false
            var strippedLine = line
            defer {
                if isHandled {
                    strippedLines?.append(strippedLine)
                }
            }

            Regex.blockBegin.enumerateComponents(in: line) {
                isHandled = true
                let tag = $0.first!
                let from = tag.index(after: tag.startIndex)
                let to = tag.index(before: tag.endIndex)

                currentBlockName = String(tag[from..<to])
                currentBlock = []
            }
            Regex.blockEnd.enumerateComponents(in: line) {
                isHandled = true
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
                    let container = CryptoContainer(pem: currentBlock.joined(separator: "\n"))
                    clientKey = container
                    if container.isEncrypted {
                        unsupportedError = ApplicationError.unsupportedConfiguration(option: "encrypted client certificate key")
                    }
                    
                case "tls-auth":
                    tlsKeyLines = currentBlock.map { Substring($0) }
                    tlsStrategy = .auth
                    
                case "tls-crypt":
                    tlsKeyLines = currentBlock.map { Substring($0) }
                    tlsStrategy = .crypt
                    
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
                isHandled = true
                guard let str = $0.first else {
                    return
                }
                defaultProto = TunnelKitProvider.SocketType(protoString: str)
                if defaultProto == nil {
                    unsupportedError = ApplicationError.unsupportedConfiguration(option: "proto \(str)")
                }
            }
            Regex.port.enumerateArguments(in: line) {
                isHandled = true
                guard let str = $0.first else {
                    return
                }
                defaultPort = UInt16(str)
            }
            Regex.remote.enumerateArguments(in: line) {
                isHandled = true
                guard let hostname = $0.first else {
                    return
                }
                var port: UInt16?
                var proto: TunnelKitProvider.SocketType?
                var strippedComponents = ["remote", "<hostname>"]
                if $0.count > 1 {
                    port = UInt16($0[1])
                    strippedComponents.append($0[1])
                }
                if $0.count > 2 {
                    proto = TunnelKitProvider.SocketType(protoString: $0[2])
                    strippedComponents.append($0[2])
                }
                remotes.append((hostname, port, proto))

                // replace private data
                strippedLine = strippedComponents.joined(separator: " ")
            }
            Regex.cipher.enumerateArguments(in: line) {
                isHandled = true
                guard let rawValue = $0.first else {
                    return
                }
                cipher = SessionProxy.Cipher(rawValue: rawValue.uppercased())
                if cipher == nil {
                    unsupportedError = ApplicationError.unsupportedConfiguration(option: "cipher \(rawValue)")
                }
            }
            Regex.auth.enumerateArguments(in: line) {
                isHandled = true
                guard let rawValue = $0.first else {
                    return
                }
                digest = SessionProxy.Digest(rawValue: rawValue.uppercased())
                if digest == nil {
                    unsupportedError = ApplicationError.unsupportedConfiguration(option: "auth \(rawValue)")
                }
            }
            Regex.compLZO.enumerateArguments(in: line) {
                isHandled = true
                compressionFraming = .compLZO
                
                guard let arg = $0.first, arg == "no" else {
                    warning = warning ?? .unsupportedConfiguration(option: "compression")
                    return
                }
            }
            Regex.compress.enumerateArguments(in: line) {
                isHandled = true
                compressionFraming = .compress

                guard $0.isEmpty else {
                    warning = warning ?? .unsupportedConfiguration(option: "compression")
                    return
                }
            }
            Regex.keyDirection.enumerateArguments(in: line) {
                isHandled = true
                guard let arg = $0.first, let value = Int(arg) else {
                    return
                }
                keyDirection = StaticKey.Direction(rawValue: value)
            }
            Regex.ping.enumerateArguments(in: line) {
                isHandled = true
                guard let arg = $0.first else {
                    return
                }
                keepAliveSeconds = TimeInterval(arg)
            }
            Regex.renegSec.enumerateArguments(in: line) {
                isHandled = true
                guard let arg = $0.first else {
                    return
                }
                renegotiateAfterSeconds = TimeInterval(arg)
            }
            Regex.fragment.enumerateArguments(in: line) { (_) in
                unsupportedError = ApplicationError.unsupportedConfiguration(option: "fragment")
            }
            Regex.proxy.enumerateArguments(in: line) { (_) in
                unsupportedError = ApplicationError.unsupportedConfiguration(option: "proxy: \"\(line)\"")
            }
            Regex.externalFiles.enumerateArguments(in: line) { (_) in
                unsupportedError = ApplicationError.unsupportedConfiguration(option: "external file: \"\(line)\"")
            }
            if line.contains("mtu") || line.contains("mssfix") {
                isHandled = true
            }

            if let error = unsupportedError {
                throw error
            }
        }
        
        guard let ca = optCA else {
            throw ApplicationError.missingConfiguration(option: "ca")
        }
        
        // XXX: only reads first remote
//        hostnames = remotes.map { $0.0 }
        guard !remotes.isEmpty else {
            throw ApplicationError.missingConfiguration(option: "remote")
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

        if let keyLines = tlsKeyLines, let strategy = tlsStrategy {
            let optKey: StaticKey?
            switch strategy {
            case .auth:
                optKey = StaticKey(lines: keyLines, direction: keyDirection)

            case .crypt:
                optKey = StaticKey(lines: keyLines, direction: .client)
            }
            if let key = optKey {
                tlsWrap = SessionProxy.TLSWrap(strategy: strategy, key: key)
            }
        }

        var sessionBuilder = SessionProxy.ConfigurationBuilder(ca: ca)
        sessionBuilder.cipher = cipher ?? .aes128cbc
        sessionBuilder.digest = digest ?? .sha1
        sessionBuilder.compressionFraming = compressionFraming
        sessionBuilder.tlsWrap = tlsWrap
        sessionBuilder.clientCertificate = clientCertificate
        sessionBuilder.clientKey = clientKey
        sessionBuilder.keepAliveInterval = keepAliveSeconds
        sessionBuilder.renegotiatesAfter = renegotiateAfterSeconds
        var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.endpointProtocols = endpointProtocols

        return ParsedFile(
            url: url,
            hostname: hostname,
            configuration: builder.build(),
            strippedLines: strippedLines,
            warning: warning
        )
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
            let tokens = match.components(separatedBy: " ").filter { !$0.isEmpty }
            block(tokens)
        }
    }

    func enumerateArguments(in string: String, using block: ([String]) -> Void) {
        enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.count)) { (result, flags, stop) in
            guard let range = result?.range else {
                return
            }
            let match = (string as NSString).substring(with: range)
            var tokens = match.components(separatedBy: " ").filter { !$0.isEmpty }
            tokens.removeFirst()
            block(tokens)
        }
    }
}

extension CryptoContainer {
    var isEncrypted: Bool {
        return pem.contains("ENCRYPTED")
    }
}
