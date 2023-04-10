//
//  DefaultLightProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
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
import PassepartoutLibrary
import Combine

class DefaultLightProfile: LightProfile {
    let id: UUID

    let name: String

    let vpnProtocol: String

    let isActive: Bool

    let providerName: String?

    let providerServer: LightProviderServer?

    init(_ header: Profile.Header, vpnProtocol: String, isActive: Bool, providerServer: LightProviderServer?) {
        id = header.id
        name = header.name
        self.vpnProtocol = vpnProtocol
        self.isActive = isActive
        providerName = header.providerName
        self.providerServer = providerServer
    }
}

class DefaultLightProfileManager: LightProfileManager {
    private let profileManager = ProfileManager.shared

    private let providerManager = ProviderManager.shared

    private var subscriptions: Set<AnyCancellable> = []

    weak var delegate: LightProfileManagerDelegate?

    init() {
        profileManager.didUpdateProfiles
            .receive(on: DispatchQueue.main)
            .sink {
                self.delegate?.didUpdateProfiles()
            }.store(in: &subscriptions)
    }

    var hasProfiles: Bool {
        profileManager.hasProfiles
    }

    var profiles: [LightProfile] {
        profileManager.profiles
            .sorted {
                $0.header < $1.header
            }.map {
                let server: ProviderServer?
                if let serverId = $0.providerServerId {
                    server = providerManager.server(withId: serverId)
                } else {
                    server = nil
                }
                return DefaultLightProfile(
                    $0.header,
                    vpnProtocol: $0.currentVPNProtocol.rawValue,
                    isActive: profileManager.isActiveProfile($0.id),
                    providerServer: server.map(DefaultLightProviderServer.init)
                )
            }
    }

    var activeProfileId: UUID? {
        profileManager.activeProfileId
    }

    var activeProfileName: String? {
        guard let header = profileManager.headers.first(where: {
            $0.id == profileManager.activeProfileId
        }) else {
            return nil
        }
        return header.name
    }
}
