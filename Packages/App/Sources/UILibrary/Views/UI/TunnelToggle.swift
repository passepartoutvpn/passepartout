//
//  TunnelToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/7/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

// FIXME: ###, handle all scenarios from TunnelToggleButton

public struct TunnelToggle: View {
    private let profile: Profile?

    @ObservedObject
    private var tunnel: ExtendedTunnel

    public init(profile: Profile?, tunnel: ExtendedTunnel) {
        self.profile = profile
        self.tunnel = tunnel
    }

    public var body: some View {
        Toggle("", isOn: tunnelBinding)
            .labelsHidden()
            .toggleStyle(.switch)
            .disabled(isDisabled)
    }
}

private extension TunnelToggle {
    var tunnelBinding: Binding<Bool> {
        Binding {
            tunnelProfile != nil
        } set: { isOn in
            guard let profile else {
                return
            }
            Task {
                if isOn, canConnect {
                    try await tunnel.connect(with: profile)
                } else {
                    try await tunnel.disconnect()
                }
            }
        }
    }

    var tunnelProfile: TunnelCurrentProfile? {
        guard let profile else {
            return nil
        }
        return tunnel.currentProfiles[profile.id]
    }

    var canConnect: Bool {
        if let tunnelProfile {
            return tunnelProfile.status == .inactive && !tunnelProfile.onDemand
        }
        return true
    }

    var isDisabled: Bool {
        profile == nil || tunnelProfile?.status == .deactivating
    }
}
