//
//  ShortcutsView+Add.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

extension ShortcutsView {
    struct AddView: View {
        @ObservedObject private var profileManager: ProfileManager
        
        @StateObject private var pendingProfile = ObservableProfile()
        
        @Binding private var pendingShortcut: INShortcut?
        
        init(pendingShortcut: Binding<INShortcut?>) {
            profileManager = .shared
            _pendingShortcut = pendingShortcut
        }
        
        var body: some View {
            List {
                Section(
                    header: Text(Unlocalized.VPN.vpn)
                ) {
                    NavigationLink(L10n.Shortcuts.Add.Items.Connect.caption) {
                        ConnectToView(
                            pendingProfile: pendingProfile,
                            pendingShortcut: $pendingShortcut
                        )
                    }.disabled(profileManager.headers.isEmpty)

                    Button(L10n.Shortcuts.Add.Items.EnableVpn.caption, action: addEnableVPN)
                    Button(L10n.Shortcuts.Add.Items.DisableVpn.caption, action: addDisableVPN)
                }
                Section(
                    header: Text(L10n.Shortcuts.Add.Sections.Wifi.header)
                ) {
                    Button(L10n.Shortcuts.Add.Items.TrustCurrentWifi.caption, action: addTrustWiFi)
                    Button(L10n.Shortcuts.Add.Items.UntrustCurrentWifi.caption, action: addUntrustWiFi)
                }
                Section(
                    header: Text(L10n.Shortcuts.Add.Sections.Cellular.header)
                ) {
                    Button(L10n.Shortcuts.Add.Items.TrustCellular.caption, action: addTrustCellular)
                    Button(L10n.Shortcuts.Add.Items.UntrustCellular.caption, action: addUntrustCellular)
                }
            }.navigationTitle(L10n.Shortcuts.Add.title)
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
}
