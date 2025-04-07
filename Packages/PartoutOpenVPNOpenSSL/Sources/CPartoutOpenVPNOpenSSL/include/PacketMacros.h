//
//  PacketMacros.h
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

#define PacketOpcodeLength          ((NSInteger)1)
#define PacketIdLength              ((NSInteger)4)
#define PacketSessionIdLength       ((NSInteger)8)
#define PacketAckLengthLength       ((NSInteger)1)
#define PacketPeerIdLength          ((NSInteger)3)
#define PacketPeerIdDisabled        ((uint32_t)0xffffffu)
#define PacketReplayIdLength        ((NSInteger)4)
#define PacketReplayTimestampLength ((NSInteger)4)

typedef NS_ENUM(uint8_t, PacketCode) {
    PacketCodeSoftResetV1           = 0x03,
    PacketCodeControlV1             = 0x04,
    PacketCodeAckV1                 = 0x05,
    PacketCodeDataV1                = 0x06,
    PacketCodeHardResetClientV2     = 0x07,
    PacketCodeHardResetServerV2     = 0x08,
    PacketCodeDataV2                = 0x09,
    PacketCodeUnknown               = 0xff
};

#define DataPacketNoCompress        0xfa
#define DataPacketNoCompressSwap    0xfb
#define DataPacketLZOCompress       0x66

#define DataPacketV2Indicator       0x50
#define DataPacketV2Uncompressed    0x00

extern const uint8_t DataPacketPingData[16];

@protocol PacketProtocol

@property (nonatomic, readonly) uint32_t packetId;

@end

static inline void PacketOpcodeGet(const uint8_t *from, PacketCode *_Nullable code, uint8_t *_Nullable key)
{
    if (code) {
        *code = (PacketCode)(*from >> 3);
    }
    if (key) {
        *key = *from & 0b111;
    }
}

static inline int PacketHeaderSet(uint8_t *to, PacketCode code, uint8_t key, const uint8_t *_Nullable sessionId)
{
    *(uint8_t *)to = (code << 3) | (key & 0b111);
    int offset = PacketOpcodeLength;
    if (sessionId) {
        memcpy(to + offset, sessionId, PacketSessionIdLength);
        offset += PacketSessionIdLength;
    }
    return offset;
}

static inline int PacketHeaderSetDataV2(uint8_t *to, uint8_t key, uint32_t peerId)
{
    *(uint32_t *)to = ((PacketCodeDataV2 << 3) | (key & 0b111)) | htonl(peerId & 0xffffff);
    return PacketOpcodeLength + PacketPeerIdLength;
}

static inline int PacketHeaderGetDataV2PeerId(const uint8_t *from)
{
    return ntohl(*(const uint32_t *)from & 0xffffff00);
}

#pragma mark - Utils

static inline void PacketSwap(uint8_t *ptr, NSInteger len1, NSInteger len2)
{
    // two buffers due to overlapping
    uint8_t buf1[len1];
    uint8_t buf2[len2];
    memcpy(buf1, ptr, len1);
    memcpy(buf2, ptr + len1, len2);
    memcpy(ptr, buf2, len2);
    memcpy(ptr + len2, buf1, len1);
}

static inline void PacketSwapCopy(uint8_t *dst, NSData *src, NSInteger len1, NSInteger len2)
{
    NSCAssert(src.length >= len1 + len2, @"src is smaller than expected");
    memcpy(dst, src.bytes + len1, len2);
    memcpy(dst + len2, src.bytes, len1);
    const NSInteger preambleLength = len1 + len2;
    memcpy(dst + preambleLength, src.bytes + preambleLength, src.length - preambleLength);
}

NS_ASSUME_NONNULL_END
