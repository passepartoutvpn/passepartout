//
//  CryptoCTRTests.swift
//  Partout
//
//  Created by Davide De Rosa on 12/12/23.
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

internal import CPartoutCryptoOpenSSL
@testable import PartoutCryptoOpenSSL
import XCTest

final class CryptoCTRTests: XCTestCase {
    func test_givenData_whenEncrypt_thenDecrypts() {
        let sut = CryptoCTR(cipherName: "aes-128-ctr",
                            digestName: "sha256",
                            tagLength: 32,
                            payloadLength: 128)

        sut.configureEncryption(withCipherKey: cipherKey, hmacKey: hmacKey)
        sut.configureDecryption(withCipherKey: cipherKey, hmacKey: hmacKey)
        let encryptedData: Data

        var flags = newFlags()
        do {
            encryptedData = try sut.encryptData(plainData, flags: &flags)
        } catch {
            XCTFail("Cannot encrypt: \(error)")
            return
        }
        do {
            let returnedData = try sut.decryptData(encryptedData, flags: &flags)
            XCTAssertEqual(returnedData, plainData)
        } catch {
            XCTFail("Cannot decrypt: \(error)")
        }
    }
}

private extension CryptoCTRTests {
    var cipherKey: ZeroingData {
        ZeroingData(length: 32)
    }

    var hmacKey: ZeroingData {
        ZeroingData(length: 32)
    }

    var plainData: Data {
        Data(hex: "00112233ffddaa")
    }

    var packetId: [UInt8] {
        [0x56, 0x34, 0x12, 0x00]
    }

    var ad: [UInt8] {
        [0x00, 0x12, 0x34, 0x56]
    }

    func newFlags() -> CryptoFlags {
        packetId.withUnsafeBufferPointer { iv in
            ad.withUnsafeBufferPointer { ad in
                CryptoFlags(
                    iv: iv.baseAddress,
                    ivLength: iv.count,
                    ad: ad.baseAddress,
                    adLength: ad.count,
                    forTesting: true
                )
            }
        }
    }
}
