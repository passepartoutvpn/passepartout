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

import CommonLibrary
import SwiftUI

struct StorageSection: View {

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
            tvToggle
                .themeRow(footer: footer)
            purchaseButton
        }
        .themeSection(
            header: header,
            footer: footer
        )
    }
}

private extension StorageSection {
    var sharingToggle: some View {
        Toggle(Strings.Modules.General.Rows.shared, isOn: $profileEditor.isShared)
            .disabled(!iapManager.isEligible(for: .sharing))
    }

    var tvToggle: some View {
        Toggle(Strings.Modules.General.Rows.appleTv(Strings.Unlocalized.appleTV), isOn: $profileEditor.isAvailableForTV)
            .disabled(!iapManager.isEligible(for: .appleTV) || !profileEditor.isShared)
    }

    @ViewBuilder
    var purchaseButton: some View {
        if !iapManager.isEligible(for: .sharing) {
            purchaseSharingButton
        } else if !iapManager.isEligible(for: .appleTV) {
            purchaseTVButton
        }
    }

    var purchaseSharingButton: some View {
        EmptyView()
            .modifier(PurchaseButtonModifier(
                Strings.Modules.General.Rows.Shared.purchase,
                feature: .sharing,
                suggesting: nil,
                showsIfRestricted: false,
                paywallReason: $paywallReason
            ))
    }

    var purchaseTVButton: some View {
        EmptyView()
            .modifier(PurchaseButtonModifier(
                Strings.Modules.General.Rows.AppleTv.purchase,
                feature: .appleTV,
                suggesting: .Features.appleTV,
                showsIfRestricted: false,
                paywallReason: $paywallReason
            ))
    }

    var header: String {
        Strings.Modules.General.Sections.Storage.header(Strings.Unlocalized.iCloud)
    }

    var footer: String {
        var desc = [
            Strings.Modules.General.Sections.Storage.footer(Strings.Unlocalized.iCloud)
        ]
        switch iapManager.paywallReason(forFeature: .appleTV, suggesting: nil) {
        case .purchase:
            desc.append(Strings.Modules.General.Sections.Storage.Footer.Purchase.tvRelease)

        case .restricted:
            desc.append(Strings.Modules.General.Sections.Storage.Footer.Purchase.tvBeta)

        default:
            break
        }
        return desc.joined(separator: " ")
    }
}

#Preview {
    Form {
        StorageSection(
            profileEditor: ProfileEditor(),
            paywallReason: .constant(nil)
       )
    }
    .themeForm()
    .withMockEnvironment()
}
