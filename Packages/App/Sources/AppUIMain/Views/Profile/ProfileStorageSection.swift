//
//  ProfileStorageSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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
import SwiftUI

struct ProfileStorageSection: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    var profileEditor: ProfileEditor

    @Binding
    var paywallReason: PaywallReason?

    var body: some View {
        debugChanges()
        return Group {
            sharingToggle
                .themeSectionWithSingleRow(
                    header: header,
                    footer: sharingDescription
                )

            Group {
                tvToggle
                    .themeRowWithSubtitle(tvDescription)

                tvPurchaseButton
            }
            .themeSection(footer: tvDescription)
            .disabled(!profileEditor.isShared)
        }
    }
}

private extension ProfileStorageSection {
    var sharingToggle: some View {
        Toggle(isOn: $profileEditor.isShared) {
            ThemeImageLabel(.cloudOn, inForm: true) {
                HStack {
                    Text(Strings.Unlocalized.iCloud)
                    sharingPurchaseButton
                }
            }
        }
    }

    var sharingPurchaseButton: some View {
        PurchaseRequiredView(
            requiring: sharingRequirements,
            reason: $paywallReason
        )
    }

    var tvToggle: some View {
        Toggle(isOn: $profileEditor.isAvailableForTV) {
            ThemeImageLabel(.tvOn, inForm: true) {
                Text(Strings.Modules.General.Rows.appletv(Strings.Unlocalized.appleTV))
            }
        }
    }

    var tvPurchaseButton: some View {
        PurchaseRequiredView(
            requiring: tvRequirements,
            reason: $paywallReason,
            title: Strings.Global.Actions.purchase,
            suggesting: .Features.appleTV
        )
    }
}

private extension ProfileStorageSection {
    var header: String {
        Strings.Modules.General.Sections.Storage.header
    }

    var sharingRequirements: Set<AppFeature> {
        profileEditor.isShared ? [.sharing] : []
    }

    var tvRequirements: Set<AppFeature> {
        profileEditor.isAvailableForTV ? [.appleTV] : []
    }

    var sharingDescription: String {
        Strings.Modules.General.Sections.Storage.Sharing.footer(Strings.Unlocalized.iCloud)
    }

    var tvDescription: String? {
        var desc: [String] = [Strings.Modules.General.Sections.Storage.Tv.footer]
        if !iapManager.isEligible(for: .appleTV) {
            desc.append(Strings.Views.Paywall.Alerts.Confirmation.Message.connect(iapManager.verificationDelayMinutes))
            if !iapManager.isBeta {
                desc.append(Strings.Modules.General.Sections.Storage.Tv.Footer.purchase)
            }
        }
        return desc.joined(separator: " ")
    }
}

#Preview {
    Form {
        ProfileStorageSection(
            profileEditor: ProfileEditor(),
            paywallReason: .constant(nil)
        )
    }
    .themeForm()
    .withMockEnvironment()
}
