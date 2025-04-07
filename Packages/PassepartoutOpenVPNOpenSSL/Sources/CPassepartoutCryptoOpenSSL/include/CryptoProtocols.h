//
//  CryptoProtocols.swift
//  Partout
//
//  Created by Davide De Rosa on 1/14/25.
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

#import <Foundation/Foundation.h>

@class ZeroingData;

NS_ASSUME_NONNULL_BEGIN

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
