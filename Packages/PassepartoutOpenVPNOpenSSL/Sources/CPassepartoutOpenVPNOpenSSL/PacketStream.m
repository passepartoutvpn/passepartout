//
//  PacketStream.m
//  Partout
//
//  Created by Davide De Rosa on 4/25/19.
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

#import "PacketStream.h"
#import "XOR.h"

static const NSInteger PacketStreamHeaderLength = sizeof(uint16_t);

@implementation PacketStream

+ (NSArray<NSData *> *)packetsFromInboundStream:(NSData *)stream
                                          until:(NSInteger *)until
                                      xorMethod:(XORMethodNative)xorMethod
                                        xorMask:(ZeroingData *)xorMask
{
    NSInteger ni = 0;
    NSMutableArray<NSData *> *parsed = [[NSMutableArray alloc] init];

    while (ni + PacketStreamHeaderLength <= stream.length) {
        const NSInteger packlen = CFSwapInt16BigToHost(*(uint16_t *)(stream.bytes + ni));
        const NSInteger start = ni + PacketStreamHeaderLength;
        const NSInteger end = start + packlen;
        if (end > stream.length) {
            break;
        }
        NSData *packet = [stream subdataWithRange:NSMakeRange(start, packlen)];
        uint8_t* packetBytes = (uint8_t*) packet.bytes;
        xor_memcpy(packetBytes, packet, xorMethod, xorMask, false);
        [parsed addObject:packet];
        ni = end;
    }
    if (until) {
        *until = ni;
    }
    return parsed;
}

+ (NSData *)outboundStreamFromPacket:(NSData *)packet
                           xorMethod:(XORMethodNative)xorMethod
                             xorMask:(ZeroingData *)xorMask
{
    NSMutableData *raw = [[NSMutableData alloc] initWithLength:(PacketStreamHeaderLength + packet.length)];

    uint8_t *ptr = raw.mutableBytes;
    *(uint16_t *)ptr = CFSwapInt16HostToBig(packet.length);
    ptr += PacketStreamHeaderLength;
    xor_memcpy(ptr, packet, xorMethod, xorMask, true);
    
    return raw;
}

+ (NSData *)outboundStreamFromPackets:(NSArray<NSData *> *)packets
                            xorMethod:(XORMethodNative)xorMethod
                              xorMask:(ZeroingData *)xorMask
{
    NSInteger streamLength = 0;
    for (NSData *p in packets) {
        streamLength += PacketStreamHeaderLength + p.length;
    }

    NSMutableData *raw = [[NSMutableData alloc] initWithLength:streamLength];
    uint8_t *ptr = raw.mutableBytes;
    for (NSData *packet in packets) {
        *(uint16_t *)ptr = CFSwapInt16HostToBig(packet.length);
        ptr += PacketStreamHeaderLength;
        xor_memcpy(ptr, packet, xorMethod, xorMask, true);
        ptr += packet.length;
    }
    return raw;
}

@end
