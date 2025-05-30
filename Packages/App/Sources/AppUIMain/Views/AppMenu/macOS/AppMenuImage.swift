//
//  AppMenuImage.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

#if os(macOS)

import CommonLibrary
import SwiftUI

public struct AppMenuImage: View {

    @ObservedObject
    private var tunnel: ExtendedTunnel

    public init(tunnel: ExtendedTunnel) {
        self.tunnel = tunnel
    }

    public var body: some View {
        ThemeMenuImage(connectionStatus.imageName)
    }
}

private extension AppMenuImage {
    var connectionStatus: TunnelStatus {
        // TODO: #218, must be per-tunnel
        guard let id = tunnel.activeProfiles.first?.value.id else {
            return .inactive
        }
        return tunnel.connectionStatus(ofProfileId: id)
    }
}

private extension TunnelStatus {
    var imageName: Theme.MenuImageName {
        switch self {
        case .active:
            return .active

        case .inactive:
            return .inactive

        case .activating, .deactivating:
            return .pending
        }
    }
}

#endif
