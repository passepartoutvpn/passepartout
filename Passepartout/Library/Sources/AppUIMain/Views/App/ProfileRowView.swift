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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ProfileRowView: View, Routable {

    @EnvironmentObject
    private var theme: Theme

    let style: ProfileCardView.Style

    @ObservedObject
    var profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    let header: ProfileHeader

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    @Binding
    var nextProfileId: Profile.ID?

    let withMarker: Bool

    var flow: ProfileFlow?

    var body: some View {
        HStack {
            Group {
                if withMarker {
                    markerView
                }
                cardView
            }
            Spacer()
            HStack(spacing: 10.0) {
                ProfileAttributesView(
                    isShared: isShared,
                    isTV: isTV,
                    isRemoteImportingEnabled: profileManager.isRemoteImportingEnabled
                )
                ProfileInfoButton(header: header) {
                    flow?.onEditProfile($0)
                }
            }
            .imageScale(.large)
        }
    }
}

// MARK: - Subviews (observing)

private struct MarkerView: View {
    let headerId: Profile.ID

    let nextProfileId: Profile.ID?

    @ObservedObject
    var tunnel: ExtendedTunnel

    var body: some View {
        ThemeImage(headerId == nextProfileId ? .pending : statusImage)
            .opaque(headerId == nextProfileId || headerId == tunnel.currentProfile?.id)
            .frame(width: 24.0)
    }

    var statusImage: Theme.ImageName {
        switch tunnel.connectionStatus {
        case .active:
            return .marked

        case .activating, .deactivating:
            return .pending

        case .inactive:
            return .sleeping
        }
    }
}

private extension ProfileRowView {
    var markerView: some View {
        MarkerView(
            headerId: header.id,
            nextProfileId: nextProfileId,
            tunnel: tunnel
        )
    }

    var cardView: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profileManager.profile(withId: header.id),
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            onProviderEntityRequired: flow?.onEditProviderEntity,
            label: { _ in
                ProfileCardView(
                    style: style,
                    header: header
                )
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
            }
        )
        .foregroundStyle(.primary)
    }

    var isShared: Bool {
        profileManager.isRemotelyShared(profileWithId: header.id)
    }

    var isTV: Bool {
        isShared && profileManager.isAvailableForTV(profileWithId: header.id)
    }
}

// MARK: - Previews

#Preview {
    let profile: Profile = .mock
    let profileManager: ProfileManager = .mock

    return Form {
        ProfileRowView(
            style: .compact,
            profileManager: profileManager,
            tunnel: .mock,
            header: profile.header(),
            interactiveManager: InteractiveManager(),
            errorHandler: .default(),
            nextProfileId: .constant(nil),
            withMarker: true
        )
    }
    .task {
        do {
            try await profileManager.observeRemote(true)
            try await profileManager.save(profile, force: true, remotelyShared: true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    .themeForm()
    .withMockEnvironment()
}
