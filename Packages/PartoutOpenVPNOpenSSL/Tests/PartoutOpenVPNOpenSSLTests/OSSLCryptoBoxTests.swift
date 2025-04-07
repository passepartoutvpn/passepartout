//
//  OSSLCryptoBoxTests.swift
//  Partout
//
//  Created by Davide De Rosa on 9/10/18.
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
internal import CPartoutOpenVPNOpenSSL
@testable import PartoutCryptoOpenSSL
import Partout
@testable import PartoutOpenVPNOpenSSL
import XCTest

final class OSSLCryptoBoxTests: XCTestCase {

    // MARK: Serialization

//    38 // HARD_RESET
//    858fe14742fdae40 // session_id
//    e67c9137933a412a711c0d0514aca6db6476d17d // hmac
//    000000015b96c947 // replay packet_id (seq + timestamp)
//    00 // ack_size
//    00000000 // message packet_id (HARD_RESET -> UInt32(0))
    func test_givenBidirectionalKey_whenVerifyData_thenHMACIsValid() {
        let sut = OSSLCryptoBox()
        let key = OpenVPN.StaticKey(biData: Data(hex: staticKeyHex))
        XCTAssertNoThrow(try sut.configure(with: .init(
            cipherAlgorithm: nil,
            digestAlgorithm: OpenVPN.Digest.sha1.rawValue,
            cipherEncKey: nil,
            cipherDecKey: nil,
            hmacEncKey: key.hmacReceiveKey.zData,
            hmacDecKey: key.hmacSendKey.zData)
        ))

        let hmac = Data(hex: "e67c9137933a412a711c0d0514aca6db6476d17d")
        let subject = Data(hex: "000000015b96c94738858fe14742fdae400000000000")
        let data = hmac + subject

        XCTAssertNoThrow(try sut.decrypter().verifyData(data, flags: nil))
    }

//    38 // HARD_RESET
//    bccfd171ce22e085 // session_id
//    e01a3454c354f3c3093b00fc8d6228a8b69ef503d56f6a572ebd26a800711b4cd4df2b9daf06cb90f82379e7815e39fb73be4ac5461752db4f35120474af82b2 // hmac
//    000000015b93b65d // replay packet_id
//    00 // ack_size
//    00000000 // message packet_id
    func test_givenKeys_whenDeserializeHardResetClientV2_thenSerializationReverts() throws {
        let sut = { OSSLCryptoBox() }
        let client = try ControlChannel.AuthSerializer(
            with: sut(),
            key: OpenVPN.StaticKey(data: Data(hex: staticKeyHex), direction: .client),
            digest: .sha512
        )
        let server = try ControlChannel.AuthSerializer(
            with: sut(),
            key: OpenVPN.StaticKey(data: Data(hex: staticKeyHex), direction: .server),
            digest: .sha512
        )

        let original = Data(hex: "38bccfd171ce22e085e01a3454c354f3c3093b00fc8d6228a8b69ef503d56f6a572ebd26a800711b4cd4df2b9daf06cb90f82379e7815e39fb73be4ac5461752db4f35120474af82b2000000015b93b65d0000000000")
        let timestamp = UInt32(0x5b93b65d)

        let packet: ControlPacket
        do {
            packet = try client.deserialize(data: original, start: 0, end: nil)
        } catch {
            XCTAssertNil(error)
            return
        }
        XCTAssertEqual(packet.code, .hardResetClientV2)
        XCTAssertEqual(packet.sessionId, Data(hex: "bccfd171ce22e085"))
        XCTAssertNil(packet.ackIds)
        XCTAssertEqual(packet.packetId, 0)

        let raw = try server.serialize(packet: packet, timestamp: timestamp)
        XCTAssertEqual(raw, original)
    }

    func test_givenKeys_whenDeserializeHardResetServerV2_thenSerializationReverts() throws {
        let sut = { OSSLCryptoBox() }
        let client = try ControlChannel.CryptSerializer(
            with: sut(),
            key: OpenVPN.StaticKey(data: Data(hex: staticKeyHex), direction: .client)
        )
        let server = try ControlChannel.CryptSerializer(
            with: sut(),
            key: OpenVPN.StaticKey(data: Data(hex: staticKeyHex), direction: .server)
        )

        let original = Data(hex: "407bf3d6a260e6476d000000015ba4155887940856ddb70e01693980c5c955cb5506ecf9fd3e0bcee0c802ec269427d43bf1cda1837ffbf30c83cacff852cd0b7f4c")
        let timestamp = UInt32(0x5ba41558)

        let packet: ControlPacket
        do {
            packet = try client.deserialize(data: original, start: 0, end: nil)
        } catch {
            XCTAssertNil(error)
            return
        }
        XCTAssertEqual(packet.code, .hardResetServerV2)
        XCTAssertEqual(packet.sessionId, Data(hex: "7bf3d6a260e6476d"))
        XCTAssertEqual(packet.ackIds?.count, 1)
        XCTAssertEqual(packet.ackRemoteSessionId, Data(hex: "a62ec85cc767f0a6"))
        XCTAssertEqual(packet.packetId, 0)

        let raw = try server.serialize(packet: packet, timestamp: timestamp)
        XCTAssertEqual(raw, original)
    }

