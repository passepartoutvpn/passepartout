//
//  Theme+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/6/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import SwiftUI

extension ModuleBuilder {

    @MainActor
    public var themeIcon: Theme.ImageName {
        switch moduleType {
        case .openVPN, .wireGuard:
            .moduleConnection
        case .onDemand:
            .moduleOnDemand
        case .dns, .httpProxy, .ip:
            .moduleSettings
        default:
            .moduleSettings
        }
    }
}

extension TunnelStatus {

    @MainActor
    public func color(_ theme: Theme) -> Color {
        switch self {
        case .active:
            return theme.activeColor
        case .activating, .deactivating:
            return theme.pendingColor
        case .inactive:
            return theme.inactiveColor
        }
    }
}

extension ExtendedTunnel {
    public func statusImageName(ofProfileId profileId: Profile.ID) -> Theme.ImageName? {
        connectionStatus(ofProfileId: profileId).imageName
    }

    public func statusColor(ofProfileId profileId: Profile.ID, _ theme: Theme) -> Color {
        if lastErrorCode(ofProfileId: profileId) != nil {
            switch status(ofProfileId: profileId) {
            case .inactive:
                return theme.inactiveColor
            default:
                return theme.errorColor
            }
        }
        switch connectionStatus(ofProfileId: profileId) {
        case .active:
            return theme.activeColor
        case .activating, .deactivating:
            return theme.pendingColor
        case .inactive:
            return activeProfiles[profileId]?.onDemand == true ? theme.pendingColor : theme.inactiveColor
        }
    }
}

private extension TunnelStatus {
    var imageName: Theme.ImageName? {
        switch self {
        case .active:
            return .marked
        case .activating, .deactivating:
            return .pending
        case .inactive:
            return nil
        }
    }
}
