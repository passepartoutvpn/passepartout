//
//  TunnelToggleButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

public struct TunnelToggleButton<Label>: View, Routable, ThemeProviding where Label: View {

    @EnvironmentObject
    public var theme: Theme

    @ObservedObject
    private var tunnel: ExtendedTunnel

    private let profile: Profile?

    @Binding
    private var nextProfileId: Profile.ID?

    private let errorHandler: ErrorHandler

    public let flow: ConnectionFlow?

    private let label: (Bool) -> Label

    public init(
        tunnel: ExtendedTunnel,
        profile: Profile?,
        nextProfileId: Binding<Profile.ID?>,
        errorHandler: ErrorHandler,
        flow: ConnectionFlow?,
        label: @escaping (Bool) -> Label
    ) {
        self.tunnel = tunnel
        self.profile = profile
        _nextProfileId = nextProfileId
        self.errorHandler = errorHandler
        self.flow = flow
        self.label = label
    }

    public var body: some View {
        Button(action: tryPerform) {
            label(canConnect)
        }
#if os(macOS)
        .buttonStyle(.plain)
        .cursor(.hand)
#endif
        .disabled(profile == nil || (isInstalled && tunnel.status == .deactivating))
    }
}

private extension TunnelToggleButton {
    var isInstalled: Bool {
        profile?.id == tunnel.currentProfile?.id
    }

    var canConnect: Bool {
        !isInstalled || (tunnel.status == .inactive && tunnel.currentProfile?.onDemand != true)
    }
}

private extension TunnelToggleButton {
    func tryPerform() {
        guard let profile else {
            return
        }
        Task {
            if !isInstalled {
                nextProfileId = profile.id
            }
            defer {
                if nextProfileId == profile.id {
                    nextProfileId = nil
                }
            }
            await perform(with: profile)
        }
    }

    func perform(with profile: Profile) async {
        do {
            if isInstalled {
                if canConnect {
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
