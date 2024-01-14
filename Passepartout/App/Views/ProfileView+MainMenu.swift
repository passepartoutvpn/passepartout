//
//  ProfileView+MainMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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

import PassepartoutLibrary
import SwiftUI

extension ProfileView {
    struct MainMenu: View {
        enum AlertType: Int, Identifiable {
            case uninstallVPN

            case deleteProfile

            var id: Int {
                rawValue
            }
        }

        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var vpnManager: VPNManager

        @ObservedObject private var currentVPNState: ObservableVPNState

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var modalType: ModalType?

        @State private var isAlertPresented = false

        @State private var alertType: AlertType?

        private let uninstallVPNTitle = L10n.Global.Strings.uninstall

        private let deleteProfileTitle = L10n.Global.Strings.delete

        init(currentProfile: ObservableProfile, modalType: Binding<ModalType?>) {
            profileManager = .shared
            vpnManager = .shared
            currentVPNState = .shared
            self.currentProfile = currentProfile
            _modalType = modalType
        }

        var body: some View {
            mainView
                .alert(
                    Text(Unlocalized.appName),
                    isPresented: $isAlertPresented,
                    presenting: alertType,
                    actions: alertActions,
                    message: alertMessage
                )
        }
    }
}

extension ProfileView {
    struct ReconnectButton: View {
        @ObservedObject private var vpnManager: VPNManager

        init() {
            vpnManager = .shared
        }

        var body: some View {
            Button {
                Task { @MainActor in
                    await vpnManager.reconnect()
                }
            } label: {
                Label(L10n.Global.Strings.reconnect, systemImage: themeReconnectImage)
            }
        }
    }

    #if !os(tvOS)
    struct ShortcutsButton: View {
        @ObservedObject private var productManager: ProductManager

        @Binding private var modalType: ModalType?

        init(modalType: Binding<ModalType?>) {
            productManager = .shared
            _modalType = modalType
        }

        var body: some View {
            Button {
                presentShortcutsOrPaywall()
            } label: {
                Label(Unlocalized.Other.siri, systemImage: themeShortcutsImage)
            }
        }
    }
    #endif

    struct RenameButton: View {
        @Binding private var modalType: ModalType?

        init(modalType: Binding<ModalType?>) {
            _modalType = modalType
        }

        var body: some View {
            Button {
                modalType = .rename
            } label: {
                Label(L10n.Global.Strings.rename, systemImage: themeRenameProfileImage)
            }
        }
    }

    struct DuplicateButton: View {
        @ObservedObject private var profileManager: ProfileManager

        private let header: Profile.Header

        private let setAsCurrent: Bool

        init(header: Profile.Header, setAsCurrent: Bool) {
            profileManager = .shared
            self.header = header
            self.setAsCurrent = setAsCurrent
        }

        var body: some View {
            Button {
                duplicateProfile(withId: header.id)
            } label: {
                Label(L10n.Global.Strings.duplicate, systemImage: themeDuplicateImage)
            }
        }
    }
}

// MARK: -

private extension ProfileView.MainMenu {
    var header: Profile.Header {
        currentProfile.value.header
    }

    var mainView: some View {
        Menu {
            ProfileView.ReconnectButton()
            #if !os(tvOS)
            ProfileView.ShortcutsButton(
                modalType: $modalType
            )
            #endif
            Divider()
            ProfileView.RenameButton(
                modalType: $modalType
            )
            ProfileView.DuplicateButton(
                header: header,
                setAsCurrent: true
            )
            uninstallVPNButton
            Divider()
            deleteProfileButton
        } label: {
            themeSettingsMenuImage.asSystemImage
        }
    }

    func alertActions(_ alertType: AlertType) -> some View {
        switch alertType {
        case .uninstallVPN:
            return Group {
                Button(role: .destructive, action: uninstallVPN) {
                    Text(uninstallVPNTitle)
                }
                Button(role: .cancel) {
                } label: {
                    Text(L10n.Global.Strings.cancel)
                }
            }

        case .deleteProfile:
            return Group {
                Button(role: .destructive, action: removeProfile) {
                    Text(deleteProfileTitle)
                }
                Button(role: .cancel) {
                } label: {
                    Text(L10n.Global.Strings.cancel)
                }
            }
        }
    }

    func alertMessage(_ alertType: AlertType) -> some View {
        switch alertType {
        case .uninstallVPN:
            return Text(L10n.Profile.Alerts.UninstallVpn.message)

        case .deleteProfile:
            return Text(L10n.Organizer.Alerts.RemoveProfile.message(header.name))
        }
    }

    var uninstallVPNButton: some View {
        Button {
            alertType = .uninstallVPN
            isAlertPresented = true
        } label: {
            Label(uninstallVPNTitle, systemImage: themeUninstallImage)
        }
    }

    var deleteProfileButton: some View {
        Button(role: .destructive) {
            alertType = .deleteProfile
            isAlertPresented = true
        } label: {
            Label(deleteProfileTitle, systemImage: themeDeleteImage)
        }
    }
}

#if !os(tvOS)
private extension ProfileView.ShortcutsButton {
    var isEligibleForSiri: Bool {
        productManager.isEligible(forFeature: .siriShortcuts)
    }
}
#endif

// MARK: -

private extension ProfileView.MainMenu {
    func uninstallVPN() {
        Task { @MainActor in
            await vpnManager.uninstall()
        }
    }

    func removeProfile() {
        withAnimation {
            profileManager.removeProfiles(withIds: [header.id])
        }
    }
}

#if !os(tvOS)
private extension ProfileView.ShortcutsButton {
    func presentShortcutsOrPaywall() {

        // eligibility: enter Siri shortcuts or present paywall
        if isEligibleForSiri {
            modalType = .shortcuts
        } else {
            modalType = .paywallShortcuts
        }
    }
}
#endif

private extension ProfileView.DuplicateButton {
    func duplicateProfile(withId id: UUID) {
        profileManager.duplicateProfile(withId: id, setAsCurrent: setAsCurrent)
    }
}
