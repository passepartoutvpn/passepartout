//
//  ProviderProfileItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/13/22.
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

extension ProviderProfileItem {

    @MainActor
    class ViewModel {
        let profile: LightProfile

        private let providerManager: LightProviderManager

        private let vpnManager: LightVPNManager

        private var didUpdate: ((LightVPNStatus) -> Void)?

        init(_ profile: LightProfile, providerManager: LightProviderManager, vpnManager: LightVPNManager) {
            self.profile = profile
            self.providerManager = providerManager
            self.vpnManager = vpnManager

            vpnManager.addDelegate(self, withIdentifier: profile.id.uuidString)
        }

        deinit {
            Task { @MainActor in
                vpnManager.removeDelegate(withIdentifier: profile.id.uuidString)
            }
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
            category.name == profile.providerServer?.categoryName
        }

        @objc func connectTo() {
            vpnManager.connect(with: profile.id)
        }

        @objc func disconnect() {
            vpnManager.disconnect()
        }

        func downloadIfNeeded() {
            providerManager.downloadIfNeeded(providerName, vpnProtocol: vpnProtocol)
        }

        func subscribe(_ block: @escaping (LightVPNStatus) -> Void) {
            didUpdate = block
        }
    }
}

extension ProviderProfileItem.ViewModel: LightVPNManagerDelegate {
    func didUpdateState(isEnabled: Bool, vpnStatus: LightVPNStatus) {
        guard profile.isActive else {
            didUpdate?(.disconnected)
            return
        }
        didUpdate?(vpnStatus)
    }
}
