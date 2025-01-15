//
//  StandardOpenVPNParserError.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 4/3/19.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import Foundation
import PassepartoutKit

/// Thrown by ``StandardOpenVPNParser``, with details about the line that triggered it.
public enum StandardOpenVPNParserError: Error {

    /// The PUSH_REPLY is multipart.
    case continuationPushReply

    /// A decrypter is required to proceed.
    case decrypterRequired

    /// Passphrase required to decrypt private keys.
    case encryptionPassphrase

    /// File format is invalid.
    case invalidFormat

    /// Option syntax is incorrect.
    case malformed(option: String)

    /// Encryption passphrase is incorrect or key is corrupt.
    case unableToDecrypt(error: Error?)

    /// An option is unsupported.
    case unsupportedConfiguration(option: String)
}

// MARK: - Mapping

extension StandardOpenVPNParserError: PassepartoutErrorMappable {
    public var asPassepartoutError: PassepartoutError {
        switch self {
        case .malformed(let option):
            return PassepartoutError(.parsing, option, self)

        case .unsupportedConfiguration(let option):
            return PassepartoutError(.parsing, option, self)

        case .encryptionPassphrase, .unableToDecrypt:
            return PassepartoutError(.crypto, self)

        default:
            return PassepartoutError(.parsing, self)
        }
    }
}
