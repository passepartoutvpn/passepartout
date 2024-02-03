//
//  OrganizerView+Profiles.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/3/22.
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

#if !os(tvOS)
import PassepartoutLibrary
import SwiftUI

extension OrganizerView {
    struct ProfilesList: View {
        @ObservedObject private var profileManager: ProfileManager

        @Binding private var modalType: ModalType?

        init(modalType: Binding<ModalType?>) {
            profileManager = .shared
            _modalType = modalType
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
            if profileManager.isActiveProfile(header.id) {
                reconnectButton
            }
            duplicateButton
            deleteButton
        }
    }
}

// MARK: -

private extension OrganizerView.ProfilesList {
    var mainView: some View {
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
        }
        .themeAnimation(on: profileManager.headers)
    }

    var profilesView: some View {
        ForEach(sortedProfiles, content: profileRow(forProfile:))
            .onDelete(perform: removeProfiles)
    }

    var emptyView: some View {
        VStack {
            Text(L10n.Organizer.Empty.noProfiles)
                .themeInformativeTextStyle()
        }
    }

    func profileRow(forProfile profile: Profile) -> some View {
        NavigationLink(tag: profile.id, selection: $profileManager.currentProfileId) {
            ProfileView()
        } label: {
            profileLabel(forProfile: profile)
        }
        .contextMenu {
            OrganizerView.ProfileContextMenu(header: profile.header)
        }
        .themeListSelectionColor(isSelected: profileManager.isCurrentProfile(profile.id))
    }

    func profileLabel(forProfile profile: Profile) -> some View {
        OrganizerView.ProfileRow(
            profile: profile,
            isActiveProfile: profileManager.isActiveProfile(profile.id),
            modalType: $modalType
        )
    }

    var sortedProfiles: [Profile] {
        profileManager.profiles
            .sorted()
    }
}

private extension OrganizerView.ProfileContextMenu {
    var reconnectButton: some View {
        ProfileView.ReconnectButton()
    }

    var duplicateButton: some View {
        ProfileView.DuplicateButton(
            header: header,
            setAsCurrent: false
        )
    }

    var deleteButton: some View {
        Button(role: .destructive) {
            withAnimation {
                profileManager.removeProfiles(withIds: [header.id])
            }
        } label: {
            Label(L10n.Global.Strings.delete, systemImage: themeDeleteImage)
        }
    }
}

// MARK: -

private extension OrganizerView.ProfilesList {
    func removeProfiles(at offsets: IndexSet) {
        let currentHeaders = sortedProfiles
        var toDelete: [UUID] = []
        offsets.forEach {
            toDelete.append(currentHeaders[$0].id)
        }
        withAnimation {
            profileManager.removeProfiles(withIds: toDelete)
        }
    }

    func performMigrationsIfNeeded() {
        Task { @MainActor in
            UpgradeManager.shared.migrateData(profileManager: profileManager)
        }
    }
}
#endif
