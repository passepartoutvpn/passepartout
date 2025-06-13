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

    @Environment(\.distributionTarget)
    private var distributionTarget

    @ObservedObject
    var profileEditor: ProfileEditor

    @Binding
    var paywallReason: PaywallReason?

    var flow: ProfileCoordinator.Flow?

    var body: some View {
        if showsSharing {
            sharingSection
        }
        tvSection
    }
}

private extension ProfileStorageSection {
    var sharingSection: some View {
        Group {
            sharingToggle
                .themeContainerEntry(
                    header: sharingHeader,
                    subtitle: sharingDescription
                )

            tvToggle
                .themeContainerEntry(
                    subtitle: sharingTVDescription
                )
                .disabled(!profileEditor.isShared)
        }
        .themeContainer(header: sharingHeader)
    }

    var sharingToggle: some View {
        Toggle(isOn: $profileEditor.isShared) {
            ThemeImageLabel(.cloudOn, inForm: true) {
                HStack {
                    Text(Strings.Unlocalized.iCloud)
                    PurchaseRequiredView(
                        requiring: sharingRequirements,
                        reason: $paywallReason
                    )
                }
            }
        }
    }
}

private extension ProfileStorageSection {
    var tvSection: some View {
        Button(Strings.Views.Profile.SendTv.title_compound) {
            flow?.onSendToTV()
        }
        .themeContainerWithSingleEntry(
            header: !showsSharing ? Strings.Unlocalized.appleTV : nil,
            footer: tvDescription,
            isAction: true
        )
    }

    var tvToggle: some View {
        Toggle(isOn: $profileEditor.isAvailableForTV) {
            ThemeImageLabel(.tvOn, inForm: true) {
                HStack {
                    Text(Strings.Modules.General.Rows.appletv_compound)
                    PurchaseRequiredView(
                        requiring: tvRequirements,
                        reason: $paywallReason
                    )
                }
            }
        }
    }
}

private extension ProfileStorageSection {
    var showsSharing: Bool {
        distributionTarget.supportsCloudKit
    }

    var sharingRequirements: Set<AppFeature> {
        profileEditor.isShared ? [.sharing] : []
    }

    var sharingHeader: String {
        Strings.Modules.General.Sections.Storage.header
    }

    var sharingDescription: String {
        Strings.Modules.General.Sections.Storage.Sharing.footer(Strings.Unlocalized.iCloud)
    }

    var sharingTVDescription: String {
        Strings.Modules.General.Sections.Storage.Tv.Icloud.footer
    }

    var tvRequirements: Set<AppFeature> {
        profileEditor.isShared && profileEditor.isAvailableForTV ? [.appleTV, .sharing] : []
    }

    var tvDescription: String {
        var desc = [Strings.Modules.General.Sections.Storage.Tv.Web.footer]
        if distributionTarget.supportsPaidFeatures && !iapManager.isBeta {
            desc.append(Strings.Views.Paywall.Alerts.Confirmation.Message.connect(iapManager.verificationDelayMinutes))
            desc.append(Strings.Modules.General.Sections.Storage.Tv.Footer.purchase)
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
