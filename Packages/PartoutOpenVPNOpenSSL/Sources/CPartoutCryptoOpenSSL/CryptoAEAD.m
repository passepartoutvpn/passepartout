//
//  CryptoAEAD.m
//  Partout
//
//  Created by Davide De Rosa on 7/6/18.
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

#import "Allocation.h"
#import "Crypto.h"
#import "CryptoAEAD.h"
#import "ZeroingData.h"

@interface CryptoAEAD ()

@property (nonatomic, assign) NSInteger nsTagLength;
@property (nonatomic, assign) NSInteger idLength;

@property (nonatomic, unsafe_unretained) const EVP_CIPHER *cipher;
@property (nonatomic, assign) int cipherKeyLength;
@property (nonatomic, assign) int cipherIVLength;

@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxEnc;
@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxDec;
@property (nonatomic, unsafe_unretained) uint8_t *cipherIVEnc;
@property (nonatomic, unsafe_unretained) uint8_t *cipherIVDec;

@end

@implementation CryptoAEAD

- (instancetype)initWithCipherName:(NSString *)cipherName tagLength:(NSInteger)tagLength idLength:(NSInteger)idLength
{
    NSParameterAssert([[cipherName uppercaseString] hasSuffix:@"GCM"]);

    self = [super init];
    if (self) {
        self.nsTagLength = tagLength;
        self.idLength = idLength;

        self.cipher = EVP_get_cipherbyname([cipherName cStringUsingEncoding:NSASCIIStringEncoding]);
        NSAssert(self.cipher, @"Unknown cipher '%@'", cipherName);

        self.cipherKeyLength = EVP_CIPHER_key_length(self.cipher);
        self.cipherIVLength = EVP_CIPHER_iv_length(self.cipher);

        self.cipherCtxEnc = EVP_CIPHER_CTX_new();
        self.cipherCtxDec = EVP_CIPHER_CTX_new();
        self.cipherIVEnc = pp_alloc_crypto(self.cipherIVLength);
        self.cipherIVDec = pp_alloc_crypto(self.cipherIVLength);

        self.mappedError = ^NSError *(CryptoAEADError errorCode) {
            return [NSError errorWithDomain:PartoutCryptoErrorDomain code:0 userInfo:nil];
        };
    }
    return self;
}

- (void)dealloc
{
    EVP_CIPHER_CTX_free(self.cipherCtxEnc);
    EVP_CIPHER_CTX_free(self.cipherCtxDec);
    bzero(self.cipherIVEnc, self.cipherIVLength);
    bzero(self.cipherIVDec, self.cipherIVLength);
    free(self.cipherIVEnc);
    free(self.cipherIVDec);

    self.cipher = NULL;
}

- (int)digestLength
{
    return 0;
}

- (int)tagLength
{
    return (int)self.nsTagLength;
}

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length
{
    return pp_alloc_crypto_capacity(length, self.tagLength);
}

#pragma mark Encrypter

- (void)configureEncryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(cipherKey.length >= self.cipherKeyLength);
    NSParameterAssert(hmacKey);

    EVP_CIPHER_CTX_reset(self.cipherCtxEnc);
    EVP_CipherInit(self.cipherCtxEnc, self.cipher, cipherKey.bytes, NULL, 1);

    [self prepareIV:self.cipherIVEnc withHMACKey:hmacKey];
}

- (BOOL)encryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSParameterAssert(flags);

    int l1 = 0, l2 = 0;
    int x = 0;
    int code = 1;

    assert(flags->adLength >= self.idLength);
    memcpy(self.cipherIVEnc, flags->iv, MIN(flags->ivLength, self.cipherIVLength));

    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxEnc, NULL, NULL, self.cipherIVEnc, -1);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxEnc, NULL, &x, flags->ad, (int)flags->adLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxEnc, dest + self.tagLength, &l1, bytes, (int)length);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxEnc, dest + self.tagLength + l1, &l2);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CIPHER_CTX_ctrl(self.cipherCtxEnc, EVP_CTRL_GCM_GET_TAG, self.tagLength, dest);

    *destLength = self.tagLength + l1 + l2;

    //    NSLog(@">>> ENC iv: %@", [NSData dataWithBytes:self.cipherIVEnc length:self.cipherIVLength]);
    //    NSLog(@">>> ENC ad: %@", [NSData dataWithBytes:extra length:self.extraLength]);
    //    NSLog(@">>> ENC x: %d", x);
    //    NSLog(@">>> ENC tag: %@", [NSData dataWithBytes:dest length:self.tagLength]);
    //    NSLog(@">>> ENC dest: %@", [NSData dataWithBytes:dest + self.tagLength length:*destLength - self.tagLength]);

    CRYPTO_OPENSSL_RETURN_STATUS(code, self.mappedError(CryptoAEADErrorGeneric))
}

#pragma mark Decrypter

- (void)configureDecryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(cipherKey.length >= self.cipherKeyLength);
    NSParameterAssert(hmacKey);

    EVP_CIPHER_CTX_reset(self.cipherCtxDec);
    EVP_CipherInit(self.cipherCtxDec, self.cipher, cipherKey.bytes, NULL, 0);

    [self prepareIV:self.cipherIVDec withHMACKey:hmacKey];
}

- (BOOL)decryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSParameterAssert(flags);

    int l1 = 0, l2 = 0;
    int x = 0;
    int code = 1;

    assert(flags->adLength >= self.idLength);
    memcpy(self.cipherIVDec, flags->iv, MIN(flags->ivLength, self.cipherIVLength));

    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxDec, NULL, NULL, self.cipherIVDec, -1);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CIPHER_CTX_ctrl(self.cipherCtxDec, EVP_CTRL_GCM_SET_TAG, self.tagLength, (uint8_t *)bytes);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxDec, NULL, &x, flags->ad, (int)flags->adLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxDec, dest, &l1, bytes + self.tagLength, (int)length - self.tagLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxDec, dest + l1, &l2);

    *destLength = l1 + l2;

    //    NSLog(@">>> DEC iv: %@", [NSData dataWithBytes:self.cipherIVDec length:self.cipherIVLength]);
    //    NSLog(@">>> DEC ad: %@", [NSData dataWithBytes:extra length:self.extraLength]);
    //    NSLog(@">>> DEC x: %d", x);
    //    NSLog(@">>> DEC tag: %@", [NSData dataWithBytes:bytes length:self.tagLength]);
    //    NSLog(@">>> DEC dest: %@", [NSData dataWithBytes:dest length:*destLength]);

    CRYPTO_OPENSSL_RETURN_STATUS(code, self.mappedError(CryptoAEADErrorGeneric))
}

- (BOOL)verifyBytes:(const uint8_t *)bytes length:(NSInteger)length flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    [NSException raise:NSInvalidArgumentException format:@"Verification not supported"];
    return NO;
}

#pragma mark Helpers

- (void)prepareIV:(uint8_t *)iv withHMACKey:(ZeroingData *)hmacKey
{
    bzero(iv, self.idLength);
    memcpy(iv + self.idLength, hmacKey.bytes, self.cipherIVLength - self.idLength);
}

@end
