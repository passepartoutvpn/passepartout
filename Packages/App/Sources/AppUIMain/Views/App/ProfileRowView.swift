//
//  ProfileRowView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/5/24.
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
import CommonUtils
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

    let errorHandler: ErrorHandler

    var flow: ProfileFlow?

    var body: some View {
        HStack {
            cardView
            Spacer()
            sharingView
            tunnelToggle
        }
        .unanimated()
    }
}

private extension ProfileRowView {
    var cardView: some View {
        ProfileCardView(
            style: style,
            preview: preview,
            tunnel: tunnel,
            onTap: flow?.onEditProfile
        )
        .contentShape(.rect)
        .foregroundStyle(.primary)
    }

    var sharingView: some View {
        ProfileSharingView(
            profileManager: profileManager,
            profileId: preview.id
        )
        .imageScale(isBigDevice ? .large : .medium)
    }

    var tunnelToggle: some View {
        TunnelToggle(
            tunnel: tunnel,
            profile: profile,
            errorHandler: errorHandler,
            flow: flow?.connectionFlow
        )
        .labelsHidden()
        .uiAccessibility(.App.profileToggle)
    }
}

private extension ProfileRowView {
    var profile: Profile? {
        profileManager.profile(withId: preview.id)
    }

    var requiredFeatures: Set<AppFeature>? {
        profileManager.requiredFeatures(forProfileWithId: preview.id)
    }
}

// MARK: - Previews

#Preview {
    let profile: Profile = .forPreviews
    let profileManager: ProfileManager = .forPreviews

    return Form {
        ProfileRowView(
            style: .full,
            profileManager: profileManager,
            tunnel: .forPreviews,
            preview: .init(profile),
            errorHandler: .default()
        )
    }
    .task {
        do {
            try await profileManager.observeRemote(repository: InMemoryProfileRepository())
            try await profileManager.save(profile, isLocal: true, remotelyShared: true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    .themeForm()
    .withMockEnvironment()
}
