//
//  OpenVPNTLSProtocol.m
//  Partout
//
//  Created by Davide De Rosa on 2/27/24.
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

#import "OpenVPNTLSProtocol.h"

const NSInteger OpenVPNTLSOptionsDefaultBufferLength = 16384;
const NSInteger OpenVPNTLSOptionsDefaultSecurityLevel = 0;

@interface OpenVPNTLSOptions ()

@property (nonatomic, assign) NSInteger bufferLength;
@property (nonatomic, strong) NSURL *caURL;
@property (nonatomic, copy) NSString *clientCertificatePEM;
@property (nonatomic, copy) NSString *clientKeyPEM;
@property (nonatomic, assign) BOOL checksEKU;
@property (nonatomic, assign) BOOL checksSANHost;
@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, assign) NSInteger securityLevel;

@end

@implementation OpenVPNTLSOptions

- (instancetype)initWithBufferLength:(NSInteger)bufferLength
                               caURL:(NSURL *)caURL
                clientCertificatePEM:(NSString *)clientCertificatePEM
                        clientKeyPEM:(NSString *)clientKeyPEM
                           checksEKU:(BOOL)checksEKU
                       checksSANHost:(BOOL)checksSANHost
                            hostname:(NSString *)hostname
                       securityLevel:(NSInteger)securityLevel
{
    if ((self = [super init])) {
        self.bufferLength = bufferLength != 0 ? bufferLength : OpenVPNTLSOptionsDefaultBufferLength;
        self.caURL = caURL;
        self.clientCertificatePEM = clientCertificatePEM;
        self.clientKeyPEM = clientKeyPEM;
        self.checksEKU = checksEKU;
        self.checksSANHost = checksSANHost;
        self.hostname = hostname;
        self.securityLevel = securityLevel > OpenVPNTLSOptionsDefaultSecurityLevel ? securityLevel : OpenVPNTLSOptionsDefaultSecurityLevel;
    }
    return self;
}

@end
