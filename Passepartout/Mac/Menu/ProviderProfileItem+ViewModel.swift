//
//  ProviderProfileItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/13/22.
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

import Foundation

extension ProviderProfileItem {
    class ViewModel {
        let profile: LightProfile
        
        private let providerManager: LightProviderManager

        private let vpnManager: LightVPNManager

        init(_ profile: LightProfile, providerManager: LightProviderManager, vpnManager: LightVPNManager) {
            self.profile = profile
            self.providerManager = providerManager
            self.vpnManager = vpnManager
        }

        private var providerName: String {
            guard let providerName = profile.providerName else {
                fatalError("ProviderProfileItem but profile is not a provider")
            }
            return providerName
        }

        private var vpnProtocol: String {
            profile.vpnProtocol
        }

        var categories: [LightProviderCategory] {
            providerManager.categories(providerName, vpnProtocol: vpnProtocol)
        }
        
        func isActiveCategory(_ category: LightProviderCategory) -> Bool {
            return category.name == profile.providerServer?.categoryName
        }
        
        func downloadIfNeeded() {
            providerManager.downloadIfNeeded(providerName, vpnProtocol: vpnProtocol)
        }
    }
}
