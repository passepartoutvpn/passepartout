//
//  OrganizerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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
import PassepartoutLibrary

struct OrganizerView: View {
    enum ModalType: Identifiable {
        case interactiveAccount(profile: Profile)

        // XXX: alert ids
        var id: Int {
            switch self {
            case .interactiveAccount: return 1
            }
        }
    }

    enum AlertType: Identifiable {
        case subscribeReddit

        case error(String, String)

        // XXX: alert ids
        var id: Int {
            switch self {
            case .subscribeReddit: return 1

            case .error: return 2
            }
        }
    }

    @State private var addProfileModalType: AddProfileMenu.ModalType?

    @State private var modalType: ModalType?

    @State private var alertType: AlertType?

    @State private var isHostFileImporterPresented = false

    @AppStorage(AppPreference.didHandleSubreddit.key) private var didHandleSubreddit = false

    private let hostFileTypes = Constants.URLs.filetypes

    private let redditURL = Constants.URLs.subreddit

    var body: some View {
        debugChanges()
        return ZStack {
            hiddenSceneView
            ProfilesList(modalType: $modalType)
        }.toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddProfileMenu(
                    modalType: $addProfileModalType,
                    isHostFileImporterPresented: $isHostFileImporterPresented
                )
            }
            ToolbarItem(placement: .navigation) {
                if themeIdiom == .phone {
                    SettingsButton()
                }
            }
        }.sheet(item: $modalType, content: presentedModal)
        .alert(item: $alertType, content: presentedAlert)
        .fileImporter(
            isPresented: $isHostFileImporterPresented,
            allowedContentTypes: hostFileTypes,
            allowsMultipleSelection: false,
            onCompletion: onHostFileImporterResult
        ).onOpenURL(perform: onOpenURL)
        .themePrimaryView()

        // VPN configuration error publisher (no need to observe VPNManager)
        .onReceive(VPNManager.shared.configurationError) {
            alertType = .error($0.profile.header.name, $0.error.localizedAppDescription)
        }
    }

    private var hiddenSceneView: some View {
        SceneView(
            alertType: $alertType,
            didHandleSubreddit: $didHandleSubreddit
        )
    }
}

extension OrganizerView {
    private func onHostFileImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                assertionFailure("Empty URLs from file importer?")
                return
            }
            Task { @MainActor in
                await Task.maybeWait(forMilliseconds: Constants.Delays.xxxPresentFileImporter)
                addProfileModalType = .addHost(url, false)
            }

        case .failure(let error):
            alertType = .error(
                L10n.Menu.Contextual.AddProfile.fromFiles,
                error.localizedDescription
            )
        }
    }

    private func onOpenURL(_ url: URL) {
        addProfileModalType = .addHost(url, false)
    }

    @ViewBuilder
    private func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .interactiveAccount(let profile):
            NavigationView {
                InteractiveConnectionView(profile: profile)
            }.themeGlobal()
        }
    }

    private func presentedAlert(_ alertType: AlertType) -> Alert {
        switch alertType {
        case .subscribeReddit:
            return Alert(
                title: Text(Unlocalized.Social.reddit),
                message: Text(L10n.Organizer.Alerts.Reddit.message),
                primaryButton: .default(Text(L10n.Organizer.Alerts.Reddit.Buttons.subscribe)) {
                    didHandleSubreddit = true
                    URL.openURL(redditURL)
                },
                secondaryButton: .cancel(Text(L10n.Global.Alerts.Buttons.never)) {
                    didHandleSubreddit = true
                }
            )

        case .error(let title, let errorDescription):
            return Alert(
                title: Text(title),
                message: Text(errorDescription),
                dismissButton: .cancel(Text(L10n.Global.Strings.ok))
            )
        }
    }
}

extension OrganizerView {
    private func presentSubscribeReddit() {
        alertType = .subscribeReddit
    }
}
