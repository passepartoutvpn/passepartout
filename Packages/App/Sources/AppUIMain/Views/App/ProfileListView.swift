//
//  ProfileListView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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
import PassepartoutKit
import SwiftUI

struct ProfileListView: View, Routable, TunnelInstallationProviding {

    @Environment(\.horizontalSizeClass)
    private var hsClass

    @Environment(\.verticalSizeClass)
    private var vsClass

    @Environment(\.isSearching)
    private var isSearching

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var tunnel: ExtendedTunnel

    let isVerifying: Bool

    let errorHandler: ErrorHandler

    var flow: ProfileFlow?

    var body: some View {
        debugChanges()
        return Form {
            if !isSearching {
                headerView
                    .unanimated()
            }
            Section {
                ForEach(allPreviews, content: profileView)
                    .onDelete { offsets in
                        Task {
                            await profileManager.removeProfiles(at: offsets)
                        }
                    }
            } header: {
                VerificationView(isVerifying: isVerifying)
            }
        }
        .themeForm()
        .themeAnimation(on: profileManager.isReady, category: .profiles)
        .themeAnimation(on: profileManager.previews, category: .profiles)
    }
}

private extension ProfileListView {
    var allPreviews: [ProfilePreview] {
        profileManager.previews
    }

    var headerView: some View {
        InstalledProfileView(
            layout: .list,
            profileManager: profileManager,
            profile: currentProfile,
            tunnel: tunnel,
            errorHandler: errorHandler,
            flow: flow
        )
        .contextMenu {
            currentProfile.map {
                ProfileContextMenu(
                    style: .installedProfile,
                    profileManager: profileManager,
                    tunnel: tunnel,
                    preview: .init($0),
                    errorHandler: errorHandler,
                    flow: flow
                )
            }
        }
    }

    func profileView(for preview: ProfilePreview) -> some View {
        ProfileRowView(
            style: cardStyle,
            profileManager: profileManager,
            tunnel: tunnel,
            preview: preview,
            errorHandler: errorHandler,
            flow: flow
        )
        .contextMenu {
            ProfileContextMenu(
                style: .containerContext,
                profileManager: profileManager,
                tunnel: tunnel,
                preview: preview,
                errorHandler: errorHandler,
                flow: flow
            )
        }
        .id(preview.id)
    }
}

private extension ProfileListView {
    var cardStyle: ProfileCardView.Style {
        if hsClass == .compact || vsClass == .compact {
            return .compact
        } else {
            return .full
        }
    }
}

// MARK: - Previews

#Preview {
    ProfileListView(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        isVerifying: false,
        errorHandler: .default()
    )
    .withMockEnvironment()
}
