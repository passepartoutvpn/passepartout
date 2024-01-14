//
//  ProviderLocationView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

import PassepartoutLibrary
import SwiftUI

struct ProviderLocationView: View, ProviderProfileAvailability {
    @ObservedObject var providerManager: ProviderManager

    @ObservedObject private var currentProfile: ObservableProfile

    private let isEditable: Bool

    @Binding private var selectedServer: ProviderServer?

    @Binding private var favoriteLocationIds: Set<String>?

    @AppStorage(AppPreference.isShowingFavorites.key) private var isShowingFavorites = false

    var profile: Profile {
        currentProfile.value
    }

    init(currentProfile: ObservableProfile, isEditable: Bool, isPresented: Binding<Bool>) {
        let providerManager: ProviderManager = .shared

        self.providerManager = providerManager
        self.currentProfile = currentProfile
        self.isEditable = isEditable

        _selectedServer = currentProfile.selectedServerBinding(providerManager: providerManager, isPresented: isPresented)
        _favoriteLocationIds = currentProfile.providerFavoriteLocationIdsBinding
    }

    var body: some View {
        debugChanges()
        return Group {
            if isProviderProfileAvailable {
                mainView
            } else {
                EmptyView()
            }
        }.toolbar {
            Button {
                withAnimation {
                    isShowingFavorites.toggle()
                }
            } label: {
                themeFavoritesImage(isShowingFavorites).asSystemImage
            }
        }.navigationTitle(L10n.Provider.Location.title)
    }
}

extension ProviderLocationView {
    struct LocationRow: View {
        let location: ProviderLocation

        let selectedLocationId: String?

        var body: some View {
            HStack {
                themeAssetsCountryImage(location.countryCode).asAssetImage
                VStack {
                    if let singleServer = location.onlyServer,
                       let shortServerDescription = singleServer.localizedDescription(optionalStyle: .short) {

                        Text(location.localizedDescription(style: .country))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(shortServerDescription)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(location.localizedDescription(style: .country))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }.withTrailingCheckmark(when: location.id == selectedLocationId)
            }.frame(height: 60)
        }
    }

    struct ServerListView: View {
        @ObservedObject private var providerManager: ProviderManager

        private let location: ProviderLocation

        @Binding private var selectedServer: ProviderServer?

        init(location: ProviderLocation, selectedServer: Binding<ProviderServer?>) {
            providerManager = .shared
            self.location = location
            _selectedServer = selectedServer
        }

        var body: some View {
            ScrollViewReader { scrollProxy in
                List {
                    ForEach(servers) { server in
                        Button(server.localizedDescription(style: .shortWithDefault)) {
                            selectedServer = server
                        }.withTrailingCheckmark(when: server.id == selectedServer?.id)
                    }
                }.onAppear {
                    scrollToSelectedServer(scrollProxy)
                }
            }
        }
    }
}

// MARK: -

private extension ProviderLocationView {
    var providerName: ProviderName {
        guard let name = currentProfile.value.header.providerName else {
            assertionFailure("Not a provider")
            return ""
        }
        return name
    }

    var vpnProtocol: VPNProtocolType {
        currentProfile.value.currentVPNProtocol
    }

    var mainView: some View {
        // FIXME: layout, restore ScrollViewReader, but content inside it is not re-rendered on isShowingFavorites
//        ScrollViewReader { scrollProxy in
        List {
            if !isShowingEmptyFavorites {
                categoriesView
            } else {
                emptyFavoritesSection
            }
//            }.onAppear {
//                scrollToSelectedLocation(scrollProxy)
        }
//        }
    }

    var categoriesView: some View {
        ForEach(categories, content: categorySection)
    }

    func categorySection(_ category: ProviderCategory) -> some View {
        Section {
            ForEach(filteredLocations(for: category)) { location in
                if isEditable {
                    locationRow(location)
                        #if !os(tvOS)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            favoriteActions(location)
                        }
                        #endif
                } else {
                    locationRow(location)
                }
            }
        } header: {
            !category.name.isEmpty ? Text(category.name) : nil
        }
    }

