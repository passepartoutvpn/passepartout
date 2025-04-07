//
//  OpenVPNCryptoProtocol.h
//  Partout
//
//  Created by Davide De Rosa on 2/26/24.
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

#import "CryptoProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenVPNCryptoOptions : NSObject

- (instancetype)initWithCipherAlgorithm:(nullable NSString *)cipherAlgorithm
                        digestAlgorithm:(nullable NSString *)digestAlgorithm
                           cipherEncKey:(nullable ZeroingData *)cipherEncKey
                           cipherDecKey:(nullable ZeroingData *)cipherDecKey
                             hmacEncKey:(nullable ZeroingData *)hmacEncKey
                             hmacDecKey:(nullable ZeroingData *)hmacDecKey;

- (nullable NSString *)cipherAlgorithm;
- (nullable NSString *)digestAlgorithm;
- (nullable ZeroingData *)cipherEncKey;
- (nullable ZeroingData *)cipherDecKey;
- (nullable ZeroingData *)hmacEncKey;
- (nullable ZeroingData *)hmacDecKey;

@end

@protocol OpenVPNCryptoProtocol <CryptoProvider>

#pragma mark Initialization

- (BOOL)configureWithOptions:(OpenVPNCryptoOptions *)options error:(NSError **)error;
- (nullable OpenVPNCryptoOptions *)options;

#pragma mark Metadata

- (NSString *)version;
- (NSInteger)digestLength;
- (NSInteger)tagLength;

#pragma mark Helpers

// WARNING: hmac must be able to hold HMAC result
- (BOOL)hmacWithDigestName:(NSString *)digestName
                    secret:(const uint8_t *)secret
              secretLength:(NSInteger)secretLength
                      data:(const uint8_t *)data
                dataLength:(NSInteger)dataLength
                      hmac:(uint8_t *)hmac
                hmacLength:(NSInteger *)hmacLength
                     error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
