//
//  CryptoCBC+OpenVPN.m
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

#import "CryptoCBC+OpenVPN.h"
#import "Crypto.h"
#import "Errors.h"
#import "PacketMacros.h"

@import CPartoutCryptoOpenSSL;

@implementation CryptoCBC (OpenVPN)

- (id<DataPathEncrypter>)dataPathEncrypter
{
    return [[DataPathCryptoCBC alloc] initWithCrypto:self];
}

- (id<DataPathDecrypter>)dataPathDecrypter
{
    return [[DataPathCryptoCBC alloc] initWithCrypto:self];
}

@end

@interface DataPathCryptoCBC ()

@property (nonatomic, strong) CryptoCBC *crypto;

@end

@implementation DataPathCryptoCBC

- (instancetype)initWithCrypto:(CryptoCBC *)crypto
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
    uint8_t *ptr = packetBytes;
    *(uint32_t *)ptr = htonl(packetId);
    ptr += sizeof(uint32_t);
    *packetLength = (int)(ptr - packetBytes + payload.length);
    if (!block) {
        memcpy(ptr, payload.bytes, payload.length);
        return;
    }

    NSInteger packetLengthOffset;
    block(ptr, &packetLengthOffset, payload);
    *packetLength += packetLengthOffset;
}

- (NSData *)encryptedDataPacketWithKey:(uint8_t)key packetId:(uint32_t)packetId packetBytes:(const uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError *__autoreleasing *)error
{
    DATA_PATH_ENCRYPT_INIT(self.peerId)

    const int capacity = headerLength + (int)[self.crypto encryptionCapacityWithLength:packetLength];
    NSMutableData *encryptedPacket = [[NSMutableData alloc] initWithLength:capacity];
    uint8_t *ptr = encryptedPacket.mutableBytes;
    NSInteger encryptedPacketLength = INT_MAX;
    const BOOL success = [self.crypto encryptBytes:packetBytes
                                            length:packetLength
                                              dest:(ptr + headerLength) // skip header bytes
                                        destLength:&encryptedPacketLength
                                             flags:NULL
                                             error:error];

    NSAssert(encryptedPacketLength <= capacity, @"Did not allocate enough bytes for payload");

    if (!success) {
        return nil;
    }

    if (hasPeerId) {
        PacketHeaderSetDataV2(ptr, key, self.peerId);
    }
    else {
        PacketHeaderSet(ptr, PacketCodeDataV1, key, nil);
    }
    encryptedPacket.length = headerLength + encryptedPacketLength;
    return encryptedPacket;
}

#pragma mark DataPathDecrypter

- (BOOL)decryptDataPacket:(NSData *)packet into:(uint8_t *)packetBytes length:(NSInteger *)packetLength packetId:(uint32_t *)packetId error:(NSError *__autoreleasing *)error
{
    NSAssert(packet.length > 0, @"Decrypting an empty packet, how did it get this far?");

    DATA_PATH_DECRYPT_INIT(packet)
    if (packet.length < headerLength + self.crypto.digestLength + self.crypto.cipherIVLength) {
        return NO;
    }

    // skip header = (code, key)
    const BOOL success = [self.crypto decryptBytes:(packet.bytes + headerLength)
                                            length:(int)(packet.length - headerLength)
                                              dest:packetBytes
                                        destLength:packetLength
                                             flags:NULL
                                             error:error];
    if (!success) {
        return NO;
    }
    if (hasPeerId) {
        if (peerId != self.peerId) {
            if (error) {
                *error = OpenVPNErrorWithCode(OpenVPNErrorCodeDataPathPeerIdMismatch);
            }
            return NO;
        }
    }
    *packetId = ntohl(*(uint32_t *)packetBytes);
    return YES;
}

- (NSData *)parsePayloadWithBlock:(DataPathParseBlock)block compressionHeader:(nonnull uint8_t *)compressionHeader packetBytes:(nonnull uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    uint8_t *payload = packetBytes;
    payload += sizeof(uint32_t); // packet id
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
