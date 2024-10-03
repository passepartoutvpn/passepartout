//
//  StorageSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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

import Foundation
import SwiftUI

struct StorageSection: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    var profileEditor: ProfileEditor

    @State
    private var paywallReason: PaywallReason?

    var body: some View {
        debugChanges()
        return Group {
            sharingToggle
#if DEBUG
            ThemeCopiableText(
                title: Strings.Unlocalized.uuid,
                value: profileEditor.id.uuidString
            )
#endif
        }
        .themeSection(
            header: Strings.Global.storage,
            footer: Strings.Modules.General.Sections.Storage.footer
        )
        .modifier(PaywallModifier(reason: $paywallReason))
    }
}

private extension StorageSection {

    @ViewBuilder
    var sharingToggle: some View {
        switch iapManager.paywallReason(forFeature: .sharing) {
        case .purchase(let appFeature):
            Button(Strings.Modules.General.Storage.Shared.purchase) {
                paywallReason = .purchase(appFeature)
            }

        case .restricted:
            EmptyView()

        default:
            Toggle(Strings.Modules.General.Storage.shared, isOn: $profileEditor.isShared)
        }
    }
}

#Preview {
    Form {
        StorageSection(
            profileEditor: ProfileEditor()
        )
    }
    .themeForm()
    .withMockEnvironment()
}
