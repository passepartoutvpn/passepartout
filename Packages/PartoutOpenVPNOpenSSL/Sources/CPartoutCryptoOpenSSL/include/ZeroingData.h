//
//  ZeroingData.h
//  Partout
//
//  Created by Davide De Rosa on 4/28/17.
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

/// A wrapper to handle data buffers safely. Any formerly allocated bytes are erased before release.
@interface ZeroingData : NSObject

@property (nonatomic, readonly) const uint8_t *bytes;
@property (nonatomic, readonly) uint8_t *mutableBytes;
@property (nonatomic, readonly) NSInteger length;

- (instancetype)initWithLength:(NSInteger)length;
- (instancetype)initWithBytes:(nullable const uint8_t *)bytes length:(NSInteger)length;
- (instancetype)initWithUInt8:(uint8_t)uint8;
- (instancetype)initWithUInt16:(uint16_t)uint16;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data offset:(NSInteger)offset length:(NSInteger)length;
- (instancetype)initWithString:(NSString *)string nullTerminated:(BOOL)nullTerminated;

- (instancetype)copy;

- (void)appendData:(ZeroingData *)other;
- (void)truncateToSize:(NSInteger)size;
- (void)removeUntilOffset:(NSInteger)until;
- (void)zero;

- (ZeroingData *)appendingData:(ZeroingData *)other;
- (ZeroingData *)withOffset:(NSInteger)offset length:(NSInteger)length;
- (uint16_t)UInt16ValueFromOffset:(NSInteger)from;
- (uint16_t)networkUInt16ValueFromOffset:(NSInteger)from;
- (nullable NSString *)nullTerminatedStringFromOffset:(NSInteger)from;

- (BOOL)isEqualToData:(NSData *)data;
- (NSData *)toData; // XXX: unsafe
- (NSString *)toHex;

@end

NS_ASSUME_NONNULL_END
