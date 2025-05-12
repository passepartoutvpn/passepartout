//
//  ProfileGridView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/13/24.
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
import UILibrary

struct ProfileGridView: View, Routable, TunnelInstallationProviding {

    @Environment(\.isUITesting)
    private var isUITesting

    @Environment(\.isSearching)
    private var isSearching

    @AppStorage(UIPreference.pinsActiveProfile.key)
    private var pinsActiveProfile = true

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var tunnel: ExtendedTunnel

    let errorHandler: ErrorHandler

    var flow: ProfileFlow?

    @State
    private var activeProfiles: [Profile.ID: TunnelActiveProfile] = [:]

    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 300.0))]

    var body: some View {
        debugChanges()
        return ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: .zero) {
#if os(iOS)
                    if !isUITesting && !isSearching && pinsActiveProfile {
                        headerView(scrollProxy: scrollProxy)
                            .padding(.bottom)
                            .unanimated()
                    }
#endif
                    LazyVGrid(columns: columns) {
                        ForEach(allPreviews, content: profileView)
                            .onDelete { offsets in
                                Task {
                                    await profileManager.removeProfiles(at: offsets)
                                }
                            }
                    }
                    .themeGridHeader {
                        ProfilesHeaderView()
                    }
                }
                .padding(.horizontal)
#if os(macOS)
                .padding(.top)
#endif
            }
            .themeAnimation(on: profileManager.isReady, category: .profiles)
            .themeAnimation(on: profileManager.previews, category: .profiles)
        }
        .task {
            for await newActiveProfiles in tunnel.activeProfilesStream {
                activeProfiles = newActiveProfiles
            }
        }
    }
}

// MARK: - Subviews

private extension ProfileGridView {
    var allPreviews: [ProfilePreview] {
        profileManager.previews
    }

#if os(iOS)
    func headerView(scrollProxy: ScrollViewProxy) -> some View {
        InstalledProfileView(
            layout: .grid,
            profileManager: profileManager,
            profile: installedProfile,
            tunnel: tunnel,
            errorHandler: errorHandler,
            flow: flow
        )
        .contextMenu {
            installedProfile.map {
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
#endif

    func profileView(for preview: ProfilePreview) -> some View {
        ProfileRowView(
            style: .compact,
            profileManager: profileManager,
            tunnel: tunnel,
            preview: preview,
            errorHandler: errorHandler,
            flow: flow
        )
        .themeGridCell()
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

// MARK: - Previews

#Preview {
    ProfileGridView(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        errorHandler: .default()
    )
    .themeWindow(width: 600, height: 300)
    .withMockEnvironment()
}
