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
import StoreKit
import PassepartoutCore

struct OrganizerView: View {
    enum ModalType: Identifiable {
        case addProvider

        case addHost(URL, Bool)
        
        case presentPaywallShortcuts
        
        // XXX: alert ids
        var id: Int {
            switch self {
            case .addProvider: return 1

            case .addHost: return 2
                
            case .presentPaywallShortcuts: return 3
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

    @ObservedObject private var appManager: AppManager

    @State private var modalType: ModalType?

    @State private var alertType: AlertType?

    @State private var isHostFileImporterPresented = false

    @AppStorage(AppManager.DefaultKey.didHandleSubreddit.rawValue) var didHandleSubreddit = false
    
    init() {
        appManager = .shared
    }
    
    private let hostFileTypes = Constants.URLs.filetypes
    
    private let redditURL = Constants.URLs.subreddit
    
    private let appName = Unlocalized.appName

    private let versionString = Constants.Global.appVersionString

    var body: some View {
        debugChanges()
        return ZStack {
            SceneView(
                alertType: $alertType,
                didHandleSubreddit: $didHandleSubreddit
            )
            List {
                ProfilesSection(
                    addProfileMenuBindings: .init(
                        modalType: $modalType,
                        alertType: $alertType,
                        isHostFileImporterPresented: $isHostFileImporterPresented
                    )
                )
                ShortcutsSection(
                    modalType: $modalType
                )
                supportSection
                aboutSection
                RemoveVPNSection()
//                betaSection
            }
        }.navigationTitle(Unlocalized.appName)
        .toolbar(content: toolbar)
        .sheet(item: $modalType, content: presentedModal)
        .alert(item: $alertType, content: presentedAlert)
        .fileImporter(
            isPresented: $isHostFileImporterPresented,
            allowedContentTypes: hostFileTypes,
            allowsMultipleSelection: false,
            onCompletion: onHostFileImporterResult
        ).onOpenURL(perform: onOpenURL)
    }

    private func toolbar() -> some View {
        Menu {
            AddProfileMenu(
                withImportedURLs: true,
                bindings: .init(
                    modalType: $modalType,
                    alertType: $alertType,
                    isHostFileImporterPresented: $isHostFileImporterPresented
                )
            )
        } label: {
            themeAddProfileImage.asSystemImage
        }
    }
}

// MARK: Global handlers

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

        case .presentPaywallShortcuts:
            NavigationView {
                PaywallView(feature: .siriShortcuts)
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
                L10n.Organizer.Items.AddHost.caption,
                error
            )
        }
    }
    
    private func onOpenURL(_ url: URL) {
        modalType = .addHost(url, false)
    }
}

// MARK: Minor sections

extension OrganizerView {
    private var supportSection: some View {
        Section(
            header: Text(L10n.Organizer.Sections.Support.header)
        ) {
            NavigationLink {
                DonateView()
            } label: {
                Label(L10n.Organizer.Items.Donate.caption, systemImage: themeDonateImage)
            }.disabled(!SKPaymentQueue.canMakePayments())

            Button {
                URL.openURL(redditURL)
            } label: {
                Label(L10n.Organizer.Items.JoinCommunity.caption, systemImage: themeRedditImage)
            }
            Button(action: submitReview) {
                Label(L10n.Organizer.Items.WriteReview.caption, systemImage: themeWriteReviewImage)
            }
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Text(L10n.Organizer.Items.About.caption(appName))
//                    .withTrailingText(versionString)
            }
        }
    }
}

// MARK: Actions

extension OrganizerView {
    private func presentSubscribeReddit() {
        alertType = .subscribeReddit
    }

    private func submitReview() {
        let reviewURL = Reviewer.urlForReview(withAppId: Constants.App.appStoreId)
        URL.openURL(reviewURL)
    }
}
