//
//  PassepartoutError+OpenVPN.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 1/10/25.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

internal import CPassepartoutOpenVPNOpenSSL
import PassepartoutKit

extension OpenVPNSessionError: PassepartoutErrorMappable {
    public var asPassepartoutError: PassepartoutError {
        PassepartoutError(errorCode, self)
    }

    private var errorCode: PassepartoutError.Code {
        switch self {
        case .negotiationTimeout, .pingTimeout, .writeTimeout:
            return .timeout

        case .badCredentials:
            return .authentication

        case .serverCompression:
            return .OpenVPN.compressionMismatch

        case .serverShutdown:
            return .OpenVPN.serverShutdown

        case .noRouting:
            return .OpenVPN.noRouting

        case .native(let code):
            switch code {
            case .cryptoRandomGenerator, .cryptoEncryption, .cryptoHMAC:
                return .crypto

            case .cryptoAlgorithm:
                return .OpenVPN.unsupportedAlgorithm

            case .tlscaRead, .tlscaUse, .tlscaPeerVerification,
                    .tlsClientCertificateRead, .tlsClientCertificateUse,
                    .tlsClientKeyRead, .tlsClientKeyUse,
                    .tlsServerCertificate, .tlsServerEKU, .tlsServerHost,
                    .tlsHandshake:
                return .OpenVPN.tlsFailure

            case .dataPathCompression:
                return .OpenVPN.compressionMismatch

            default:
                return .OpenVPN.connectionFailure
            }

        default:
            return .OpenVPN.connectionFailure
        }
    }
}

// MARK: - Debugging

extension OpenVPNErrorCode: @retroactive CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue.description
    }
}