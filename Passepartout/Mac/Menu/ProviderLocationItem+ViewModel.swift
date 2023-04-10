//
//  ProviderLocationItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/8/22.
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

extension ProviderLocationItem {

    @MainActor
    class ViewModel {
        private let profile: LightProfile

        let location: LightProviderLocation

        private let vpnManager: LightVPNManager

        init(_ profile: LightProfile, _ location: LightProviderLocation, vpnManager: LightVPNManager) {
            self.profile = profile
            self.location = location
            self.vpnManager = vpnManager
        }

        var isActiveLocation: Bool {
            location.id == profile.providerServer?.locationId
        }

        var isOnlyServer: Bool {
            location.servers.count == 1
        }

        @objc func connectTo() {
            guard isOnlyServer else {
                fatalError("Connecting to a location with multiple servers?")
            }
            vpnManager.connect(with: profile.id, to: location.servers.first!.serverId)
        }
    }
}
