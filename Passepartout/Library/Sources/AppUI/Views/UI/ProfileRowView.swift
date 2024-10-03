//
//  ProfileRowView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/5/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import AppLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct ProfileRowView: View, TunnelContextProviding {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    var connectionObserver: ConnectionObserver

    let style: ProfileCardView.Style

    let profileManager: ProfileManager

    @ObservedObject
    var tunnel: Tunnel

    let header: ProfileHeader

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    @Binding
    var nextProfileId: Profile.ID?

    let withMarker: Bool

    let onEdit: (ProfileHeader) -> Void

    var body: some View {
        HStack {
            if withMarker {
                markerView
            }
            cardView
            Spacer()
            ProfileInfoButton(header: header, onEdit: onEdit)
        }
    }
}

private extension ProfileRowView {
    var markerView: some View {
        ThemeImage(header.id == nextProfileId ? .pending : statusImage)
            .opacity(header.id == nextProfileId || header.id == tunnel.currentProfile?.id ? 1.0 : 0.0)
            .frame(width: 24.0)
    }

    var cardView: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profileManager.profile(withId: header.id),
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler
        ) { _ in
            ProfileCardView(
                style: style,
                header: header,
                profileManager: profileManager
            )
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
    }

    var statusImage: Theme.ImageName {
        switch tunnelConnectionStatus {
        case .active:
            return .marked

        case .activating, .deactivating:
            return .pending

        case .inactive:
            return .sleeping
        }
    }
}
