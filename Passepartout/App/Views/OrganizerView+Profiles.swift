//
//  OrganizerView+Profiles.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/22.
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
import PassepartoutCore

extension OrganizerView {
    struct ProfilesList: View {
        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var providerManager: ProviderManager

        // just to observe changes in profiles eligibility
        @ObservedObject private var productManager: ProductManager
        
        @Binding private var alertType: AlertType?

        @State private var isFirstLaunch = true

        @State private var presentedProfileId: UUID?
        
        private var presentedAndLoadedProfileId: Binding<UUID?> {
            .init {
                presentedProfileId
            } set: {
                guard let id = $0 else {
                    presentedProfileId = nil
                    return
                }
                presentedProfileId = id

                // load profile contextually with navigation
                do {
                    try profileManager.loadCurrentProfile(withId: id)
                } catch {
                    pp_log.error("Unable to load profile: \(error)")
                }
            }
        }
        
        init(alertType: Binding<AlertType?>) {
            profileManager = .shared
            providerManager = .shared
            productManager = .shared
            _alertType = alertType
        }

        var body: some View {
            debugChanges()
            return Group {
                mainView
                if profileManager.headers.isEmpty {
                    emptyView
                }
            }.onAppear {
                performMigrationsIfNeeded()
            }.onChange(of: profileManager.headers) {
                dismissSelectionIfDeleted(headers: $0)
            }

            // from AddProfileView
            .onReceive(profileManager.didCreateProfile) {
                presentedAndLoadedProfileId.wrappedValue = $0.id
            }
        }
        
        private var mainView: some View {
            List {
                ForEach(sortedHeaders, content: profileRow(forHeader:))
                    .onDelete(perform: removeProfiles)
            }.themeAnimation(on: profileManager.headers)
        }

        private var emptyView: some View {
            VStack {
                Text(L10n.Organizer.Empty.noProfiles)
                    .themeInformativeTextStyle()
            }
        }
        
        private func profileRow(forHeader header: Profile.Header) -> some View {
            NavigationLink(tag: header.id, selection: presentedAndLoadedProfileId) {
                ProfileView()
            } label: {
                profileLabel(forHeader: header)
            }.contextMenu {
                profileMenu(forHeader: header)
            }.onAppear {
                presentIfActiveProfile(header.id)
            }
        }
        
        private func profileLabel(forHeader header: Profile.Header) -> some View {
            ProfileRow(
                header: header,
                isActive: profileManager.isActiveProfile(header.id)
            )
        }

        @ViewBuilder
        private func profileMenu(forHeader header: Profile.Header) -> some View {
            ProfileView.DuplicateButton(
                header: header,
                switchCurrentProfile: false
            )
        }

        private var sortedHeaders: [Profile.Header] {
            profileManager.headers
                .sorted()
            
            // FIXME: layout, moving active profile on top breaks row animation (content flashes on Mac)
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
    }
}

extension OrganizerView.ProfilesList {
    private func presentIfActiveProfile(_ id: UUID) {
        guard id == profileManager.activeHeader?.id else {
            return
        }
        presentActiveProfile()
    }
    
    private func presentActiveProfile() {
        guard isFirstLaunch else {
            return
        }
        isFirstLaunch = false

        // presenting profile when an alert is active seems to break navigation
        guard alertType == nil else {
            return
        }
        guard let activeProfileId = profileManager.activeHeader?.id else {
            return
        }

        // FIXME: layout, preselecting profile on iPad portrait/compact adds ProfileView() twice
        // can notice becase "Back" needs to be tapped twice to show sidebar
        if themeIdiom != .pad {
            presentedProfileId = activeProfileId
        }
    }
    
    private func removeProfiles(at offsets: IndexSet) {
        let currentHeaders = sortedHeaders
        var toDelete: [UUID] = []
        offsets.forEach {
            toDelete.append(currentHeaders[$0].id)
        }
        removeProfiles(withIds: toDelete)
    }

    private func removeProfiles(withIds toDelete: [UUID]) {

        // clear selection before removal to avoid triggering a bogus navigation push
        if toDelete.contains(profileManager.currentProfile.value.id) {
            presentedProfileId = nil
        }

        profileManager.removeProfiles(withIds: toDelete)
    }
    
    private func performMigrationsIfNeeded() {
        Task {
            await AppManager.shared.doMigrations(profileManager)
        }
    }
    
    private func dismissSelectionIfDeleted(headers: [Profile.Header]) {
        if let _ = presentedProfileId, !profileManager.isCurrentProfileExisting() {
            presentedProfileId = nil
        }
    }
}
