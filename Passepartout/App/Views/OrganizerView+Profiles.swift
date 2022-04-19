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
        
        @State private var localHeaders: [Profile.Header] = []

        @State private var selectedProfileId: UUID?
        
        init(alertType: Binding<AlertType?>) {
            appManager = .shared
            profileManager = .shared
            providerManager = .shared
            productManager = .shared
            _alertType = alertType
        }

        var body: some View {
            debugChanges()
            return Group {
                mainView
                if localHeaders.isEmpty {
                    emptyView
                }
            }.onAppear {
                reloadHeaders(profileManager.headers)
                performMigrationsIfNeeded()
            }.onChange(of: profileManager.headers) { newHeaders in
                withAnimation {
                    guard Set(newHeaders) != Set(localHeaders) else {
                        return
                    }
                    reloadHeaders(newHeaders)
                    dismissSelectionIfDeleted(headers: newHeaders)
                }
            }

            // from AddProfileView
            .onReceive(profileManager.didCreateProfile) {
                selectedProfileId = $0.id
            }
        }
        
        private var mainView: some View {
            List {
                Section {
                    ForEach(localHeaders, content: navigationLink(forHeader:))
                        .onDelete(perform: removeProfiles)
                }
            }
        }

        // FIXME: l10n
        private var emptyView: some View {
            VStack {
                Text("No profiles")
                    .themeInformativeText()
            }
        }

        private func navigationLink(forHeader header: Profile.Header) -> some View {
            NavigationLink(tag: header.id, selection: $selectedProfileId) {
                ProfileView(header: header)
            } label: {
                if profileManager.isActiveProfile(header.id) {
                    ActiveProfileHeaderRow(header: header)
                } else {
                    ProfileHeaderRow(header: header)
                }
            }.onAppear {
                preselectIfActiveProfile(header.id)
            }
        }
    }
}

extension OrganizerView.ProfilesList {
    struct ActiveProfileHeaderRow: View {
        @ObservedObject private var currentVPNState: VPNManager.ObservableState

        private let header: Profile.Header
        
        init(header: Profile.Header) {
            currentVPNState = .shared
            self.header = header
        }
        
        var body: some View {
            debugChanges()
            return ProfileHeaderRow(header: header)
                .withTrailingText(statusDescription)
        }

        private var statusDescription: String {
            return currentVPNState.localizedStatusDescription(
                withErrors: false,
                withDataCount: false
            )
        }
    }
}

extension OrganizerView.ProfilesList {
    private func reloadHeaders(_ newHeaders: [Profile.Header]) {
        localHeaders = newHeaders.sorted()
    }
    
    private func preselectIfActiveProfile(_ id: UUID) {

        // do not push profile if:
        //
        // - an alert is active, as it would break navigation
        // - on iPad, as it's already shown
        //
        guard alertType == nil, themeIdiom != .pad, id == profileManager.activeHeader?.id else {
            return
        }
        guard isFirstLaunch else {
            return
        }
        isFirstLaunch = false

        selectedProfileId = id
    }

    private func performMigrationsIfNeeded() {
        Task {
            await appManager.doMigrations(profileManager)
        }
    }
    
    private func removeProfiles(_ indexSet: IndexSet) {
        withAnimation {
            doRemoveProfiles(indexSet)
        }
    }

    private func doRemoveProfiles(_ indexSet: IndexSet) {
        var toDelete: [UUID] = []
        indexSet.forEach {
            toDelete.append(localHeaders[$0].id)
        }

        // clear selection before removal to avoid triggering a bogus navigation push
        if let selectedProfileId = selectedProfileId, toDelete.contains(selectedProfileId) {
            self.selectedProfileId = nil
        }

        profileManager.removeProfiles(withIds: toDelete)

        // IMPORTANT: synchronize headers here to prevent .onChange() from animating a second time
        localHeaders.remove(atOffsets: indexSet)
    }

    private func dismissSelectionIfDeleted(headers: [Profile.Header]) {
        if let selectedProfileId = selectedProfileId,
           !profileManager.isExistingProfile(withId: selectedProfileId) {

            self.selectedProfileId = nil
        }
    }
}
