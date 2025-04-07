//
//  OpenVPNTLSProtocol.h
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

extern const NSInteger OpenVPNTLSOptionsDefaultBufferLength;
extern const NSInteger OpenVPNTLSOptionsDefaultSecurityLevel;

@interface OpenVPNTLSOptions : NSObject

- (instancetype)initWithBufferLength:(NSInteger)bufferLength
                               caURL:(NSURL *)caURL
                clientCertificatePEM:(nullable NSString *)clientCertificatePEM
                        clientKeyPEM:(nullable NSString *)clientKeyPEM
                           checksEKU:(BOOL)checksEKU
                       checksSANHost:(BOOL)checksSANHost
                            hostname:(nullable NSString *)hostname
                       securityLevel:(NSInteger)securityLevel;

- (NSInteger)bufferLength;
- (NSURL *)caURL;
- (nullable NSString *)clientCertificatePEM;
- (nullable NSString *)clientKeyPEM;
- (BOOL)checksEKU;
- (BOOL)checksSANHost;
- (nullable NSString *)hostname;
- (NSInteger)securityLevel;

@end

@protocol OpenVPNTLSProtocol

#pragma mark Initialization

- (BOOL)configureWithOptions:(OpenVPNTLSOptions *)options onFailure:(void (^)(NSError *))onFailure error:(NSError **)error;
- (nullable OpenVPNTLSOptions *)options;

#pragma mark Handshake

- (BOOL)startWithError:(NSError **)error;

- (nullable NSData *)pullCipherTextWithError:(NSError **)error;
- (BOOL)pullRawPlainText:(uint8_t *)text length:(NSInteger *)length error:(NSError **)error;

- (BOOL)putCipherText:(NSData *)text error:(NSError **)error;
- (BOOL)putRawCipherText:(const uint8_t *)text length:(NSInteger)length error:(NSError **)error;
- (BOOL)putPlainText:(NSString *)text error:(NSError **)error;
- (BOOL)putRawPlainText:(const uint8_t *)text length:(NSInteger)length error:(NSError **)error;

- (BOOL)isConnected;

#pragma mark Helpers

- (nullable NSString *)md5ForCertificatePath:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
