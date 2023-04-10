//
//  DefaultLightProviderManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/7/22.
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

import Foundation
import Combine
import PassepartoutLibrary

class DefaultLightProviderCategory: LightProviderCategory {
    let name: String

    var locations: [LightProviderLocation]

    init(_ category: ProviderCategory) {
        name = category.name
        locations = category.locations
            .sorted()
            .map(DefaultLightProviderLocation.init)
    }
}

class DefaultLightProviderLocation: LightProviderLocation {
    let description: String

    let id: String

    let countryCode: String

    let servers: [LightProviderServer]

    init(_ location: ProviderLocation) {
        description = location.localizedCountry
        id = location.id
        countryCode = location.countryCode
        servers = location.servers?
            .sorted()
            .map(DefaultLightProviderServer.init) ?? []
    }
}

class DefaultLightProviderServer: LightProviderServer {
    let description: String

    let longDescription: String

    let categoryName: String

    let locationId: String

    let serverId: String

    init(_ server: ProviderServer) {
        description = server.localizedShortDescriptionWithDefault
        longDescription = server.localizedLongDescription(withCategory: false)
        categoryName = server.categoryName
        locationId = server.locationId
        serverId = server.id
    }
}

class DefaultLightProviderManager: LightProviderManager {
    private let providerManager = ProviderManager.shared

    private var subscriptions: Set<AnyCancellable> = []

    weak var delegate: LightProviderManagerDelegate?

    init() {
        providerManager.didUpdateProviders
            .receive(on: DispatchQueue.main)
            .sink {
                self.delegate?.didUpdateProviders()
            }.store(in: &subscriptions)
    }

    func categories(_ name: String, vpnProtocol: String) -> [LightProviderCategory] {
        guard let vpnProtocolType = VPNProtocolType(rawValue: vpnProtocol) else {
            fatalError("Unrecognized VPN protocol: \(vpnProtocol)")
        }
        return providerManager.categories(name, vpnProtocol: vpnProtocolType)
            .sorted()
            .map(DefaultLightProviderCategory.init)
    }

    func downloadIfNeeded(_ name: String, vpnProtocol: String) {
        guard let vpnProtocolType = VPNProtocolType(rawValue: vpnProtocol) else {
            fatalError("Unrecognized VPN protocol: \(vpnProtocol)")
        }
        guard !providerManager.isAvailable(name, vpnProtocol: vpnProtocolType) else {
            return
        }
        Task {
            try await providerManager.fetchProviderPublisher(withName: name, vpnProtocol: vpnProtocolType, priority: .remoteThenBundle).async()
        }
    }
}
