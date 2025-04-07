//
//  MockOpenVPNTLS.swift
//  Partout
//
//  Created by Davide De Rosa on 4/12/24.
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

internal import CPartoutOpenVPNOpenSSL
import Foundation

final class MockOpenVPNTLS: OpenVPNTLSProtocol {
    func configure(with options: OpenVPNTLSOptions, onFailure: (Error) -> Void) throws {
    }

    func options() -> OpenVPNTLSOptions? {
        nil
    }

    func start() throws {
    }

    func pullCipherText() throws -> Data {
        Data()
    }

    func pullRawPlainText(_ text: UnsafeMutablePointer<UInt8>, length: UnsafeMutablePointer<Int>) throws {
    }

    func putCipherText(_ text: Data) throws {
    }

    func putRawCipherText(_ text: UnsafePointer<UInt8>, length: Int) throws {
    }

    func putPlainText(_ text: String) throws {
    }

    func putRawPlainText(_ text: UnsafePointer<UInt8>, length: Int) throws {
    }

    func isConnected() -> Bool {
        true
    }

    func md5(forCertificatePath path: String) throws -> String {
        ""
    }

    func decryptedPrivateKey(fromPath path: String, passphrase: String) throws -> String {
        ""
    }

    func decryptedPrivateKey(fromPEM pem: String, passphrase: String) throws -> String {
        ""
    }
}
