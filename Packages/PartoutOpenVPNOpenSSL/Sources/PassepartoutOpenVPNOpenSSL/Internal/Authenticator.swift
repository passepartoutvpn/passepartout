//
//  Authenticator.swift
//  Partout
//
//  Created by Davide De Rosa on 2/9/17.
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
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

internal import CPartoutOpenVPNOpenSSL
import Foundation
import Partout

fileprivate extension ZeroingData {
    func appendSized(_ buf: ZeroingData) {
        append(Z(UInt16(buf.length).bigEndian))
        append(buf)
    }
}

final class Authenticator {
    private var controlBuffer: ZeroingData

    private(set) var preMaster: ZeroingData

    private(set) var random1: ZeroingData

    private(set) var random2: ZeroingData

    private(set) var serverRandom1: ZeroingData?

    private(set) var serverRandom2: ZeroingData?

    private(set) var username: ZeroingData?

    private(set) var password: ZeroingData?

    var withLocalOptions: Bool

    var sslVersion: String?

    init(prng: PRNGProtocol, _ username: String?, _ password: String?) {
        preMaster = prng.safeData(length: Constants.preMasterLength)
        random1 = prng.safeData(length: Constants.randomLength)
        random2 = prng.safeData(length: Constants.randomLength)

        // XXX: not 100% secure, can't erase input username/password
        if let username = username, let password = password {
            self.username = Z(username, nullTerminated: true)
            self.password = Z(password, nullTerminated: true)
        } else {
            self.username = nil
            self.password = nil
        }

        withLocalOptions = true

        controlBuffer = Z()
    }

    func reset() {
        controlBuffer.zero()
        preMaster.zero()
        random1.zero()
        random2.zero()
        serverRandom1?.zero()
        serverRandom2?.zero()
        username = nil
        password = nil
    }

    // MARK: Authentication request

    func putAuth(into: OpenVPNTLSProtocol, options: OpenVPN.Configuration) throws {
        let raw = Z(ProtocolMacros.tlsPrefix)

        // local keys
        raw.append(preMaster)
        raw.append(random1)
        raw.append(random2)

        // options string
        let optsString: String
        if withLocalOptions {
            var opts = [
                "V4",
                "dev-type tun"
            ]
            if let comp = options.compressionFraming {
                switch comp {
                case .compLZO:
                    opts.append("comp-lzo")

                case .compress:
                    opts.append("compress")

                default:
                    break
                }
            }
            if let direction = options.tlsWrap?.key.direction?.rawValue {
                opts.append("keydir \(direction)")
            }
            opts.append("cipher \(options.fallbackCipher.rawValue)")
            opts.append("auth \(options.fallbackDigest.rawValue)")
            opts.append("keysize \(options.fallbackCipher.keySize)")
            if let strategy = options.tlsWrap?.strategy {
                opts.append("tls-\(strategy)")
            }
            opts.append("key-method 2")
            opts.append("tls-client")
            optsString = opts.joined(separator: ",")
        } else {
            optsString = "V0 UNDEF"
        }
        pp_log(.openvpn, .info, "TLS.auth: Local options: \(optsString)")
        raw.appendSized(Z(optsString, nullTerminated: true))

        // credentials
        if let username = username, let password = password {
            raw.appendSized(username)
            raw.appendSized(password)
        } else {
            raw.append(Z(UInt16(0)))
            raw.append(Z(UInt16(0)))
        }

        // peer info
        var extra: [String: String] = [:]
        if let dataCiphers = options.dataCiphers {
            extra["IV_CIPHERS"] = dataCiphers.map(\.rawValue).joined(separator: ":")
        }
        let peerInfo = Constants.peerInfo(sslVersion: sslVersion, extra: extra)
        raw.appendSized(Z(peerInfo, nullTerminated: true))

        pp_log(.openvpn, .info, "TLS.auth: Put plaintext \(raw.asSensitiveBytes)")

        try into.putRawPlainText(raw.bytes, length: raw.length)
    }

    // MARK: Server replies

    func appendControlData(_ data: ZeroingData) {
        controlBuffer.append(data)
    }

    func parseAuthReply() throws -> Bool {
        let prefixLength = ProtocolMacros.tlsPrefix.count

        // TLS prefix + random (x2) + opts length [+ opts]
        guard controlBuffer.length >= prefixLength + 2 * Constants.randomLength + 2 else {
            return false
        }

        let prefix = controlBuffer.withOffset(0, length: prefixLength)
        guard prefix.isEqual(to: ProtocolMacros.tlsPrefix) else {
            throw OpenVPNSessionError.wrongControlDataPrefix
        }

        var offset = ProtocolMacros.tlsPrefix.count

        let serverRandom1 = controlBuffer.withOffset(offset, length: Constants.randomLength)
        offset += Constants.randomLength

        let serverRandom2 = controlBuffer.withOffset(offset, length: Constants.randomLength)
        offset += Constants.randomLength

        let serverOptsLength = Int(controlBuffer.networkUInt16Value(fromOffset: offset))
        offset += 2

        guard controlBuffer.length >= offset + serverOptsLength else {
            return false
        }
        let serverOpts = controlBuffer.withOffset(offset, length: serverOptsLength)
        offset += serverOptsLength

        pp_log(.openvpn, .info, "TLS.auth: Parsed server random [\(serverRandom1.asSensitiveBytes), \(serverRandom2.asSensitiveBytes)]")

        if let serverOptsString = serverOpts.nullTerminatedString(fromOffset: 0) {
            pp_log(.openvpn, .info, "TLS.auth: Parsed server options: \"\(serverOptsString)\"")
        }

        self.serverRandom1 = serverRandom1
        self.serverRandom2 = serverRandom2
        controlBuffer.remove(untilOffset: offset)

        return true
    }

    func parseMessages() -> [String] {
        var messages = [String]()
        var offset = 0

        while true {
            guard let msg = controlBuffer.nullTerminatedString(fromOffset: offset) else {
                break
            }
            messages.append(msg)
            offset += msg.count + 1
        }

        controlBuffer.remove(untilOffset: offset)

        return messages
    }

    // MARK: Response

    var response: Response? {
        guard let serverRandom1, let serverRandom2 else {
            return nil
        }
        return Response(
            preMaster: preMaster,
            random1: random1,
            random2: random2,
            serverRandom1: serverRandom1,
            serverRandom2: serverRandom2
        )
    }
}

extension Authenticator {
    struct Response {
        let preMaster: ZeroingData

        let random1: ZeroingData

        let random2: ZeroingData

        let serverRandom1: ZeroingData

        let serverRandom2: ZeroingData
    }
}
