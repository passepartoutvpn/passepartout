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
                .themeRow(footer: sharingDescription)
            tvToggle
                .themeRow(footer: tvDescription)
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
        Toggle(Strings.Modules.General.Rows.appletv(Strings.Unlocalized.appleTV), isOn: $profileEditor.isAvailableForTV)
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
        PurchaseRequiredButton(
            Strings.Modules.General.Rows.Shared.purchase,
            features: [.sharing],
            paywallReason: $paywallReason
        )
    }

    var purchaseTVButton: some View {
        PurchaseRequiredButton(
            Strings.Modules.General.Rows.Appletv.purchase,
            features: [.appleTV],
            suggestedProduct: .Features.appleTV,
            paywallReason: $paywallReason
        )
    }

    var header: String {
        Strings.Modules.General.Sections.Storage.header(Strings.Unlocalized.iCloud)
    }

    var footer: String {
        var desc = [
            Strings.Modules.General.Sections.Storage.footer(Strings.Unlocalized.iCloud)
        ]
        if let tvDescription {
            desc.append(tvDescription)
        }
        return desc.joined(separator: " ")
    }

    var sharingDescription: String {
        Strings.Modules.General.Sections.Storage.footer(Strings.Unlocalized.iCloud)
    }

    var tvDescription: String? {
        if iapManager.isEligible(for: .appleTV) {
            return nil
        }
        if !iapManager.isRestricted {
            return Strings.Modules.General.Sections.Storage.Footer.Purchase.tvRelease
        } else {
            return Strings.Modules.General.Sections.Storage.Footer.Purchase.tvBeta
        }
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
