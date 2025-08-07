// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import SwiftUI

struct ProfileBehaviorSection: View {

    @ObservedObject
    var profileEditor: ProfileEditor

    var body: some View {
        keepAliveToggle
            .themeContainerWithSingleEntry(
                header: Strings.Modules.General.Sections.Behavior.header,
                footer: Strings.Modules.General.Rows.KeepAliveOnSleep.footer
            )
    }
}

private extension ProfileBehaviorSection {
    var keepAliveToggle: some View {
        Toggle(Strings.Modules.General.Rows.keepAliveOnSleep, isOn: $profileEditor.keepsAliveOnSleep)
    }
}

#Preview {
    Form {
        ProfileBehaviorSection(profileEditor: ProfileEditor())
    }
    .themeForm()
    .withMockEnvironment()
}
