//
//  ProcessTransformer.m
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ProcessTransformer.h"

@import AppKit;
@import ApplicationServices;
//@import Carbon;

// https://stackoverflow.com/a/22242797/784615

@interface ProcessTransformer ()

@property (nonatomic) BOOL isForeground;

- (BOOL)tranformAppToState:(ProcessApplicationTransformState)newState;

@end

@implementation ProcessTransformer

- (instancetype)init
{
    if ((self = [super init])) {
        self.isForeground = YES;
    }
    return self;
}

- (BOOL)toggleForeground
{
    if (self.isForeground) {
        return [self sendToBackground];
    } else {
        return [self bringToForeground];
    }
}

- (BOOL)bringToForeground
{
    if (![self tranformAppToState:kProcessTransformToForegroundApplication]) {
        return NO;
    }
//    if (SetSystemUIMode(kUIModeNormal, 0) != 0) {
//        return NO;
//    }
    [NSApp activateIgnoringOtherApps:YES];
    self.isForeground = YES;
    return YES;
}

- (BOOL)sendToBackground
{
    if (![self tranformAppToState:kProcessTransformToBackgroundApplication]) {
        return NO;
    }
    self.isForeground = NO;
    return YES;
}

- (BOOL)tranformAppToState:(ProcessApplicationTransformState)newState
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    OSStatus transformStatus = TransformProcessType(&psn, newState);

    if ((transformStatus != 0)) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:transformStatus userInfo:nil];
        NSLog(@"tranformAppToState: Unable to transform app state: %@", error);
    }

    return (transformStatus == 0);
}

@end