    // MARK: Encryption

    func test_givenClientServer_whenEncryptCBC_thenDecrypts() throws {
        let (client, server) = clientServer("aes-128-cbc", "sha256")

        let plain = Data(hex: "00112233445566778899")
        let encrypted = try client.encrypter().encryptData(plain, flags: nil)
        let decrypted = try server.decrypter().decryptData(encrypted, flags: nil)
        XCTAssertEqual(plain, decrypted)
    }

    func test_givenClientServer_whenEncryptCBC_thenValidates() throws {
        let (client, server) = clientServer(nil, "sha256")

        let plain = Data(hex: "00112233445566778899")
        let encrypted = try client.encrypter().encryptData(plain, flags: nil)
        XCTAssertNoThrow(try server.decrypter().verifyData(encrypted, flags: nil))
    }

    func test_givenClientServer_whenEncryptGCM_thenDecrypts() throws {
        let (client, server) = clientServer("aes-256-gcm", nil)

        let packetId: [UInt8] = [0x56, 0x34, 0x12, 0x00]
        let ad: [UInt8] = [0x00, 0x12, 0x34, 0x56]
        var flags = packetId.withUnsafeBufferPointer { iv in
            ad.withUnsafeBufferPointer { ad in
                CryptoFlags(iv: iv.baseAddress,
                            ivLength: iv.count,
                            ad: ad.baseAddress,
                            adLength: ad.count,
                            forTesting: true)
            }
        }

        let plain = Data(hex: "00112233445566778899")
        let encrypted = try client.encrypter().encryptData(plain, flags: &flags)
        let decrypted = try server.decrypter().decryptData(encrypted, flags: &flags)
        XCTAssertEqual(plain, decrypted)
    }

    func test_givenClientServer_whenEncryptCTR_thenDecrypts() throws {
        let (client, server) = clientServer("aes-256-ctr", "sha256")

        let original = Data(hex: "0000000000")
        let ad: [UInt8] = [UInt8](Data(hex: "38afa8f1162096081e000000015ba35373"))
        var flags = ad.withUnsafeBufferPointer {
            CryptoFlags(iv: nil,
                        ivLength: 0,
                        ad: $0.baseAddress,
                        adLength: $0.count,
                        forTesting: true)
        }

        let encrypted = try client.encrypter().encryptData(original, flags: &flags)
        let decrypted = try server.decrypter().decryptData(encrypted, flags: &flags)
        XCTAssertEqual(decrypted, original)
    }

    // MARK: DataPath Encryption

    func test_givenDataPath_whenEncryptCBC_thenDecrypts() throws {
        let (encrypter, decrypter) = dataPathPair("aes-128-cbc", "sha256")
        try privateTestDataPathHigh(encrypter, decrypter, peerId: nil)
        try privateTestDataPathLow(encrypter, decrypter, peerId: nil)
    }

    func test_givenDataPath_whenEncryptCBCWithPeerId_thenDecrypts() throws {
        let (encrypter, decrypter) = dataPathPair("aes-128-cbc", "sha256")
        let peerId: UInt32 = 0x64385837
        try privateTestDataPathHigh(encrypter, decrypter, peerId: peerId)
        try privateTestDataPathLow(encrypter, decrypter, peerId: peerId)
    }

    func test_givenDataPath_whenEncryptGCM_thenDecrypts() throws {
        let (encrypter, decrypter) = dataPathPair("aes-256-gcm", nil)
        try privateTestDataPathHigh(encrypter, decrypter, peerId: nil)
        try privateTestDataPathLow(encrypter, decrypter, peerId: nil)
    }

    func test_givenDataPath_whenEncryptGCMWithPeerId_thenDecrypts() throws {
        let (encrypter, decrypter) = dataPathPair("aes-256-gcm", nil)
        let peerId: UInt32 = 0x64385837
        try privateTestDataPathHigh(encrypter, decrypter, peerId: peerId)
        try privateTestDataPathLow(encrypter, decrypter, peerId: peerId)
    }
}

private extension OSSLCryptoBoxTests {
    var cipherEncKey: ZeroingData {
        Z(Data(hex: "634a4d2d459d606c8e6abbec168fdcd1871462eaa2eaed84c8f403bdf8c7da73"))
    }

    var cipherDecKey: ZeroingData {
        Z(Data(hex: "7d81b5774cc35fe0a42b38aa053f1335fd4a22d721880433bbb20ae1f2d88315"))
    }

    var hmacEncKey: ZeroingData {
        Z(Data(hex: "b2d186b3b377685506fa39d85d38da16c2ecc0d631bda64f9d8f5a8d073f18aa"))
    }

    var hmacDecKey: ZeroingData {
        Z(Data(hex: "b97ade23e49ea9e7de86784d1ed5fa356df5f7fa1d163e5537efa8d4ba61239d"))
    }

