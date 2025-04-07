//
//  DataPathCrypto.h
//  Partout
//
//  Created by Davide De Rosa on 7/11/18.
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

NS_ASSUME_NONNULL_BEGIN

#define DATA_PATH_ENCRYPT_INIT(peerId) \
    const BOOL hasPeerId = (peerId != PacketPeerIdDisabled); \
    int headerLength = PacketOpcodeLength; \
    if (hasPeerId) { \
        headerLength += PacketPeerIdLength; \
    }

#define DATA_PATH_DECRYPT_INIT(packet) \
    const uint8_t *ptr = packet.bytes; \
    PacketCode code; \
    PacketOpcodeGet(ptr, &code, NULL); \
    uint32_t peerId = PacketPeerIdDisabled; \
    const BOOL hasPeerId = (code == PacketCodeDataV2); \
    int headerLength = PacketOpcodeLength; \
    if (hasPeerId) { \
        headerLength += PacketPeerIdLength; \
        if (packet.length < headerLength) { \
            return NO; \
        } \
        peerId = PacketHeaderGetDataV2PeerId(ptr); \
    }

typedef void (^DataPathAssembleBlock)(uint8_t *packetDest, NSInteger *packetLengthOffset, NSData *payload);
typedef BOOL (^DataPathParseBlock)(uint8_t *payload,
                                   NSInteger *payloadOffset,
                                   uint8_t *header,
                                   NSInteger *headerLength,
                                   const uint8_t *packet,
                                   NSInteger packetLength,
                                   NSError **error);

@protocol DataPathChannel

- (uint32_t)peerId;
- (void)setPeerId:(uint32_t)peerId;
- (NSInteger)encryptionCapacityWithLength:(NSInteger)length;

@end

@protocol DataPathEncrypter <DataPathChannel>

- (void)assembleDataPacketWithBlock:(nullable DataPathAssembleBlock)block packetId:(uint32_t)packetId payload:(NSData *)payload into:(uint8_t *)packetBytes length:(NSInteger *)packetLength;
- (nullable NSData *)encryptedDataPacketWithKey:(uint8_t)key packetId:(uint32_t)packetId packetBytes:(const uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError **)error;

@end

@protocol DataPathDecrypter <DataPathChannel>

- (BOOL)decryptDataPacket:(NSData *)packet into:(uint8_t *)packetBytes length:(NSInteger *)packetLength packetId:(uint32_t *)packetId error:(NSError **)error;
- (nullable NSData *)parsePayloadWithBlock:(nullable DataPathParseBlock)block compressionHeader:(uint8_t *)compressionHeader packetBytes:(uint8_t *)packetBytes packetLength:(NSInteger)packetLength error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
