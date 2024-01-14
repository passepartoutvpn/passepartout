//
//  ProfilesList+TV.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/18/23.
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

#if os(tvOS)
import PassepartoutLibrary
import SwiftUI

struct ProfilesListView: View {
    @ObservedObject private var profileManager: ProfileManager

    @Environment(\.presentationMode) private var presentationMode

    @State private var profileIdPendingSelection: UUID?

    @FocusState private var focusedProfileId: UUID?

    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    var body: some View {
        List {
            Section {
                Text(listHeader)
                    .font(.footnote)
                    .themeSecondaryTextStyle()
                ForEach(profiles, content: profileRow)
                    .themeAnimation(on: profiles)
            }
        }
        .onAppear {
            focusedProfileId = profileManager.activeProfileId
        }
        .disabled(profileIdPendingSelection != nil)
        .navigationTitle(Text(L10n.Global.Strings.profiles))
        .themeTV()
    }
}

private extension ProfilesListView {
    var profiles: [Profile] {
        profileManager.profiles.sorted()
    }

    var listHeader: String {
        [
            L10n.Organizer.Sections.Tv.ProfilesList.Header.p1,
            L10n.Profile.Sections.Tv.Footer.encryption
        ]
            .joined(separator: " ")
    }

    func profileRow(for profile: Profile) -> some View {
        Button {
            activateProfile(profile)
        } label: {
            HStack {
                Text(profile.header.name)
                Spacer()
                if profile.header.id == profileIdPendingSelection {
                    ProgressView()
                } else if profileManager.isActiveProfile(profile.header.id) {
                    themeCheckmarkImage.asSystemImage
                }
            }
        }
        .focused($focusedProfileId, equals: profile.id)
    }

    func activateProfile(_ profile: Profile) {
        guard profile.id != profileManager.activeProfileId else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        Task {
            profileIdPendingSelection = profile.id
            do {
                try await profileManager.makeProfileReady(profile)
                await VPNManager.shared.disable()
                profileManager.activateProfile(profile)
                presentationMode.wrappedValue.dismiss()
            } catch {
                ErrorHandler.shared.handle(
                    title: L10n.Global.Strings.profiles,
                    message: AppError(error).localizedDescription
                )
            }
        }
    }
}
#endif
