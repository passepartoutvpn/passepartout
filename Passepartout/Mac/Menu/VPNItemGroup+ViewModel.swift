//
//  VPNItemGroup+ViewModel.swift
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
import Combine

extension VPNItemGroup {

    @MainActor
    class ViewModel {
        private let vpnManager: LightVPNManager

        private let toggleTitleBlock: (Bool) -> String

        private let reconnectTitleBlock: () -> String

        private var didUpdateState: [(Bool, LightVPNStatus) -> Void] = []

        private var subscriptions: Set<AnyCancellable> = []

        init(
            vpnManager: LightVPNManager,
            toggleTitleBlock: @escaping (Bool) -> String,
            reconnectTitleBlock: @escaping () -> String
        ) {
            self.vpnManager = vpnManager
            self.toggleTitleBlock = toggleTitleBlock
            self.reconnectTitleBlock = reconnectTitleBlock

            vpnManager.addDelegate(self, withIdentifier: "VPNItemGroup")
        }

        deinit {
            Task { @MainActor in
                vpnManager.removeDelegate(withIdentifier: "VPNItemGroup")
            }
        }

        var toggleTitle: String {
            toggleTitleBlock(vpnManager.isEnabled)
        }

        var reconnectTitle: String {
            reconnectTitleBlock()
        }

        @objc func toggleVPN() {
            vpnManager.toggle()
        }

        @objc func reconnectVPN() {
            vpnManager.reconnect()
        }

        func subscribeVPNState(_ block: @escaping (Bool, LightVPNStatus) -> Void) {
            didUpdateState.append(block)
        }
    }
}

extension VPNItemGroup.ViewModel: LightVPNManagerDelegate {
    func didUpdateState(isEnabled: Bool, vpnStatus: LightVPNStatus) {
        didUpdateState.forEach {
            $0(isEnabled, vpnStatus)
        }
    }
}
