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
        @ObservedObject private var appManager: AppManager

        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var providerManager: ProviderManager

        // just to observe changes in profiles eligibility
        @ObservedObject private var productManager: ProductManager
        
        @Binding private var alertType: AlertType?

        @State private var isFirstLaunch = true
        
        @State private var isPresentingProfile = false
        
        init(alertType: Binding<AlertType?>) {
            appManager = .shared
            profileManager = .shared
            providerManager = .shared
            productManager = .shared
            _alertType = alertType
        }

        var body: some View {
            debugChanges()
            return ZStack {
                hiddenProfileLink
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
                presentProfile(withId: $0.id)
            }
        }
        
        private var mainView: some View {
            List {
                activeHeaders.map { headers in
                    Section(
                        header: Text(L10n.Organizer.Sections.active)
                    ) {
                        ForEach(headers, content: profileButton(forHeader:))
                            .onDelete(perform: removeActiveProfile)
                    }
                }
                let headers = otherHeaders
                if !headers.isEmpty {
                    Section(
                        header: Text(L10n.Global.Strings.profiles)
                    ) {
                        ForEach(headers, content: profileButton(forHeader:))
                            .onDelete(perform: removeOtherProfiles)
                    }
                }
            }.themeAnimation(on: profileManager.headers)
        }

        private var emptyView: some View {
            VStack {
                Text(L10n.Organizer.Empty.noProfiles)
                    .themeInformativeTextStyle()
            }
        }
        
        private func profileButton(forHeader header: Profile.Header) -> some View {
            Button {
                presentProfile(withId: header.id)
            } label: {
                ProfileHeaderRow(
                    header: header,
                    isActive: profileManager.isActiveProfile(header.id)
                )
            }.contextMenu {
                ProfileView.DuplicateButton(
                    header: header,
                    switchCurrentProfile: false
                )
            }.themeTextButtonStyle()
        }
        
        private var hiddenProfileLink: some View {
            NavigationLink("", isActive: $isPresentingProfile) {
                ProfileView()
            }.onAppear(perform: presentActiveProfile)
        }
    }
}

extension OrganizerView.ProfilesList {
    private var activeHeaders: [Profile.Header]? {
        guard let activeHeader = profileManager.activeHeader else {
            return nil
        }
        return [activeHeader]
    }
    
    private var otherHeaders: [Profile.Header] {
        profileManager.headers
            .filter {
                !profileManager.isActiveProfile($0.id)
            }.sorted()
    }
    
    private func presentActiveProfile() {

        // do not present profile if:
        //
        // - an alert is active, as it would break navigation
        // - on iPad, as it's already shown
        //
        guard alertType == nil, themeIdiom != .pad else {
            return
        }

        guard isFirstLaunch, profileManager.hasActiveProfile else {
            return
        }
        isFirstLaunch = false
        isPresentingProfile = true
    }
    
    private func presentProfile(withId id: UUID) {
        do {
            try profileManager.loadCurrentProfile(withId: id, makeReady: true)
            isPresentingProfile = true
        } catch {
            pp_log.error("Unable to load profile: \(error)")
        }
    }

    private func removeActiveProfile(_ indexSet: IndexSet) {
        guard let activeHeader = activeHeaders?.first else {
            assertionFailure("Removing active profile while nil?")
            return
        }
        removeProfiles(withIds: [activeHeader.id])
    }
    
    private func removeOtherProfiles(_ indexSet: IndexSet) {
        let currentHeaders = otherHeaders
        var toDelete: [UUID] = []
        indexSet.forEach {
            toDelete.append(currentHeaders[$0].id)
        }
        removeProfiles(withIds: toDelete)
    }

    private func removeProfiles(withIds toDelete: [UUID]) {

        // clear selection before removal to avoid triggering a bogus navigation push
        if toDelete.contains(profileManager.currentProfile.value.id) {
            isPresentingProfile = false
        }

        profileManager.removeProfiles(withIds: toDelete)
    }
    
    private func performMigrationsIfNeeded() {
        Task {
            await appManager.doMigrations(profileManager)
        }
    }
    
    private func dismissSelectionIfDeleted(headers: [Profile.Header]) {
        if isPresentingProfile, !profileManager.isCurrentProfileExisting() {
            isPresentingProfile = false
        }
    }
}
