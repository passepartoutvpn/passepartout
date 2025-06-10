//
//  ProfilesView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/6/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct ProfilesView: View {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var webReceiverManager: WebReceiverManager

    let registry: Registry

    @FocusState
    private var detail: Detail?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        HStack {
            masterView
            detailView
        }
        .background(theme.primaryGradient)
        .withErrorHandler(errorHandler)
    }
}

private extension ProfilesView {
    var masterView: some View {
        List {
            importSection
            if profileManager.hasProfiles {
                profilesSection
            }
        }
        .themeList()
        .frame(maxWidth: .infinity)
    }

    var detailView: some View {
        DetailView(
            detail: detail,
            webReceiverManager: webReceiverManager,
            registry: registry,
            profileManager: profileManager,
            errorHandler: errorHandler
        )
        .frame(maxWidth: .infinity)
    }

    var importSection: some View {
        webReceiverButton
            .themeSection(header: Strings.Global.Actions.import)
    }

    var webReceiverButton: some View {
        Toggle(Strings.Views.Tv.Profiles.importLocal, isOn: isImporterEnabled)
            .focused($detail, equals: .import)
    }

    var profilesSection: some View {
        ForEach(profileManager.previews, id: \.id, content: row(forProfilePreview:))
            .themeSection(header: Strings.Global.Nouns.profiles)
    }

    func row(forProfilePreview preview: ProfilePreview) -> some View {
        Button {
            //
        } label: {
            HStack {
                Text(preview.name)
                Spacer()
                if profileManager.isRemotelyShared(profileWithId: preview.id) {
                    ThemeImage(.cloudOn)
                }
            }
        }
        .contextMenu {
            if !profileManager.isRemotelyShared(profileWithId: preview.id) {
                Button(Strings.Global.Actions.delete, role: .destructive) {
                    deleteProfile(withId: preview.id)
                }
            }
        }
        .focused($detail, equals: .profiles)
    }
}

private extension ProfilesView {
    var isImporterEnabled: Binding<Bool> {
        Binding {
            webReceiverManager.isStarted
        } set: {
            if $0 {
                do {
                    try webReceiverManager.start()
                } catch {
                    pp_log_g(.app, .error, "Unable to start web receiver: \(error)")
                    errorHandler.handle(error)
                }
            } else {
                webReceiverManager.stop()
            }
       }
    }

    func deleteProfile(withId profileId: Profile.ID) {
        Task {
            await profileManager.remove(withId: profileId)
        }
    }
}

// MARK: - Detail

private enum Detail {
    case `import`

    case profiles
}

private struct DetailView: View {
    let detail: Detail?

    @ObservedObject
    var webReceiverManager: WebReceiverManager

    let registry: Registry

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        VStack {
            TopSpacer()
            switch detail {
            case .import:
                importView
            case .profiles:
                Text(Strings.Views.Tv.Profiles.Detail.profiles)
            default:
                Text("") // take space regardless
            }
            Spacer()
        }
    }
}

private extension DetailView {
    var importView: some View {
        WebReceiverView(
            webReceiverManager: webReceiverManager,
            registry: registry,
            profileManager: profileManager,
            errorHandler: errorHandler
        )
    }
}

// MARK: - Preview

#Preview {
    ProfilesView(
        profileManager: .forPreviews,
        webReceiverManager: .forPreviews,
        registry: Registry()
    )
    .withMockEnvironment()
}
