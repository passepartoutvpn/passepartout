//
//  CryptoCBC.m
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
#import <openssl/rand.h>

#import "Allocation.h"
#import "Crypto.h"
#import "CryptoCBC.h"
#import "ZeroingData.h"

const NSInteger CryptoCBCMaxHMACLength = 100;

@interface CryptoCBC ()

@property (nonatomic, unsafe_unretained) const EVP_CIPHER *cipher;
@property (nonatomic, unsafe_unretained) const EVP_MD *digest;
@property (nonatomic, unsafe_unretained) char *utfCipherName;
@property (nonatomic, unsafe_unretained) char *utfDigestName;
@property (nonatomic, assign) int cipherKeyLength;
@property (nonatomic, assign) int cipherIVLength;
@property (nonatomic, assign) int hmacKeyLength;
@property (nonatomic, assign) int digestLength;

@property (nonatomic, unsafe_unretained) EVP_MAC *mac;
@property (nonatomic, unsafe_unretained) OSSL_PARAM *macParams;
@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxEnc;
@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxDec;
@property (nonatomic, strong) ZeroingData *hmacKeyEnc;
@property (nonatomic, strong) ZeroingData *hmacKeyDec;
@property (nonatomic, unsafe_unretained) uint8_t *bufferDecHMAC;

@end

@implementation CryptoCBC

- (instancetype)initWithCipherName:(NSString *)cipherName digestName:(NSString *)digestName
{
    NSParameterAssert(!cipherName || [[cipherName uppercaseString] hasSuffix:@"CBC"]);
    NSParameterAssert(digestName);

    self = [super init];
    if (self) {
        if (cipherName) {
            self.utfCipherName = calloc([cipherName length] + 1, sizeof(char));
            strncpy(self.utfCipherName, [cipherName UTF8String], [cipherName length]);
            self.cipher = EVP_get_cipherbyname(self.utfCipherName);
            NSAssert(self.cipher, @"Unknown cipher '%@'", cipherName);
        }
        self.utfDigestName = calloc([digestName length] + 1, sizeof(char));
        strncpy(self.utfDigestName, [digestName UTF8String], [digestName length]);
        self.digest = EVP_get_digestbyname(self.utfDigestName);
        NSAssert(self.digest, @"Unknown digest '%@'", digestName);

        if (cipherName) {
            self.cipherKeyLength = EVP_CIPHER_key_length(self.cipher);
            self.cipherIVLength = EVP_CIPHER_iv_length(self.cipher);
        }
        // as seen in OpenVPN's crypto_openssl.c:md_kt_size()
        self.hmacKeyLength = (int)EVP_MD_size(self.digest);
        self.digestLength = (int)EVP_MD_size(self.digest);

        if (cipherName) {
            self.cipherCtxEnc = EVP_CIPHER_CTX_new();
            self.cipherCtxDec = EVP_CIPHER_CTX_new();
        }

        self.mac = EVP_MAC_fetch(NULL, "HMAC", NULL);
        OSSL_PARAM *macParams = calloc(2, sizeof(OSSL_PARAM));
        macParams[0] = OSSL_PARAM_construct_utf8_string("digest", self.utfDigestName, 0);
        macParams[1] = OSSL_PARAM_construct_end();
        self.macParams = macParams;

        self.bufferDecHMAC = pp_alloc_crypto(CryptoCBCMaxHMACLength);

        self.mappedError = ^NSError *(CryptoCBCError errorCode) {
            return [NSError errorWithDomain:PartoutCryptoErrorDomain code:0 userInfo:nil];
        };
    }
    return self;
}

- (void)dealloc
{
    if (self.cipher) {
        EVP_CIPHER_CTX_free(self.cipherCtxEnc);
        EVP_CIPHER_CTX_free(self.cipherCtxDec);
    }
    EVP_MAC_free(self.mac);
    free(self.macParams);
    bzero(self.bufferDecHMAC, CryptoCBCMaxHMACLength);
    free(self.bufferDecHMAC);

    if (self.utfCipherName) {
        free(self.utfCipherName);
    }
    free(self.utfDigestName);

    self.cipher = NULL;
    self.digest = NULL;
}

- (int)tagLength
{
    return 0;
}

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length
{
    return pp_alloc_crypto_capacity(length, self.digestLength + self.cipherIVLength);
}

#pragma mark Encrypter

- (void)configureEncryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(hmacKey);
    NSParameterAssert(hmacKey.length >= self.hmacKeyLength);

    if (self.cipher) {
        NSParameterAssert(cipherKey.length >= self.cipherKeyLength);

        EVP_CIPHER_CTX_reset(self.cipherCtxEnc);
        EVP_CipherInit(self.cipherCtxEnc, self.cipher, cipherKey.bytes, NULL, 1);
    }

    self.hmacKeyEnc = [[ZeroingData alloc] initWithBytes:hmacKey.bytes length:self.hmacKeyLength];
}

