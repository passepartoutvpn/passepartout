//
//  AppleTVSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/4/24.
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

struct AppleTVSection: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    var profileEditor: ProfileEditor

    @Binding
    var paywallReason: PaywallReason?

    var body: some View {
        debugChanges()
        return Group {
            availableToggle
            purchaseButton
        }
        .themeSection(footer: footer)
        .disabled(!profileEditor.isShared)
    }
}

private extension AppleTVSection {
    var availableToggle: some View {
        Toggle(Strings.Modules.General.Rows.appleTv(Strings.Unlocalized.appleTV), isOn: $profileEditor.isAvailableForTV)
    }

    var purchaseButton: some View {
        EmptyView()
            .modifier(PurchaseButtonModifier(
                Strings.Modules.General.Rows.AppleTv.purchase,
                feature: .appleTV,
                showsIfRestricted: true,
                paywallReason: $paywallReason
            ))
    }

    var footer: String {
        var desc = [Strings.Modules.General.Sections.AppleTv.footer]
        let expirationDesc = {
            Strings.Modules.General.Sections.AppleTv.Footer.Purchase._1( Constants.shared.tunnel.tvExpirationMinutes)
        }
        let purchaseDesc = {
            Strings.Modules.General.Sections.AppleTv.Footer.Purchase._2
        }
        switch iapManager.paywallReason(forFeature: .appleTV) {
        case .purchase:
            desc.append(expirationDesc())
            desc.append(purchaseDesc())

        case .restricted:
            desc.append(expirationDesc())

        default:
            break
        }
        return desc.joined(separator: " ")
    }
}

#Preview {
    Form {
        AppleTVSection(
            profileEditor: ProfileEditor(),
            paywallReason: .constant(nil)
        )
    }
    .themeForm()
    .withMockEnvironment()
}
