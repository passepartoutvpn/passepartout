//
//  ReplayProtector.m
//  Partout
//
//  Created by Davide De Rosa on 2/17/17.
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

#import "Allocation.h"
#import "ReplayProtector.h"

@import CPartoutCryptoOpenSSL;

#define HIDDEN_WINSIZE          128
#define BITMAP_LEN              (HIDDEN_WINSIZE / 32)
#define BITMAP_INDEX_MASK       (BITMAP_LEN - 1)
#define REDUNDANT_BIT_SHIFTS    5
#define REDUNDANT_BITS          (1 << REDUNDANT_BIT_SHIFTS)
#define BITMAP_LOC_MASK         (REDUNDANT_BITS - 1)
#define REPLAY_WINSIZE          (HIDDEN_WINSIZE - REDUNDANT_BITS)

@interface ReplayProtector ()

@property (nonatomic, assign) uint32_t highestPacketId;
@property (nonatomic, unsafe_unretained) uint32_t *bitmap;

@end

@implementation ReplayProtector

- (instancetype)init
{
    if ((self = [super init])) {
        self.highestPacketId = 0;
        self.bitmap =  pp_alloc_crypto(BITMAP_LEN * sizeof(uint32_t));
        bzero(self.bitmap, BITMAP_LEN * sizeof(uint32_t));
    }
    return self;
}

- (void)dealloc
{
    free(self.bitmap);
}

- (BOOL)isReplayedPacketId:(uint32_t)packetId
{
    if (packetId == 0) {
        return YES;
    }
    if ((REPLAY_WINSIZE + packetId) < self.highestPacketId) {
        return YES;
    }
    
    uint32_t index = (packetId >> REDUNDANT_BIT_SHIFTS);
    
    if (packetId > self.highestPacketId) {
        const uint32_t currentIndex = self.highestPacketId >> REDUNDANT_BIT_SHIFTS;
        const uint32_t diff = MIN(index - currentIndex, BITMAP_LEN);

        for (uint32_t bid = 0; bid < diff; ++bid) {
            self.bitmap[(bid + currentIndex + 1) & BITMAP_INDEX_MASK] = 0;
        }
        
        self.highestPacketId = packetId;
    }
    
    index &= BITMAP_INDEX_MASK;
    const uint32_t bitLocation = packetId & BITMAP_LOC_MASK;
    const uint32_t bitmask = (1 << bitLocation);
    
    if (self.bitmap[index] & bitmask) {
        return YES;
    }
    self.bitmap[index] |= bitmask;
    return NO;
}

@end
