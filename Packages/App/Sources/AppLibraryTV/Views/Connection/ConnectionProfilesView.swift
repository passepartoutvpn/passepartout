//
//  ConnectionProfilesView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

import AppAccessibility
import CommonLibrary
import CommonUtils
import CommonWeb
import SwiftUI

struct ConnectionProfilesView: View {

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var tunnel: ExtendedTunnel

    @FocusState.Binding
    var focusedField: ConnectionView.Field?

    @ObservedObject
    var errorHandler: ErrorHandler

    var flow: ConnectionFlow?

    var body: some View {
        VStack {
            headerView
                .frame(maxWidth: .infinity, alignment: .leading)
            List {
                ForEach(allPreviews, id: \.id, content: toggleButton(for:))
            }
            .themeList()
            .themeProgress(if: false, isEmpty: !profileManager.hasProfiles) {
                Text(Strings.Views.App.Folders.noProfiles)
                    .themeEmptyMessage()
            }
        }
    }
}

private extension ConnectionProfilesView {
    var allPreviews: [ProfilePreview] {
        profileManager.previews
    }

    var headerView: some View {
        Text(Strings.Views.Tv.ConnectionProfiles.header(Strings.Unlocalized.appName, Strings.Unlocalized.appleTV))
            .textCase(.none)
            .foregroundStyle(.primary)
            .font(.body)
    }

    func toggleButton(for preview: ProfilePreview) -> some View {
        TunnelToggle(
            tunnel: tunnel,
            profile: profileManager.profile(withId: preview.id),
            errorHandler: errorHandler,
            flow: flow,
            label: { isOn, _ in
                Button {
                    isOn.wrappedValue.toggle()
                } label: {
                    toggleView(for: preview)
                }
            }
        )
        .focused($focusedField, equals: .profile(preview.id))
        .uiAccessibility(.App.ProfileList.profile)
    }

    func toggleView(for preview: ProfilePreview) -> some View {
        HStack {
            Text(preview.name)
            Spacer()
            tunnel.statusImageName(ofProfileId: preview.id)
                .map {
                    ThemeImage($0)
                        .opaque(tunnel.isActiveProfile(withId: preview.id))
                }
        }
        .font(.headline)
    }
}

// MARK: - Previews

#Preview("List") {
    ContentPreview(profileManager: .forPreviews)
}

#Preview("Empty") {
    ContentPreview(profileManager: ProfileManager(profiles: []))
}

private struct ContentPreview: View {
    let profileManager: ProfileManager

    @FocusState
    var focusedField: ConnectionView.Field?

    var body: some View {
        ConnectionProfilesView(
            profileManager: profileManager,
            tunnel: .forPreviews,
            focusedField: $focusedField,
            errorHandler: .default()
        )
        .withMockEnvironment()
    }
}
