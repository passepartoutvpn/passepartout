// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

struct ProfileStorageSection: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    var profileEditor: ProfileEditor

    @Binding
    var paywallReason: PaywallReason?

    var flow: ProfileCoordinator.Flow?

    var body: some View {
        debugChanges()
        return Group {
            sharingToggle
                .themeContainerEntry(
                    header: header,
                    subtitle: sharingDescription
                )
            tvToggle
                .themeContainerEntry(subtitle: tvDescription)
                .disabled(!profileEditor.isShared)
        }
        .themeContainer(header: header)
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
            reason: $paywallReason,
            suggesting: { // FIXME: #1446, delete suggesting after deleting old paywall
                var products = iapManager.suggestedProducts()
                products.insert(.Features.appleTV)
                return products
            }()
        )
    }

    var tvToggle: some View {
        Toggle(isOn: $profileEditor.isAvailableForTV) {
            ThemeImageLabel(.tvOn, inForm: true) {
                HStack {
                    Text(Strings.Modules.General.Rows.appletv(Strings.Unlocalized.appleTV))
                    tvPurchaseButton
                }
            }
        }
    }

    var tvPurchaseButton: some View {
        PurchaseRequiredView(
            requiring: tvRequirements,
            reason: $paywallReason,
            suggesting: { // FIXME: #1446, delete suggesting after deleting old paywall
                var products = iapManager.suggestedProducts(filter: .onlyComplete)
                products.insert(.Features.appleTV)
                return products
            }()
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
        profileEditor.isShared && profileEditor.isAvailableForTV ? [.appleTV, .sharing] : []
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
