//
//  ShortcutsView+Add.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import Intents
import PassepartoutLibrary

extension ShortcutsView {
    struct AddView: View {
        @ObservedObject private var providerManager: ProviderManager

        @StateObject private var pendingProfile = ObservableProfile()

        private let target: Profile

        @Binding private var pendingShortcut: INShortcut?

        @State private var isPresentingProviderLocation = false

        init(target: Profile, pendingShortcut: Binding<INShortcut?>) {
            providerManager = .shared
            self.target = target
            _pendingShortcut = pendingShortcut
        }

        var body: some View {
            ZStack {
                hiddenProviderLocationLink
                List {
                    Section {
                        addConnectView
                        Button(L10n.Shortcuts.Add.Items.EnableVpn.caption, action: addEnableVPN)
                        Button(L10n.Shortcuts.Add.Items.DisableVpn.caption, action: addDisableVPN)
                    } header: {
                        Text(Unlocalized.VPN.vpn)
                    }
                    Section {
                        Button(L10n.Shortcuts.Add.Items.TrustCurrentWifi.caption, action: addTrustWiFi)
                        Button(L10n.Shortcuts.Add.Items.UntrustCurrentWifi.caption, action: addUntrustWiFi)
                    } header: {
                        Text(L10n.Shortcuts.Add.Sections.Wifi.header)
                    }
                    Section {
                        Button(L10n.Shortcuts.Add.Items.TrustCellular.caption, action: addTrustCellular)
                        Button(L10n.Shortcuts.Add.Items.UntrustCellular.caption, action: addUntrustCellular)
                    } header: {
                        Text(L10n.Shortcuts.Add.Sections.Cellular.header)
                    }
                }
            }.navigationTitle(L10n.Shortcuts.Add.title)
        }

        private var addConnectView: some View {
            Button(L10n.Shortcuts.Add.Items.Connect.caption) {
                if target.isProvider {
                    pendingProfile.value = target
                    isPresentingProviderLocation = true
                } else {
                    addConnect(target.header)
                }
            }
        }

        private var hiddenProviderLocationLink: some View {
            NavigationLink("", isActive: $isPresentingProviderLocation) {
                ProviderLocationView(
                    currentProfile: pendingProfile,
                    isEditable: false,
                    isPresented: isProviderLocationPresented
                )
            }
        }
    }
}

extension ShortcutsView.AddView {
    private var isProviderLocationPresented: Binding<Bool> {
        .init {
            isPresentingProviderLocation
        } set: {
            if !$0 {
                isPresentingProviderLocation = false
                addMoveToPendingProfile()
            }
        }
    }

    private func addConnect(_ header: Profile.Header) {
        pendingShortcut = INShortcut(intent: IntentDispatcher.intentConnect(
            header: header
        ))
    }

    private func addMoveToPendingProfile() {
        let header = pendingProfile.value.header
        guard let server = pendingProfile.value.providerServer(providerManager) else {
            return
        }
        pendingShortcut = INShortcut(intent: IntentDispatcher.intentMoveTo(
            header: header,
            providerFullName: server.providerMetadata.fullName,
            server: server
        ))
    }

    private func addEnableVPN() {
        addShortcut(with: IntentDispatcher.intentEnable())
    }

    private func addDisableVPN() {
        addShortcut(with: IntentDispatcher.intentDisable())
    }

    private func addTrustWiFi() {
        addShortcut(with: IntentDispatcher.intentTrustWiFi())
    }

    private func addUntrustWiFi() {
        addShortcut(with: IntentDispatcher.intentUntrustWiFi())
    }

    private func addTrustCellular() {
        addShortcut(with: IntentDispatcher.intentTrustCellular())
    }

    private func addUntrustCellular() {
        addShortcut(with: IntentDispatcher.intentUntrustCellular())
    }

    private func addShortcut(with intent: INIntent) {
        guard let shortcut = INShortcut(intent: intent) else {
            fatalError("Unable to create INShortcut, intent '\(intent.description)' not exposed by app?")
        }
        pendingShortcut = shortcut
    }
}
