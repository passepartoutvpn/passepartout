//
//  OSSLCryptoBox.m
//  Partout
//
//  Created by Davide De Rosa on 2/4/17.
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

#import <openssl/evp.h>
#import <openssl/hmac.h>
#import <openssl/rand.h>

#import "OSSLCryptoBox.h"
#import "CryptoCBC+OpenVPN.h"
#import "CryptoAEAD+OpenVPN.h"
#import "CryptoCTR+OpenVPN.h"
#import "Errors.h"
#import "PacketMacros.h"

@import CPartoutCryptoOpenSSL;

static const NSInteger CryptoAEADTagLength = 16;
static const NSInteger CryptoAEADIdLength = PacketIdLength;
static const NSInteger CryptoCTRTagLength = 32;
static const NSInteger CryptoCTRPayloadLength = PacketOpcodeLength + PacketSessionIdLength + PacketReplayIdLength + PacketReplayTimestampLength;

@interface OSSLCryptoBox ()

@property (nonatomic, strong) OpenVPNCryptoOptions *options;

@property (nonatomic, strong) id<Encrypter, DataPathEncrypterProvider> encrypter;
@property (nonatomic, strong) id<Decrypter, DataPathDecrypterProvider> decrypter;

@end

@implementation OSSLCryptoBox

#pragma mark Initialization

- (instancetype)initWithSeed:(ZeroingData *)seed
{
    if ((self = [super init])) {
        unsigned char x[1];
        // make sure its initialized before seeding
        if (RAND_bytes(x, 1) != 1) {
            return nil;
        }
        RAND_seed(seed.bytes, (int)seed.length);
    }
    return self;
}

- (void)dealloc
{
    self.encrypter = nil;
    self.decrypter = nil;
}

// these keys are coming from the OpenVPN negotiation despite the cipher
- (BOOL)configureWithOptions:(OpenVPNCryptoOptions *)options error:(NSError *__autoreleasing  *)error
{
    NSAssert(self.options == nil, @"Already configured");

    if (options.cipherAlgorithm) {
        if ([options.cipherAlgorithm hasSuffix:@"-cbc"]) {
            if (!options.digestAlgorithm) {
                if (error) {
                    *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoAlgorithm);
                }
                return NO;
            }
            CryptoCBC *cbc = [[CryptoCBC alloc] initWithCipherName:options.cipherAlgorithm
                                                        digestName:options.digestAlgorithm];

            cbc.mappedError = ^NSError *(CryptoCBCError errorCode) {
                switch (errorCode) {
                case CryptoCBCErrorGeneric:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoEncryption);

                case CryptoCBCErrorRandomGenerator:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoRandomGenerator);

                case CryptoCBCErrorHMAC:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoHMAC);
                }
            };

            self.encrypter = cbc;
            self.decrypter = cbc;
        }
        else if ([options.cipherAlgorithm hasSuffix:@"-gcm"]) {
            CryptoAEAD *gcm = [[CryptoAEAD alloc] initWithCipherName:options.cipherAlgorithm
                                                           tagLength:CryptoAEADTagLength
                                                            idLength:CryptoAEADIdLength];

            gcm.mappedError = ^NSError *(CryptoAEADError errorCode) {
                switch (errorCode) {
                case CryptoAEADErrorGeneric:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoEncryption);
                }
            };

            self.encrypter = gcm;
            self.decrypter = gcm;
        }
        else if ([options.cipherAlgorithm hasSuffix:@"-ctr"]) {
            CryptoCTR *ctr = [[CryptoCTR alloc] initWithCipherName:options.cipherAlgorithm
                                                        digestName:options.digestAlgorithm
                                                         tagLength:CryptoCTRTagLength
                                                     payloadLength:CryptoCTRPayloadLength];

            ctr.mappedError = ^NSError *(CryptoCTRError errorCode) {
                switch (errorCode) {
                case CryptoCTRErrorGeneric:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoEncryption);

                case CryptoCTRErrorHMAC:
                    return OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoHMAC);
                }
            };

            self.encrypter = ctr;
            self.decrypter = ctr;
        }
        // not supported
        else {
            if (error) {
                *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoAlgorithm);
            }
            return NO;
        }
    }
    else {
        CryptoCBC *cbc = [[CryptoCBC alloc] initWithCipherName:nil digestName:options.digestAlgorithm];
        self.encrypter = cbc;
        self.decrypter = cbc;
    }
    
    [self.encrypter configureEncryptionWithCipherKey:options.cipherEncKey hmacKey:options.hmacEncKey];
    [self.decrypter configureDecryptionWithCipherKey:options.cipherDecKey hmacKey:options.hmacDecKey];

    NSAssert(self.encrypter.digestLength == self.decrypter.digestLength, @"Digest length mismatch in encrypter/decrypter");

    self.options = options;

    return YES;
}

#pragma mark Implementation

- (NSString *)version
{
    return [NSString stringWithCString:OpenSSL_version(OPENSSL_VERSION) encoding:NSASCIIStringEncoding];
}

- (NSInteger)digestLength
{
    return self.encrypter.digestLength;
}

- (NSInteger)tagLength
{
    return self.encrypter.tagLength;
}

- (BOOL)hmacWithDigestName:(NSString *)digestName
                    secret:(const uint8_t *)secret
              secretLength:(NSInteger)secretLength
                      data:(const uint8_t *)data
                dataLength:(NSInteger)dataLength
                      hmac:(uint8_t *)hmac
                hmacLength:(NSInteger *)hmacLength
                     error:(NSError **)error
{
    NSParameterAssert(digestName);
    NSParameterAssert(secret);
    NSParameterAssert(data);
    
    unsigned int l = 0;

    const BOOL success = HMAC(EVP_get_digestbyname([digestName cStringUsingEncoding:NSASCIIStringEncoding]),
                              secret,
                              (int)secretLength,
                              data,
                              dataLength,
                              hmac,
                              &l) != NULL;

    *hmacLength = l;

    return success;
}

@end
