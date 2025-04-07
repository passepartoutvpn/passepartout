//
//  CryptoAEAD+OpenVPN.m
//  Partout
//
//  Created by Davide De Rosa on 7/6/18.
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

#import <Foundation/Foundation.h>

#import "CryptoAEAD+OpenVPN.h"
#import "Errors.h"
#import "PacketMacros.h"

@import CPartoutCryptoOpenSSL;

@implementation CryptoAEAD (OpenVPN)

- (id<DataPathEncrypter>)dataPathEncrypter
{
    return [[DataPathCryptoAEAD alloc] initWithCrypto:self];
}

- (id<DataPathDecrypter>)dataPathDecrypter
{
    return [[DataPathCryptoAEAD alloc] initWithCrypto:self];
}

@end

@interface DataPathCryptoAEAD ()

@property (nonatomic, strong) CryptoAEAD *crypto;

@end

@implementation DataPathCryptoAEAD

- (instancetype)initWithCrypto:(CryptoAEAD *)crypto
{
    if ((self = [super init])) {
        self.crypto = crypto;
        self.peerId = PacketPeerIdDisabled;
    }
    return self;
}

#pragma mark DataPathChannel

- (void)setPeerId:(uint32_t)peerId
{
    _peerId = peerId & 0xffffff;
}

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length
{
    return [self.crypto encryptionCapacityWithLength:length];
}

#pragma mark DataPathEncrypter

- (void)assembleDataPacketWithBlock:(DataPathAssembleBlock)block packetId:(uint32_t)packetId payload:(NSData *)payload into:(uint8_t *)packetBytes length:(NSInteger *)packetLength
{
    *packetLength = payload.length;
    if (!block) {
        memcpy(packetBytes, payload.bytes, payload.length);
        return;
    }

    NSInteger packetLengthOffset;
    block(packetBytes, &packetLengthOffset, payload);
    *packetLength += packetLengthOffset;
}

- (NSData *)encryptedDataPacketWithKey:(uint8_t)key packetId:(uint32_t)packetId packetBytes:(const uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError *__autoreleasing *)error
{
    DATA_PATH_ENCRYPT_INIT(self.peerId)

    const int capacity = headerLength + PacketIdLength + (int)[self.crypto encryptionCapacityWithLength:packetLength];
    NSMutableData *encryptedPacket = [[NSMutableData alloc] initWithLength:capacity];
    uint8_t *ptr = encryptedPacket.mutableBytes;
    NSInteger encryptedPacketLength = INT_MAX;

    *(uint32_t *)(ptr + headerLength) = htonl(packetId);

    CryptoFlags flags;
    flags.iv = ptr + headerLength;
    flags.ivLength = PacketIdLength;
    if (hasPeerId) {
        PacketHeaderSetDataV2(ptr, key, self.peerId);
        flags.ad = ptr;
        flags.adLength = headerLength + PacketIdLength;
    }
    else {
        PacketHeaderSet(ptr, PacketCodeDataV1, key, nil);
        flags.ad = ptr + headerLength;
        flags.adLength = PacketIdLength;
    }

    const BOOL success = [self.crypto encryptBytes:packetBytes
                                            length:packetLength
                                              dest:(ptr + headerLength + PacketIdLength) // skip header and packet id
                                        destLength:&encryptedPacketLength
                                             flags:&flags
                                             error:error];

    NSAssert(encryptedPacketLength <= capacity, @"Did not allocate enough bytes for payload");

    if (!success) {
        return nil;
    }

    encryptedPacket.length = headerLength + PacketIdLength + encryptedPacketLength;
    return encryptedPacket;
}

#pragma mark DataPathDecrypter

- (BOOL)decryptDataPacket:(NSData *)packet into:(uint8_t *)packetBytes length:(NSInteger *)packetLength packetId:(uint32_t *)packetId error:(NSError *__autoreleasing *)error
{
    NSAssert(packet.length > 0, @"Decrypting an empty packet, how did it get this far?");

    DATA_PATH_DECRYPT_INIT(packet)
    if (packet.length < headerLength + PacketIdLength) {
        return NO;
    }

    CryptoFlags flags;
    flags.iv = packet.bytes + headerLength;
    flags.ivLength = PacketIdLength;
    if (hasPeerId) {
        if (peerId != self.peerId) {
            if (error) {
                *error = OpenVPNErrorWithCode(OpenVPNErrorCodeDataPathPeerIdMismatch);
            }
            return NO;
        }
        flags.ad = packet.bytes;
        flags.adLength = headerLength + PacketIdLength;
    }
    else {
        flags.ad = packet.bytes + headerLength;
        flags.adLength = PacketIdLength;
    }

    // skip header + packet id
    const BOOL success = [self.crypto decryptBytes:(packet.bytes + headerLength + PacketIdLength)
                                            length:(int)(packet.length - (headerLength + PacketIdLength))
                                              dest:packetBytes
                                        destLength:packetLength
                                             flags:&flags
                                             error:error];
    if (!success) {
        return NO;
    }
    *packetId = ntohl(*(const uint32_t *)(flags.iv));
    return YES;
}

- (NSData *)parsePayloadWithBlock:(DataPathParseBlock)block compressionHeader:(nonnull uint8_t *)compressionHeader packetBytes:(nonnull uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    uint8_t *payload = packetBytes;
    NSUInteger length = packetLength - (int)(payload - packetBytes);
    if (!block) {
        *compressionHeader = 0x00;
        return [NSData dataWithBytes:payload length:length];
    }

    NSInteger payloadOffset;
    NSInteger payloadHeaderLength;
    if (!block(payload, &payloadOffset, compressionHeader, &payloadHeaderLength, packetBytes, packetLength, error)) {
        return NULL;
    }
    length -= payloadHeaderLength;
    return [NSData dataWithBytes:(payload + payloadOffset) length:length];
}

@end
