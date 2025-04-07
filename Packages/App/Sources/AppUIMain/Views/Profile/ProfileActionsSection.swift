//
//  ProfileActionsSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/10/25.
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
import Partout
import SwiftUI

struct ProfileActionsSection: View {

    @Environment(\.dismissProfile)
    private var dismissProfile

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    @State
    private var isConfirmingDeletion = false

    var body: some View {
#if os(iOS)
        Section {
            UUIDText(uuid: profileId)
        }
        Section {
            removeContent()
                .frame(maxWidth: .infinity, alignment: .center)
        }
#else
        if isExistingProfile {
            Section {
                uuidView
                ThemeTrailingContent(content: removeContent)
            }
        } else {
            uuidView
        }
#endif
    }
}

private extension ProfileActionsSection {
    var isExistingProfile: Bool {
        profileManager.profile(withId: profileId) != nil
    }

    var uuidView: some View {
        UUIDText(uuid: profileId)
    }

    func removeContent() -> some View {
        profileManager.profile(withId: profileId)
            .map { _ in
                removeButton
                    .themeConfirmation(
                        isPresented: $isConfirmingDeletion,
                        title: Strings.Global.Actions.delete,
                        isDestructive: true,
                        action: {
                            Task {
                                dismissProfile()
                                await profileManager.remove(withId: profileId)
                            }
                        }
                    )
            }
    }

    var removeButton: some View {
        Button(Strings.Views.Profile.Rows.deleteProfile, role: .destructive) {
            isConfirmingDeletion = true
        }
    }
}

private extension ProfileActionsSection {
    var profileId: Profile.ID {
        profileEditor.profile.id
    }
}
