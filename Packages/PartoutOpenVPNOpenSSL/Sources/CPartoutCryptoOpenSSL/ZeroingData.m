//
//  ZeroingData.m
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

#import "ZeroingData.h"
#import "Allocation.h"

@interface ZeroingData () {
    uint8_t *_bytes;
}

@end

@implementation ZeroingData

- (instancetype)init
{
    return [self initWithBytes:NULL length:0];
}

- (instancetype)initWithLength:(NSInteger)length
{
    if ((self = [super init])) {
        _length = length;
        _bytes = pp_alloc_crypto(length);
        bzero(_bytes, _length);
    }
    return self;
}

- (instancetype)initWithBytes:(const uint8_t *)bytes length:(NSInteger)length
{
//    NSParameterAssert(bytes);

    if ((self = [super init])) {
        _length = length;
        _bytes = pp_alloc_crypto(length);
        memcpy(_bytes, bytes, length);
    }
    return self;
}

- (instancetype)initWithBytesNoCopy:(uint8_t *)bytes length:(NSInteger)length
{
    NSParameterAssert(bytes);

    if ((self = [super init])) {
        _length = length;
        _bytes = bytes;
    }
    return self;
}

- (instancetype)initWithUInt8:(uint8_t)uint8
{
    if ((self = [super init])) {
        _length = 1;
        _bytes = pp_alloc_crypto(_length);
        _bytes[0] = uint8;
    }
    return self;
}

- (instancetype)initWithUInt16:(uint16_t)uint16
{
    if ((self = [super init])) {
        _length = 2;
        _bytes = pp_alloc_crypto(_length);
        _bytes[0] = (uint16 & 0xff);
        _bytes[1] = (uint16 >> 8);
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    return [self initWithData:data offset:0 length:data.length];
}

- (instancetype)initWithData:(NSData *)data offset:(NSInteger)offset length:(NSInteger)length
{
    NSParameterAssert(data);
    NSParameterAssert(length >= 0);
    NSParameterAssert(offset + length <= data.length);

    if ((self = [super init])) {
        _length = length;
        _bytes = pp_alloc_crypto(length);
        memcpy(_bytes, data.bytes + offset, length);
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string nullTerminated:(BOOL)nullTerminated
{
    NSParameterAssert(string);

    if ((self = [super init])) {
        const int stringLength = (int)string.length;
        _length = stringLength + (nullTerminated ? 1 : 0);
        _bytes = pp_alloc_crypto(_length);

        const char *stringBytes = [string cStringUsingEncoding:NSUTF8StringEncoding];
        if (stringBytes) {
            memcpy(_bytes, stringBytes, stringLength);
        } else {
            NSAssert(stringBytes != NULL, @"Cannot encode string to UTF-8");
            bzero(_bytes, stringLength);
        }
        if (nullTerminated) {
            _bytes[stringLength] = '\0';
        }
    }
    return self;
}

- (instancetype)copy
{
    return [[ZeroingData alloc] initWithBytes:_bytes length:_length];
}

- (void)dealloc
{
    bzero(_bytes, _length);
    free(_bytes);
}

- (const uint8_t *)bytes
{
    return _bytes;
}

- (uint8_t *)mutableBytes
{
    return _bytes;
}

- (void)appendData:(ZeroingData *)other
{
    NSParameterAssert(other);

    const NSInteger newLength = _length + other.length;
    uint8_t *newBytes = pp_alloc_crypto(newLength);
    memcpy(newBytes, _bytes, _length);
    memcpy(newBytes + _length, other.bytes, other.length);
    
    bzero(_bytes, _length);
    free(_bytes);
    
    _bytes = newBytes;
    _length = newLength;
}

- (void)truncateToSize:(NSInteger)size
{
    NSParameterAssert(size <= _length);
    
    uint8_t *newBytes = pp_alloc_crypto(size);
    memcpy(newBytes, _bytes, size);

    bzero(_bytes, _length);
    free(_bytes);
    
    _bytes = newBytes;
    _length = size;
}

- (void)removeUntilOffset:(NSInteger)until
{
    NSParameterAssert(until <= _length);
    
    const NSInteger newLength = _length - until;
    uint8_t *newBytes = pp_alloc_crypto(newLength);
    memcpy(newBytes, _bytes + until, newLength);
    
    bzero(_bytes, _length);
    free(_bytes);
    
    _bytes = newBytes;
    _length = newLength;
}

- (void)zero
{
    bzero(_bytes, _length);
}

- (ZeroingData *)appendingData:(ZeroingData *)other
{
    NSParameterAssert(other);

    const NSInteger newLength = _length + other.length;
    uint8_t *newBytes = pp_alloc_crypto(newLength);
    memcpy(newBytes, _bytes, _length);
    memcpy(newBytes + _length, other.bytes, other.length);
    
    return [[ZeroingData alloc] initWithBytesNoCopy:newBytes length:newLength];
}

- (ZeroingData *)withOffset:(NSInteger)offset length:(NSInteger)length
{
    NSParameterAssert(offset + length <= _length);

    uint8_t *newBytes = pp_alloc_crypto(length);
    memcpy(newBytes, _bytes + offset, length);
    
    return [[ZeroingData alloc] initWithBytesNoCopy:newBytes length:length];
}

- (uint16_t)UInt16ValueFromOffset:(NSInteger)from
{
    NSParameterAssert(from + 2 <= _length);

    uint16_t value = 0;
    value |= _bytes[from];
    value |= _bytes[from + 1] << 8;
    return value;
}

- (uint16_t)networkUInt16ValueFromOffset:(NSInteger)from
{
    NSParameterAssert(from + 2 <= _length);
    
    uint16_t value = 0;
    value |= _bytes[from];
    value |= _bytes[from + 1] << 8;
    return CFSwapInt16BigToHost(value);
}

- (NSString *)nullTerminatedStringFromOffset:(NSInteger)from
{
    NSParameterAssert(from <= _length);

    NSInteger nullOffset = NSNotFound;
    for (NSInteger i = from; i < _length; ++i) {
        if (_bytes[i] == 0) {
            nullOffset = i;
            break;
        }
    }
    if (nullOffset == NSNotFound) {
        return nil;
    }
    const NSInteger stringLength = nullOffset - from;
    return [[NSString alloc] initWithBytes:_bytes length:stringLength encoding:NSUTF8StringEncoding];
}

- (BOOL)isEqual:(id)object
{
    NSParameterAssert(object);

    if (![object isKindOfClass:[ZeroingData class]]) {
        return NO;
    }
    ZeroingData *other = (ZeroingData *)object;
    if (other.length != _length) {
        return NO;
    }
    return !memcmp(_bytes, other.bytes, _length);
}

- (BOOL)isEqualToData:(NSData *)data
{
    NSParameterAssert(data);

    if (data.length != _length) {
        return NO;
    }
    return !memcmp(_bytes, data.bytes, _length);
}

- (NSData *)toData
{
    return [NSData dataWithBytes:_bytes length:_length];
}

- (NSString *)toHex
{
    const NSUInteger capacity = _length * 2;
    NSMutableString *hexString = [[NSMutableString alloc] initWithCapacity:capacity];
    for (int i = 0; i < _length; ++i) {
        [hexString appendFormat:@"%02x", _bytes[i]];
    }
    return hexString;
}

@end