    @ViewBuilder
    func locationRow(_ location: ProviderLocation) -> some View {
        if let onlyServer = location.onlyServer {
            singleServerRow(location, onlyServer)
        } else if profile.providerRandomizesServer ?? false {
            singleServerRow(location, nil)
        } else {
            multipleServersRow(location)
        }
    }

    func multipleServersRow(_ location: ProviderLocation) -> some View {
        NavigationLink(destination: {
            ServerListView(
                location: location,
                selectedServer: $selectedServer
            ).navigationTitle(location.localizedDescription(style: .country))
        }, label: {
            LocationRow(
                location: location,
                selectedLocationId: selectedServer?.locationId
            )
        })
    }

    func singleServerRow(_ location: ProviderLocation, _ server: ProviderServer?) -> some View {
        Button {
            selectedServer = server ?? location.servers?.randomElement()
        } label: {
            LocationRow(
                location: location,
                selectedLocationId: selectedServer?.locationId
            )
        }
    }

    func favoriteActions(_ location: ProviderLocation) -> some View {
        Button {
            withAnimation {
                toggleFavoriteLocation(location)
            }
        } label: {
            themeFavoriteActionImage(!isFavoriteLocation(location)).asSystemImage
        }.themePrimaryTintStyle()
    }

    var emptyFavoritesSection: some View {
        Section {
        } footer: {
            Text(L10n.Provider.Location.Sections.EmptyFavorites.footer)
        }
    }

    var isShowingEmptyFavorites: Bool {
        guard isShowingFavorites else {
            return false
        }
        return favoriteLocationIds?.isEmpty ?? true
    }
}

private extension ProviderLocationView {
    func server(withId serverId: String) -> ProviderServer? {
        providerManager.server(withId: serverId)
    }

    var categories: [ProviderCategory] {
        providerManager.categories(providerName, vpnProtocol: vpnProtocol)
            .filter {
                !filteredLocations(for: $0).isEmpty
            }.sorted()
    }

    func filteredLocations(for category: ProviderCategory) -> [ProviderLocation] {
        let locations: [ProviderLocation]
        if isShowingFavorites {
            locations = category.locations.filter {
                favoriteLocationIds?.contains($0.id) ?? false
            }
        } else {
            locations = category.locations
        }
        return locations.sorted()
    }

    func isFavoriteLocation(_ location: ProviderLocation) -> Bool {
        favoriteLocationIds?.contains(location.id) ?? false
    }
}

private extension ProviderLocationView.ServerListView {
    var servers: [ProviderServer] {
        providerManager.servers(forLocation: location).sorted()
    }
}

// MARK: -

private extension ProviderLocationView {
    func toggleFavoriteLocation(_ location: ProviderLocation) {
        if !isFavoriteLocation(location) {
            if favoriteLocationIds == nil {
                favoriteLocationIds = [location.id]
            } else {
                favoriteLocationIds?.insert(location.id)
            }
        } else {
            favoriteLocationIds?.remove(location.id)
        }
        // may trigger view updates?
//        pp_log.debug("New favorite locations: \(favoriteLocationIds ?? [])")
    }
}

private extension ProviderLocationView {
    func scrollToSelectedLocation(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(selectedServer?.locationId)
    }
}

private extension ProviderLocationView.ServerListView {
    func scrollToSelectedServer(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(selectedServer?.id)
    }
}

// MARK: - Bindings

private extension ObservableProfile {

    @MainActor
    func selectedServerBinding(providerManager: ProviderManager, isPresented: Binding<Bool>) -> Binding<ProviderServer?> {
        .init {
            guard let serverId = self.value.providerServerId else {
                return nil
            }
            return providerManager.server(withId: serverId)
        } set: {
            // user never selects a nil server
            guard let server = $0 else {
                return
            }
            self.value.setProviderServer(server)
            isPresented.wrappedValue = false
        }
    }

    var providerFavoriteLocationIdsBinding: Binding<Set<String>?> {
        .init {
            self.value.providerFavoriteLocationIds
        } set: {
            self.value.providerFavoriteLocationIds = $0
        }
    }
}
