//
//  HostProfileItem+ViewModel.swift
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

extension HostProfileItem {

    @MainActor
    class ViewModel {
        let profile: LightProfile

        private let vpnManager: LightVPNManager

        private var didUpdate: ((LightVPNStatus) -> Void)?

        init(_ profile: LightProfile, vpnManager: LightVPNManager) {
            self.profile = profile
            self.vpnManager = vpnManager

            vpnManager.addDelegate(self, withIdentifier: profile.id.uuidString)
        }

        deinit {
            Task { @MainActor in
                vpnManager.removeDelegate(withIdentifier: profile.id.uuidString)
            }
        }

        @objc func connectTo() {
            vpnManager.connect(with: profile.id)
        }

        @objc func disconnect() {
            vpnManager.disconnect()
        }

        func subscribe(_ block: @escaping (LightVPNStatus) -> Void) {
            didUpdate = block
        }
    }
}

extension HostProfileItem.ViewModel: LightVPNManagerDelegate {
    func didUpdateState(isEnabled: Bool, vpnStatus: LightVPNStatus) {
        guard profile.isActive else {
            didUpdate?(.disconnected)
            return
        }
        didUpdate?(vpnStatus)
    }
}
