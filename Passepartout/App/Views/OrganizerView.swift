//
//  OrganizerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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

        // XXX: alert ids
        var id: Int {
            switch self {
            case .subscribeReddit: return 1
            }
        }
    }

    @State private var addProfileModalType: AddProfileMenu.ModalType?

    @State private var modalType: ModalType?

    @State private var isAlertPresented = false

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
        .alert(
            Unlocalized.appName,
            isPresented: $isAlertPresented,
            presenting: alertType,
            actions: alertActions,
            message: alertMessage
        )
        .fileImporter(
            isPresented: $isHostFileImporterPresented,
            allowedContentTypes: hostFileTypes,
            allowsMultipleSelection: false,
            onCompletion: onHostFileImporterResult
        )
        .onOpenURL(perform: onOpenURL)
        .themePrimaryView()
    }
}

// MARK: -

private extension OrganizerView {
    var hiddenSceneView: some View {
        SceneView(
            isAlertPresented: $isAlertPresented,
            alertType: $alertType,
            didHandleSubreddit: $didHandleSubreddit
        )
    }

    @ViewBuilder
    func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .interactiveAccount(let profile):
            NavigationView {
                InteractiveConnectionView(profile: profile)
            }.themeGlobal()
        }
    }

    func alertActions(_ alertType: AlertType) -> some View {
        switch alertType {
        case .subscribeReddit:
            return Group {
                Button(L10n.Organizer.Alerts.Reddit.Buttons.subscribe) {
                    didHandleSubreddit = true
                    URL.open(redditURL)
                }
                Button(role: .cancel) {
                    didHandleSubreddit = true
                } label: {
                    Text(L10n.Global.Alerts.Buttons.never)
                }
            }
        }
    }

    func alertMessage(_ alertType: AlertType) -> some View {
        switch alertType {
        case .subscribeReddit:
            return Text(L10n.Organizer.Alerts.Reddit.message)
        }
    }
}

// MARK: -

private extension OrganizerView {

    @MainActor
    func onHostFileImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                assertionFailure("Empty URLs from file importer?")
                return
            }
            Task {
                await Task.maybeWait(forMilliseconds: Constants.Delays.xxxPresentFileImporter)
                addProfileModalType = .addHost(url, false)
            }

        case .failure(let error):
            ErrorHandler.shared.handle(error, title: L10n.Menu.Contextual.AddProfile.fromFiles)
        }
    }

    func onOpenURL(_ url: URL) {
        addProfileModalType = .addHost(url, false)
    }
}
#endif
