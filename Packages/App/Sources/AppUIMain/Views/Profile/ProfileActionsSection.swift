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
import PassepartoutKit
import SwiftUI

struct ProfileActionsSection: View {
    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    var body: some View {
        UUIDText(uuid: profileId)
            .asSectionWithTrailingContent {
                if profileManager.profile(withId: profileId) != nil {
                    ProfileRemoveButton(
                        profileManager: profileManager,
                        profileId: profileId,
                        profileName: profileEditor.profile.name,
                        label: {
                            Text(Strings.Views.Profile.Rows.deleteProfile)
                        }
                    )
                }
            }
    }

    private var profileId: Profile.ID {
        profileEditor.profile.id
    }
}
