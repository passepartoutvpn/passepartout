//
//  ProfileContextMenu.swift
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

import AppLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct ProfileContextMenu: View, Routable {
    let profileManager: ProfileManager

    let tunnel: Tunnel

    let header: ProfileHeader

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    let isInstalledProfile: Bool

    var flow: ProfileFlow?

    var body: some View {
        tunnelToggleButton
        if isInstalledProfile {
            tunnelRestartButton
        }
        Divider()
        profileEditButton
        profileDuplicateButton
        Divider()
        profileRemoveButton
    }
}

@MainActor
private extension ProfileContextMenu {
    var tunnelToggleButton: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profileManager.profile(withId: header.id),
            nextProfileId: .constant(nil),
            interactiveManager: interactiveManager,
            errorHandler: errorHandler
        ) {
            ThemeImageLabel(
                $0 ? Strings.Global.enable : Strings.Global.disable,
                $0 ? .tunnelEnable : .tunnelDisable
            )
        }
    }

    var tunnelRestartButton: some View {
        TunnelRestartButton(
            tunnel: tunnel,
            profile: profileManager.profile(withId: header.id),
            errorHandler: errorHandler
        ) {
            ThemeImageLabel(Strings.Global.restart, .tunnelRestart)
        }
    }

    var profileEditButton: some View {
        Button {
            flow?.onEdit(header)
        } label: {
            ThemeImageLabel(Strings.Global.edit, .profileEdit)
        }
    }

    var profileDuplicateButton: some View {
        ProfileDuplicateButton(
            profileManager: profileManager,
            header: header,
            errorHandler: errorHandler
        ) {
            ThemeImageLabel(Strings.Global.duplicate, .contextDuplicate)
        }
    }

    var profileRemoveButton: some View {
        ProfileRemoveButton(
            profileManager: profileManager,
            header: header
        ) {
            ThemeImageLabel(Strings.Global.remove, .contextRemove)
        }
    }
}

#Preview {
    List {
        Menu("Menu") {
            ProfileContextMenu(
                profileManager: .mock,
                tunnel: .mock,
                header: Profile.mock.header(),
                interactiveManager: InteractiveManager(),
                errorHandler: .default(),
                isInstalledProfile: true
            )
        }
    }
    .withMockEnvironment()
}
