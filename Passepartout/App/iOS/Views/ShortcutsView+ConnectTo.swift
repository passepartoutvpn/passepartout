//
//  ShortcutsView+ConnectTo.swift
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
    struct ConnectToView: View {
        @ObservedObject private var profileManager: ProfileManager
        
        @ObservedObject private var providerManager: ProviderManager
        
        @ObservedObject private var pendingProfile: ObservableProfile
        
        @Binding private var pendingShortcut: INShortcut?
        
        @State private var profileIdMakingReady: UUID?
        
        @State private var presentedHeader: Profile.Header?
        
        private var isLocationPresented: Binding<Bool> {
            .init {
                presentedHeader != nil
            } set: {
                if !$0 {
                    presentedHeader = nil
                    addMoveToPendingProfile()
                }
            }
        }
        
        init(pendingProfile: ObservableProfile, pendingShortcut: Binding<INShortcut?>) {
            profileManager = .shared
            providerManager = .shared
            self.pendingProfile = pendingProfile
            _pendingShortcut = pendingShortcut
        }

        var body: some View {
            debugChanges()
            return ZStack {
                let headers = profileManager.headers
                List {
                    Section {
                        ForEach(headers.sorted(), content: profileRow)
                            .disabled(profileIdMakingReady != nil)
                    }
                }
                ForEach(Array(headers.filter {
                    $0.providerName != nil
                }), content: providerLocationLink)
            }.navigationTitle(L10n.Shortcuts.Add.Items.Connect.caption)
        }
        
        private func profileRow(_ header: Profile.Header) -> some View {
            Button {
                if let _ = header.providerName {
                    Task {
                        profileIdMakingReady = header.id
                        await loadAndSelectProfile(withHeader: header)
                        profileIdMakingReady = nil
                    }
                } else {
                    addConnect(header)
                }
            } label: {
                ProfileHeaderRow(header: header)
            }.withTrailingProgress(when: profileIdMakingReady == header.id)
        }
        
        private func providerLocationLink(_ header: Profile.Header) -> some View {
            NavigationLink("", tag: header, selection: $presentedHeader) {
                ProviderLocationView(
                    currentProfile: pendingProfile,
                    isEditable: false,
                    isPresented: isLocationPresented
                )
            }
        }
        
        private func loadAndSelectProfile(withHeader header: Profile.Header) async {
            do {
                let result = try profileManager.loadProfile(withId: header.id)
                if !result.isReady {
                    try await profileManager.makeProfileReady(result.profile)
                }
                pendingProfile.value = result.profile
                presentedHeader = header
            } catch {
                pp_log.error("Unable to select profile: \(error)")
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
    }
}
