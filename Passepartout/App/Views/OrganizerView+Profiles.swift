//
//  OrganizerView+Profiles.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/3/22.
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
import PassepartoutLibrary

extension OrganizerView {
    struct ProfilesList: View {
        @ObservedObject private var profileManager: ProfileManager

        init() {
            profileManager = .shared
        }
        
        var body: some View {
            debugChanges()
            return Group {
                mainView
                if !profileManager.hasProfiles {
                    emptyView
                }
            }.onAppear(perform: performMigrationsIfNeeded)
            .onReceive(profileManager.didCreateProfile) {
                profileManager.currentProfileId = $0.id
            }
        }
        
        private var mainView: some View {
            List {
                if profileManager.hasProfiles {

                    // FIXME: iPad multitasking, navigation binding does not clear on pop
                    // - if listStyle is different than .sidebar
                    // - if listStyle is .sidebar but List has no Section
                    if themeIsiPadMultitasking {
                        Section {
                            profilesView
                        } header: {
                            Text(L10n.Global.Strings.profiles)
                        }
                    } else {
                        profilesView
                    }
                }
            }.themeAnimation(on: profileManager.headers)
        }
        
        private var profilesView: some View {
            ForEach(sortedHeaders, content: profileRow(forHeader:))
                .onDelete(perform: removeProfiles)
        }

        private var emptyView: some View {
            VStack {
                Text(L10n.Organizer.Empty.noProfiles)
                    .themeInformativeTextStyle()
            }
        }

        private func profileRow(forHeader header: Profile.Header) -> some View {
            NavigationLink(tag: header.id, selection: $profileManager.currentProfileId) {
                ProfileView()
            } label: {
                profileLabel(forHeader: header)
            }.contextMenu {
                ProfileContextMenu(header: header)
            }
        }
        
        private func profileLabel(forHeader header: Profile.Header) -> some View {
            ProfileRow(
                header: header,
                isActiveProfile: profileManager.isActiveProfile(header.id)
            )
        }

        private var sortedHeaders: [Profile.Header] {
            profileManager.headers
                .sorted()
//                .sorted {
//                    if profileManager.isActiveProfile($0.id) {
//                        return true
//                    } else if profileManager.isActiveProfile($1.id) {
//                        return false
//                    } else {
//                        return $0 < $1
//                    }
//                }
        }

        private func removeProfiles(at offsets: IndexSet) {
            let currentHeaders = sortedHeaders
            var toDelete: [UUID] = []
            offsets.forEach {
                toDelete.append(currentHeaders[$0].id)
            }
            withAnimation {
                profileManager.removeProfiles(withIds: toDelete)
            }
        }
        
        private func performMigrationsIfNeeded() {
            Task { @MainActor in
                UpgradeManager.shared.doMigrations(profileManager)
            }
        }
    }
}

extension OrganizerView {
    struct ProfileContextMenu: View {
        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var currentVPNState: ObservableVPNState

        let header: Profile.Header
        
        init(header: Profile.Header) {
            profileManager = .shared
            currentVPNState = .shared
            self.header = header
        }
        
        var body: some View {
            if isActiveProfileNotDisconnected {
                reconnectButton
            }
            duplicateButton
            deleteButton
        }
        
        private var isActiveProfileNotDisconnected: Bool {
            profileManager.isActiveProfile(header.id) && currentVPNState.vpnStatus != .disconnected
        }
        
        private var reconnectButton: some View {
            ProfileView.ReconnectButton()
        }

        private var duplicateButton: some View {
            ProfileView.DuplicateButton(
                header: header,
                setAsCurrent: false
            )
        }

        private var deleteButton: some View {
            DestructiveButton {
                withAnimation {
                    profileManager.removeProfiles(withIds: [header.id])
                }
            } label: {
                Label(L10n.Global.Strings.delete, systemImage: themeDeleteImage)
            }
        }
    }
}