    var staticKeyHex: String { "634a4d2d459d606c8e6abbec168fdcd1871462eaa2eaed84c8f403bdf8c7da737d81b5774cc35fe0a42b38aa053f1335fd4a22d721880433bbb20ae1f2d88315b2d186b3b377685506fa39d85d38da16c2ecc0d631bda64f9d8f5a8d073f18aab97ade23e49ea9e7de86784d1ed5fa356df5f7fa1d163e5537efa8d4ba61239dc301a9aa55de0e06e33a7545f7d0cc153405576464ba92942dafa5fb79c7a60663ff1e7da3122ae09d4561653bef3eeb312ad68b191e2f94cbcf4e21caff0b59f8be86567bd21787070c2dc10a8baf7e87ce2e07d7d7de25ead11bd6d6e6ec030c0a3fd50d2d0ca3c0378022bb642e954868d7b93e18a131ecbb12b0bbedb1ce"
    }

    func clientServer(_ cipher: String?, _ digest: String?) -> (OSSLCryptoBox, OSSLCryptoBox) {
        let client = OSSLCryptoBox()
        let server = OSSLCryptoBox()
        XCTAssertNoThrow(try client.configure(with: .init(
            cipherAlgorithm: cipher,
            digestAlgorithm: digest,
            cipherEncKey: cipherEncKey,
            cipherDecKey: cipherDecKey,
            hmacEncKey: hmacEncKey,
            hmacDecKey: hmacDecKey
        )))
        XCTAssertNoThrow(try server.configure(with: .init(
            cipherAlgorithm: cipher,
            digestAlgorithm: digest,
            cipherEncKey: cipherDecKey,
            cipherDecKey: cipherEncKey,
            hmacEncKey: hmacDecKey,
            hmacDecKey: hmacEncKey
        )))
        return (client, server)
    }

    func dataPathPair(_ cipher: String?, _ digest: String?) -> (DataPathEncrypter, DataPathDecrypter) {
        let box = OSSLCryptoBox()
        XCTAssertNoThrow(try box.configure(with: .init(
            cipherAlgorithm: cipher,
            digestAlgorithm: digest,
            cipherEncKey: cipherEncKey,
            cipherDecKey: cipherEncKey, // same
            hmacEncKey: hmacEncKey,
            hmacDecKey: hmacEncKey // same
        )))
        return (box.encrypter().dataPathEncrypter(), box.decrypter().dataPathDecrypter())
    }

    func privateTestDataPathLow(_ enc: DataPathEncrypter, _ dec: DataPathDecrypter, peerId: UInt32?) throws {
        if let peerId {
            enc.setPeerId(peerId)
            dec.setPeerId(peerId)
            XCTAssertEqual(enc.peerId(), peerId & 0xffffff)
            XCTAssertEqual(dec.peerId(), peerId & 0xffffff)
        }

        let expectedPayload = Data(hex: "00112233445566778899")
        let expectedPacketId: UInt32 = 0x56341200
        let key: UInt8 = 4

        var encryptedPacketBytes: [UInt8] = [UInt8](repeating: 0, count: 1000)
        var encryptedPacketLength: Int = 0
        enc.assembleDataPacket(nil, packetId: expectedPacketId, payload: expectedPayload, into: &encryptedPacketBytes, length: &encryptedPacketLength)
        let encrypted = try enc.encryptedDataPacket(withKey: key, packetId: expectedPacketId, packetBytes: encryptedPacketBytes, packetLength: encryptedPacketLength)

        var decryptedBytes: [UInt8] = [UInt8](repeating: 0, count: 1000)
        var decryptedLength: Int = 0
        var packetId: UInt32 = 0
        var compressionHeader: UInt8 = 0
        try dec.decryptDataPacket(encrypted, into: &decryptedBytes, length: &decryptedLength, packetId: &packetId)
        let payload = try dec.parsePayload(nil, compressionHeader: &compressionHeader, packetBytes: &decryptedBytes, packetLength: decryptedLength)

        XCTAssertEqual(payload, expectedPayload)
        XCTAssertEqual(packetId, expectedPacketId)
    }

    func privateTestDataPathHigh(_ enc: DataPathEncrypter, _ dec: DataPathDecrypter, peerId: UInt32?) throws {
        let path = DataPath(
            encrypter: enc,
            decrypter: dec,
            peerId: peerId ?? PacketPeerIdDisabled,
            compressionFraming: .disabled,
            compressionAlgorithm: .disabled,
            maxPackets: 1000,
            usesReplayProtection: false
        )

        if let peerId {
            enc.setPeerId(peerId)
            dec.setPeerId(peerId)
            XCTAssertEqual(enc.peerId(), peerId & 0xffffff)
            XCTAssertEqual(dec.peerId(), peerId & 0xffffff)
        }

        let expectedPayload = Data(hex: "00112233445566778899")
        let key: UInt8 = 4

        let encrypted = try path.encryptPackets([expectedPayload], key: key)
        let decrypted = try path.decryptPackets(encrypted, keepAlive: nil)
        let payload = decrypted.first!

        XCTAssertEqual(payload, expectedPayload)
    }
}
