//
//  OpenVPNCryptoProtocol.m
//  Partout
//
//  Created by Davide De Rosa on 5/8/24.
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

#import "OpenVPNCryptoProtocol.h"

@interface OpenVPNCryptoOptions ()

@property (nonatomic, copy) NSString *cipherAlgorithm;
@property (nonatomic, copy) NSString *digestAlgorithm;
@property (nonatomic, strong) ZeroingData *cipherEncKey;
@property (nonatomic, strong) ZeroingData *cipherDecKey;
@property (nonatomic, strong) ZeroingData *hmacEncKey;
@property (nonatomic, strong) ZeroingData *hmacDecKey;

@end

@implementation OpenVPNCryptoOptions

- (instancetype)initWithCipherAlgorithm:(NSString *)cipherAlgorithm
                        digestAlgorithm:(NSString *)digestAlgorithm
                           cipherEncKey:(ZeroingData *)cipherEncKey
                           cipherDecKey:(ZeroingData *)cipherDecKey
                             hmacEncKey:(ZeroingData *)hmacEncKey
                             hmacDecKey:(ZeroingData *)hmacDecKey
{
    NSParameterAssert(cipherAlgorithm || digestAlgorithm);
    NSParameterAssert((cipherEncKey && cipherDecKey) || (hmacEncKey && hmacDecKey));

    if ((self = [super init])) {
        self.cipherAlgorithm = [cipherAlgorithm lowercaseString];
        self.digestAlgorithm = [digestAlgorithm lowercaseString];
        self.cipherEncKey = cipherEncKey;
        self.cipherDecKey = cipherDecKey;
        self.hmacEncKey = hmacEncKey;
        self.hmacDecKey = hmacDecKey;
    }
    return self;
}

@end
