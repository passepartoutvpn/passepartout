//
//  DefaultLightVPNManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
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
import PassepartoutLibrary
import Combine

class DefaultLightVPNManager: LightVPNManager {
    private let vpnManager = Impl.VPNManager.shared
    
    private var subscriptions: Set<AnyCancellable> = []
    
    var isEnabled: Bool {
        vpnManager.currentState.isEnabled
    }
    
    var vpnStatus: LightVPNStatus {
        vpnManager.currentState.vpnStatus.asLightVPNStatus
    }
    
    weak var delegate: LightVPNManagerDelegate?

    init() {
        vpnManager.currentState.$isEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {
                self.delegate?.didUpdateState(
                    isEnabled: $0,
                    vpnStatus: self.vpnManager.currentState.vpnStatus.asLightVPNStatus
                )
            }.store(in: &subscriptions)

        vpnManager.currentState.$vpnStatus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {
                self.delegate?.didUpdateState(
                    isEnabled: self.vpnManager.currentState.isEnabled,
                    vpnStatus: $0.asLightVPNStatus
                )
            }.store(in: &subscriptions)
    }
    
    @MainActor
    func connect(with profileId: UUID) {
        Task {
            try? await vpnManager.connect(with: profileId)
        }
    }

    @MainActor
    func connect(with profileId: UUID, to serverId: String) {
        Task {
            try? await vpnManager.connect(with: profileId, toServer: serverId)
        }
    }

    @MainActor
    func toggle() {
        Task {
            if !isEnabled {
                try? await vpnManager.connectWithActiveProfile(toServer: nil)
            } else {
                await vpnManager.disable()
            }
        }
    }

    @MainActor
    func reconnect() {
        Task {
            if isEnabled {
                await vpnManager.disable()
                try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            }
            try? await vpnManager.connectWithActiveProfile(toServer: nil)
        }
    }
}

private extension VPNStatus {
    var asLightVPNStatus: LightVPNStatus {
        switch self {
        case .connected:
            return .connected
            
        case .connecting:
            return .connecting
            
        case .disconnected:
            return .disconnected
            
        case .disconnecting:
            return .disconnecting
        }
    }
}