- (BOOL)encryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    uint8_t *outIV = dest + self.digestLength;
    uint8_t *outEncrypted = dest + self.digestLength + self.cipherIVLength;
    int l1 = 0, l2 = 0;
    size_t l3 = 0;
    int code = 1;

    if (self.cipher) {
        if (!flags || !flags->forTesting) {
            if (RAND_bytes(outIV, self.cipherIVLength) != 1) {
                if (error) {
                    *error = self.mappedError(CryptoCBCErrorRandomGenerator);
                }
                return NO;
            }
        }

        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxEnc, NULL, NULL, outIV, -1);
        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxEnc, outEncrypted, &l1, bytes, (int)length);
        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxEnc, outEncrypted + l1, &l2);
    }
    else {
        NSAssert(outEncrypted == outIV, @"cipherIVLength is non-zero");

        memcpy(outEncrypted, bytes, length);
        l1 = (int)length;
    }
    EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(self.mac);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_init(ctx, self.hmacKeyEnc.bytes, self.hmacKeyEnc.length, self.macParams);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_update(ctx, outIV, l1 + l2 + self.cipherIVLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_final(ctx, dest, &l3, self.digestLength);
    EVP_MAC_CTX_free(ctx);

    *destLength = l1 + l2 + self.cipherIVLength + self.digestLength;

    CRYPTO_OPENSSL_RETURN_STATUS(code, self.mappedError(CryptoCBCErrorGeneric))
}

#pragma mark Decrypter

- (void)configureDecryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(hmacKey);
    NSParameterAssert(hmacKey.length >= self.hmacKeyLength);

    if (self.cipher) {
        NSParameterAssert(cipherKey.length >= self.cipherKeyLength);

        EVP_CIPHER_CTX_reset(self.cipherCtxDec);
        EVP_CipherInit(self.cipherCtxDec, self.cipher, cipherKey.bytes, NULL, 0);
    }

    self.hmacKeyDec = [[ZeroingData alloc] initWithBytes:hmacKey.bytes length:self.hmacKeyLength];
}

- (BOOL)decryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    const uint8_t *iv = bytes + self.digestLength;
    const uint8_t *encrypted = bytes + self.digestLength + self.cipherIVLength;
    size_t l1 = 0, l2 = 0;
    int code = 1;

    EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(self.mac);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_init(ctx, self.hmacKeyDec.bytes, self.hmacKeyDec.length, self.macParams);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_update(ctx, bytes + self.digestLength, length - self.digestLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_final(ctx, self.bufferDecHMAC, &l1, self.digestLength);
    EVP_MAC_CTX_free(ctx);

    if (CRYPTO_OPENSSL_SUCCESS(code) && CRYPTO_memcmp(self.bufferDecHMAC, bytes, self.digestLength) != 0) {
        if (error) {
            *error = self.mappedError(CryptoCBCErrorHMAC);
        }
        return NO;
    }

    if (self.cipher) {
        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxDec, NULL, NULL, iv, -1);
        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxDec, dest, (int *)&l1, encrypted, (int)length - self.digestLength - self.cipherIVLength);
        CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxDec, dest + l1, (int *)&l2);

        *destLength = l1 + l2;
    } else {
        l2 = (int)length - l1;
        memcpy(dest, bytes + l1, l2);

        *destLength = l2;
    }

    CRYPTO_OPENSSL_RETURN_STATUS(code, self.mappedError(CryptoCBCErrorGeneric))
}

- (BOOL)verifyBytes:(const uint8_t *)bytes length:(NSInteger)length flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    size_t l1 = 0;
    int code = 1;

    EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(self.mac);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_init(ctx, self.hmacKeyDec.bytes, self.hmacKeyDec.length, self.macParams);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_update(ctx, bytes + self.digestLength, length - self.digestLength);
    CRYPTO_OPENSSL_TRACK_STATUS(code) EVP_MAC_final(ctx, self.bufferDecHMAC, &l1, self.digestLength);
    EVP_MAC_CTX_free(ctx);

    if (CRYPTO_OPENSSL_SUCCESS(code) && CRYPTO_memcmp(self.bufferDecHMAC, bytes, self.digestLength) != 0) {
        if (error) {
            *error = self.mappedError(CryptoCBCErrorHMAC);
        }
        return NO;
    }

    CRYPTO_OPENSSL_RETURN_STATUS(code, self.mappedError(CryptoCBCErrorGeneric))
}

@end
