//
//  ProfileBehaviorSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/25.
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

import SwiftUI

struct ProfileBehaviorSection: View {

    @ObservedObject
    var profileEditor: ProfileEditor

    var body: some View {
        debugChanges()
        return Group {
            keepAliveToggle
                .themeRowWithSubtitle(footer)
        }
        .themeSection(header: header, footer: footer)
    }
}

private extension ProfileBehaviorSection {
    var keepAliveToggle: some View {
        Toggle(Strings.Modules.General.Rows.keepAliveOnSleep, isOn: .constant(true))
    }
}

private extension ProfileBehaviorSection {
    var header: String {
        Strings.Modules.General.Sections.Behavior.header
    }

    var footer: String {
        Strings.Modules.General.Rows.KeepAliveOnSleep.footer
    }
}

#Preview {
    Form {
        ProfileBehaviorSection(profileEditor: ProfileEditor())
    }
    .themeForm()
    .withMockEnvironment()
}
