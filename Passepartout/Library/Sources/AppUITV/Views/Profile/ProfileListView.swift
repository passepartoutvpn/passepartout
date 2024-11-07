//
//  ProfileListView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

struct ProfileListView: View {

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var tunnel: ExtendedTunnel

    @FocusState.Binding
    var focusedField: ProfileView.Field?

    @ObservedObject
    var interactiveManager: InteractiveManager

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        List {
            Group {
                ForEach(headers, id: \.id, content: toggleButton(for:))
            }
            .themeSection(header: Strings.Views.Profiles.Folders.default)
        }
        .listStyle(.grouped)
        .scrollClipDisabled()
    }
}

private extension ProfileListView {
    var headers: [ProfileHeader] {
        profileManager.headers
    }

    func toggleButton(for header: ProfileHeader) -> some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profileManager.profile(withId: header.id),
            nextProfileId: .constant(nil),
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            label: { _ in
                toggleView(for: header)
            }
        )
        .focused($focusedField, equals: .profile(header.id))
    }

    func toggleView(for header: ProfileHeader) -> some View {
        HStack {
            Text(header.name)
            Spacer()
            if header.id == tunnel.currentProfile?.id {
                ThemeImage(.marked)
            }
        }
        .font(.headline)
    }
}
