//
//  OrganizerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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

struct OrganizerView: View {
    enum ModalType: Identifiable {
        case addProvider

        case addHost(URL, Bool)
        
        case donate
        
        case share([Any])

        case about
        
        // XXX: alert ids
        var id: Int {
            switch self {
            case .addProvider: return 1

            case .addHost: return 2
                
            case .donate: return 4
                
            case .share: return 5
                
            case .about: return 6
            }
        }
    }
    
    enum AlertType: Identifiable {
        case subscribeReddit
        
        case error(String, Error)
        
        // XXX: alert ids
        var id: Int {
            switch self {
            case .subscribeReddit: return 1

            case .error: return 2
            }
        }
    }

    @State private var modalType: ModalType?

    @State private var alertType: AlertType?

    @State private var isHostFileImporterPresented = false

    @AppStorage(AppManager.DefaultKey.didHandleSubreddit.rawValue) var didHandleSubreddit = false
    
    private let hostFileTypes = Constants.URLs.filetypes
    
    private let redditURL = Constants.URLs.subreddit
    
    var body: some View {
        debugChanges()
        return ZStack {
            SceneView(
                alertType: $alertType,
                didHandleSubreddit: $didHandleSubreddit
            )
            ProfilesList(alertType: $alertType)
        }.toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddMenu(
                    modalType: $modalType,
                    isHostFileImporterPresented: $isHostFileImporterPresented
                )
            }
            ToolbarItem(placement: .navigationBarLeading) {
                SettingsMenu(
                    modalType: $modalType,
                    alertType: $alertType
                )
    //            EditButton()
            }
        }.sheet(item: $modalType, content: presentedModal)
        .alert(item: $alertType, content: presentedAlert)
        .fileImporter(
            isPresented: $isHostFileImporterPresented,
            allowedContentTypes: hostFileTypes,
            allowsMultipleSelection: false,
            onCompletion: onHostFileImporterResult
        ).onOpenURL(perform: onOpenURL)
        .navigationTitle(Unlocalized.appName)
    }
}

extension OrganizerView {
    
    @ViewBuilder
    private func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .addProvider:
            NavigationView {
                AddProviderView(
                    bindings: .init(
                        isPresented: isModalPresented
                    )
                )
            }.themeGlobal()

        case .addHost(let url, let deletingURLOnSuccess):
            NavigationView {
                AddHostView(
                    url: url,
                    deletingURLOnSuccess: deletingURLOnSuccess,
                    bindings: .init(
                        isPresented: isModalPresented
                    )
                )
            }.themeGlobal()
            
        case .donate:
            NavigationView {
                DonateView()
            }.themeGlobal()

        case .share(let items):
            ActivityView(activityItems: items)

        case .about:
            NavigationView {
                AboutView()
            }.themeGlobal()
        }
    }
    
    private var isModalPresented: Binding<Bool> {
        .init {
            modalType != nil
        } set: {
            if !$0 {
                modalType = nil
            }
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
                secondaryButton: .cancel(Text(L10n.Organizer.Alerts.Reddit.Buttons.never)) {
                    didHandleSubreddit = true
                }
            )

        case .error(let title, let error):
            return Alert(
                title: Text(title),
                message: Text(error.localizedDescription),
                dismissButton: .cancel(Text(L10n.Global.Strings.ok))
            )
        }
    }

    private func onHostFileImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                assertionFailure("Empty URLs from file importer?")
                return
            }
            modalType = .addHost(url, false)

        case .failure(let error):
            alertType = .error(
                L10n.Menu.Contextual.AddProfile.fromFiles,
                error
            )
        }
    }
    
    private func onOpenURL(_ url: URL) {
        modalType = .addHost(url, false)
    }
}

extension OrganizerView {
    private func presentSubscribeReddit() {
        alertType = .subscribeReddit
    }
}
