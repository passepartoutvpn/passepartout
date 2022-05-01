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

    @ObservedObject private var profileManager: ProfileManager

    @ObservedObject private var providerManager: ProviderManager

    // just to observe changes in profiles eligibility
    @ObservedObject private var productManager: ProductManager
    
    @State private var isFirstLaunch = true

    @State private var modalType: ModalType?

    @State private var alertType: AlertType?

    @State private var isHostFileImporterPresented = false

    @State private var presentedProfileId: UUID?

    private var presentedAndLoadedProfileId: Binding<UUID?> {
        .init {
            presentedProfileId
        } set: {
            guard $0 != presentedProfileId else {
                return
            }
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

    @AppStorage(AppManager.DefaultKey.didHandleSubreddit.rawValue) var didHandleSubreddit = false
    
    private let hostFileTypes = Constants.URLs.filetypes
    
    private let redditURL = Constants.URLs.subreddit
    
    init() {
        profileManager = .shared
        providerManager = .shared
        productManager = .shared
    }
    
    var body: some View {
        debugChanges()
        return ZStack {
            hiddenSceneView
            mainView
            if !profileManager.hasProfiles {
                emptyView
            }
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
//                EditButton()
            }
        }.sheet(item: $modalType, content: presentedModal)
        .alert(item: $alertType, content: presentedAlert)
        .navigationTitle(Unlocalized.appName)
        .themePrimaryView()

        // events
        .onAppear {
            performMigrationsIfNeeded()
        }.onChange(of: profileManager.headers) {
            dismissSelectionIfDeleted(headers: $0)
        }.onReceive(profileManager.didCreateProfile) {
            presentedAndLoadedProfileId.wrappedValue = $0.id
        }.fileImporter(
            isPresented: $isHostFileImporterPresented,
            allowedContentTypes: hostFileTypes,
            allowsMultipleSelection: false,
            onCompletion: onHostFileImporterResult
        ).onOpenURL(perform: onOpenURL)
    }
    
    private var hiddenSceneView: some View {
        SceneView(
            alertType: $alertType,
            didHandleSubreddit: $didHandleSubreddit
        )
    }
    
    private var mainView: some View {
        List {
            if profileManager.hasProfiles {
                switch themeIdiom {
                case .mac:
                    profilesView

                default:
                    // FIXME: iPad multitasking, navigation binding does not clear on pop without Section
                    Section {
                        profilesView
                    } header: {
                        Text(L10n.Global.Strings.profiles)
                    }
                }
            }
        }.themeAnimation(on: profileManager.headers)
    }
    
    private var profilesView: some View {
        ForEach(sortedHeaders, content: profileRow(forHeader:))
            .onDelete(perform: removeProfiles)
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
            .sorted {
                if profileManager.isActiveProfile($0.id) {
                    return true
                } else if profileManager.isActiveProfile($1.id) {
                    return false
                } else {
                    return $0 < $1
                }
            }
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
                AddHostView.NameView(
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

        // FIXME: iPad portrait/compact, preselecting profile on launch adds ProfileView() twice
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

    private func presentSubscribeReddit() {
        alertType = .subscribeReddit
    }
}
