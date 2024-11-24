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

struct ProfileRowView: View, Routable, SizeClassProviding {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.horizontalSizeClass)
    var hsClass

    @Environment(\.verticalSizeClass)
    var vsClass

    let style: ProfileCardView.Style

    @ObservedObject
    var profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    let preview: ProfilePreview

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    @Binding
    var nextProfileId: Profile.ID?

    let withMarker: Bool

    var flow: ProfileFlow?

    var body: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: .zero)
            HStack {
                Group {
                    if withMarker {
                        markerView
                    }
                    cardView
                }
                Spacer()
                HStack(spacing: 8) {
                    ProfileAttributesView(
                        attributes: attributes,
                        isRemoteImportingEnabled: profileManager.isRemoteImportingEnabled
                    )
                    .imageScale(isBigDevice ? .large : .medium)

                    ProfileInfoButton(preview: preview) {
                        flow?.onEditProfile($0)
                    }
                    .imageScale(.large)
                }
            }
            Spacer(minLength: .zero)
        }
    }
}

// MARK: - Subviews (observing)

private struct MarkerView: View {
    let profileId: Profile.ID

    let nextProfileId: Profile.ID?

    @ObservedObject
    var tunnel: ExtendedTunnel

    let requiredFeatures: Set<AppFeature>?

    var body: some View {
        ZStack {
            ThemeImage(profileId == nextProfileId ? .pending : tunnel.statusImageName)
                .opaque(requiredFeatures == nil && (profileId == nextProfileId || profileId == tunnel.currentProfile?.id))

            if let requiredFeatures {
                PurchaseRequiredButton(features: requiredFeatures, paywallReason: .constant(nil))
            }
        }
        .frame(width: 24)
    }
}

private extension ProfileRowView {
    var profile: Profile? {
        profileManager.profile(withId: preview.id)
    }

    var markerView: some View {
        MarkerView(
            profileId: preview.id,
            nextProfileId: nextProfileId,
            tunnel: tunnel,
            requiredFeatures: requiredFeatures
        )
    }

    var cardView: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profile,
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            onProviderEntityRequired: {
                flow?.onProviderEntityRequired($0)
            },
            onPurchaseRequired: {
                flow?.onPurchaseRequired($0)
            },
            label: { _ in
                ProfileCardView(
                    style: style,
                    preview: preview
                )
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
            }
        )
        .foregroundStyle(.primary)
    }

    var attributes: [ProfileAttributesView.Attribute] {
        if isTV {
            return [.tv]
        } else if isShared {
            return [.shared]
        }
        return []
    }

    var requiredFeatures: Set<AppFeature>? {
        profileManager.requiredFeatures(forProfileWithId: preview.id)
    }

    var isShared: Bool {
        profileManager.isRemotelyShared(profileWithId: preview.id)
    }

    var isTV: Bool {
        isShared && profileManager.isAvailableForTV(profileWithId: preview.id)
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
            preview: .init(profile),
            interactiveManager: InteractiveManager(),
            errorHandler: .default(),
            nextProfileId: .constant(nil),
            withMarker: true
        )
    }
    .task {
        do {
            try await profileManager.observeRemote(true)
            try await profileManager.save(profile, isLocal: true, remotelyShared: true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    .themeForm()
    .withMockEnvironment()
}
