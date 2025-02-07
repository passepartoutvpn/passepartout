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
import CommonUtils
import PassepartoutKit
import SwiftUI

// FIXME: ###, duplication in TunnelToggleButton
#if !os(tvOS)

public struct TunnelToggle: View {

    @ObservedObject
    private var tunnel: ExtendedTunnel

    private let profile: Profile?

    private let errorHandler: ErrorHandler

    private let flow: ConnectionFlow?

    public init(tunnel: ExtendedTunnel, profile: Profile?, errorHandler: ErrorHandler, flow: ConnectionFlow?) {
        self.tunnel = tunnel
        self.profile = profile
        self.errorHandler = errorHandler
        self.flow = flow
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
        } set: {
            tryPerform(isOn: $0)
        }
    }
}

private extension TunnelToggle {
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

    func tryPerform(isOn: Bool) {
        guard let profile else {
            return
        }
        Task {
            await perform(isOn: isOn, with: profile)
        }
    }

    func perform(isOn: Bool, with profile: Profile) async {
        do {
            if tunnelProfile != nil {
                if isOn, canConnect {
                    await flow?.onConnect(profile)
                } else {
                    try await tunnel.disconnect()
                }
            } else {
                await flow?.onConnect(profile)
            }
        } catch is CancellationError {
            //
        } catch {
            errorHandler.handle(
                error,
                title: profile.name,
                message: Strings.Errors.App.tunnel
            )
        }
    }
}

#endif
