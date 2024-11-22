//
//  ProfileListView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    var flow: ProfileFlow?

    @State
    private var nextProfileId: Profile.ID?

    var body: some View {
        debugChanges()
        return ScrollViewReader { scrollProxy in
            Form {
                if !isSearching {
                    headerView(scrollProxy: scrollProxy)
                        .unanimated()
                }
                Group {
                    ForEach(allPreviews, content: profileView)
                        .onDelete { offsets in
                            Task {
                                await profileManager.removeProfiles(at: offsets)
                            }
                        }
                }
                .themeSection(header: Strings.Views.Profiles.Folders.default)
            }
            .themeForm()
        }
    }
}

private extension ProfileListView {
    var allPreviews: [ProfilePreview] {
        profileManager.previews
    }

    func headerView(scrollProxy: ScrollViewProxy) -> some View {
        InstalledProfileView(
            layout: .list,
            profileManager: profileManager,
            profile: currentProfile,
            tunnel: tunnel,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            nextProfileId: $nextProfileId,
            flow: flow
        )
        .contextMenu {
            currentProfile.map {
                ProfileContextMenu(
                    profileManager: profileManager,
                    tunnel: tunnel,
                    preview: .init($0),
                    interactiveManager: interactiveManager,
                    errorHandler: errorHandler,
                    isInstalledProfile: true,
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
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            nextProfileId: $nextProfileId,
            withMarker: true,
            flow: flow
        )
        .contextMenu {
            ProfileContextMenu(
                profileManager: profileManager,
                tunnel: tunnel,
                preview: preview,
                interactiveManager: interactiveManager,
                errorHandler: errorHandler,
                isInstalledProfile: false,
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
        profileManager: .mock,
        tunnel: .mock,
        interactiveManager: InteractiveManager(),
        errorHandler: .default()
    )
    .withMockEnvironment()
}
