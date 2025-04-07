//
//  ControlPacket.h
//  Partout
//
//  Created by Davide De Rosa on 9/14/18.
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

#import "PacketMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol Encrypter;

@interface ControlPacket : NSObject<PacketProtocol>

- (instancetype)initWithCode:(PacketCode)code
                         key:(uint8_t)key
                   sessionId:(NSData *)sessionId
                    packetId:(uint32_t)packetId
                     payload:(nullable NSData *)payload
                      ackIds:(nullable NSArray<NSNumber *> *)ackIds
          ackRemoteSessionId:(nullable NSData *)ackRemoteSessionId;

- (instancetype)initWithKey:(uint8_t)key
                  sessionId:(NSData *)sessionId
                     ackIds:(NSArray<NSNumber *> *)ackIds
         ackRemoteSessionId:(NSData *)ackRemoteSessionId;

@property (nonatomic, assign, readonly) PacketCode code;
@property (nonatomic, assign, readonly) BOOL isAck;
@property (nonatomic, assign, readonly) uint8_t key;
@property (nonatomic, strong, readonly) NSData *sessionId;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *_Nullable ackIds; // uint32_t
@property (nonatomic, strong, readonly) NSData *_Nullable ackRemoteSessionId;
@property (nonatomic, assign, readonly) uint32_t packetId;
@property (nonatomic, strong, readonly) NSData *_Nullable payload;

- (NSData *)serialized;

@end

@interface ControlPacket (Authentication)

- (nullable NSData *)serializedWithAuthenticator:(id<Encrypter>)auth replayId:(uint32_t)replayId timestamp:(uint32_t)timestamp error:(NSError * _Nullable __autoreleasing *)error;

@end

@interface ControlPacket (Encryption)

- (nullable NSData *)serializedWithEncrypter:(id<Encrypter>)encrypter replayId:(uint32_t)replayId timestamp:(uint32_t)timestamp adLength:(NSInteger)adLength error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
