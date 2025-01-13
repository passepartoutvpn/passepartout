//
//  Crypto.h
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/3/17.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
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

@class ZeroingData;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PassepartoutCryptoErrorDomain;

/// - Parameters:
///   - size: The base number of bytes.
///   - overhead: The extra number of bytes.
/// - Returns: The number of bytes to store a crypto buffer safely.
size_t pp_alloc_crypto_capacity(size_t size, size_t overhead);

/// Custom flags for encryption routines.
typedef struct {

    /// A custom initialization vector (IV).
    const uint8_t *_Nullable iv;

    /// The length of ``iv``.
    NSInteger ivLength;

    /// A custom associated data for AEAD (AD).
    const uint8_t *_Nullable ad;

    /// The length of ``ad``.
    NSInteger adLength;

    /// Enable testable (predictable) behavior.
    BOOL forTesting;
} CryptoFlags;

@protocol Crypto

/// The digest length or 0.
- (int)digestLength;

/// The tag length or 0.
- (int)tagLength;

/// The preferred encryption capacity.
/// - Parameter length: The number of bytes to encrypt.
- (NSInteger)encryptionCapacityWithLength:(NSInteger)length;

@end

@protocol Encrypter <Crypto>

/// Configures the object.
/// - Parameters:
///   - cipherKey: The cipher key data.
///   - hmacKey: The HMAC key data.
- (void)configureEncryptionWithCipherKey:(nullable ZeroingData *)cipherKey hmacKey:(nullable ZeroingData *)hmacKey;

/// Encrypts a buffer.
/// - Parameters:
///   - bytes: Bytes to encrypt.
///   - length: The number of bytes.
///   - dest: The destination buffer.
///   - destLength: The number of bytes written to ``dest``.
///   - flags: The optional encryption flags.
- (BOOL)encryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;

@end

@protocol Decrypter <Crypto>

/// Configures the object.
/// - Parameters:
///   - cipherKey: The cipher key data.
///   - hmacKey: The HMAC key data.
- (void)configureDecryptionWithCipherKey:(nullable ZeroingData *)cipherKey hmacKey:(nullable ZeroingData *)hmacKey;

/// Decrypts a buffer.
/// - Parameters:
///   - bytes: Bytes to decrypt.
///   - length: The number of bytes.
///   - dest: The destination buffer.
///   - destLength: The number of bytes written to ``dest``.
///   - flags: The optional encryption flags.
- (BOOL)decryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;

/// Verifies an encrypted buffer.
/// - Parameters:
///   - bytes: Bytes to decrypt.
///   - length: The number of bytes.
///   - flags: The optional encryption flags.
- (BOOL)verifyBytes:(const uint8_t *)bytes length:(NSInteger)length flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
