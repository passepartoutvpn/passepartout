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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct TunnelToggleButton<Label>: View, TunnelContextProviding, ThemeProviding where Label: View {
    enum Style {
        case plain

        case color
    }

    @EnvironmentObject
    var theme: Theme

    @EnvironmentObject
    var connectionObserver: ConnectionObserver

    @EnvironmentObject
    private var iapManager: IAPManager

    @EnvironmentObject
    private var profileProcessor: ProfileProcessor

    var style: Style = .plain

    @ObservedObject
    var tunnel: Tunnel

    let profile: Profile?

    @Binding
    var nextProfileId: Profile.ID?

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    var onProviderEntityRequired: ((Profile) -> Void)?

    let label: (Bool) -> Label

    var body: some View {
        Button(action: tryPerform) {
            label(canConnect)
        }
        .foregroundStyle(color)
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

    var color: Color {
        switch style {
        case .plain:
            return .primary

        case .color:
            return tunnelStatusColor
        }
    }
}

private extension TunnelToggleButton {
    func tryPerform() {
        Task {
            guard let profile else {
                return
            }
            if !isInstalled {
                nextProfileId = profile.id
            }
            defer {
                if nextProfileId == profile.id {
                    nextProfileId = nil
                }
            }
            if canConnect && profile.isInteractive {
                if iapManager.isEligible(for: .interactiveLogin) {
                    pp_log(.app, .notice, "Present interactive login")
                    interactiveManager.present(with: profile) {
                        await perform(with: $0)
                    }
                    return
                } else {
                    pp_log(.app, .notice, "Suppress interactive login, not eligible")
                }
            }
            await perform(with: profile)
        }
    }

    func perform(with profile: Profile) async {
        do {
            if isInstalled {
                if canConnect {
                    try await tunnel.connect(with: profile, processor: profileProcessor)
                } else {
                    try await tunnel.disconnect()
                }
            } else {
                try await tunnel.connect(with: profile, processor: profileProcessor)
            }
        } catch is CancellationError {
            //
        } catch {
            switch (error as? PassepartoutError)?.code {
            case .providerRequired:
                errorHandler.handle(
                    error,
                    title: Strings.Global.connection
                )
                return

            case .missingProviderEntity:
                onProviderEntityRequired?(profile)
                return

            default:
                break
            }
            errorHandler.handle(
                error,
                title: Strings.Global.connection,
                message: Strings.Views.Profiles.Errors.tunnel
            )
        }
    }
}
