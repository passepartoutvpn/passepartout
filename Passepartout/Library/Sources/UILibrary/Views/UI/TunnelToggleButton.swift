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

public struct TunnelToggleButton<Label>: View, ThemeProviding where Label: View {

    @EnvironmentObject
    public var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    private var tunnel: ExtendedTunnel

    private let profile: Profile?

    @Binding
    private var nextProfileId: Profile.ID?

    private let interactiveManager: InteractiveManager

    private let errorHandler: ErrorHandler

    private let onProviderEntityRequired: (Profile) -> Void

    private let onPurchaseRequired: (Set<AppFeature>) -> Void

    private let label: (Bool) -> Label

    public init(
        tunnel: ExtendedTunnel,
        profile: Profile?,
        nextProfileId: Binding<Profile.ID?>,
        interactiveManager: InteractiveManager,
        errorHandler: ErrorHandler,
        onProviderEntityRequired: @escaping (Profile) -> Void,
        onPurchaseRequired: @escaping (Set<AppFeature>) -> Void,
        label: @escaping (Bool) -> Label
    ) {
        self.tunnel = tunnel
        self.profile = profile
        _nextProfileId = nextProfileId
        self.interactiveManager = interactiveManager
        self.errorHandler = errorHandler
        self.onProviderEntityRequired = onProviderEntityRequired
        self.onPurchaseRequired = onPurchaseRequired
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

                // ineligible, suppress interactive login
                if !iapManager.isEligible(for: .interactiveLogin) {
                    pp_log(.app, .notice, "Ineligible, suppress interactive login")
                } else {
                    pp_log(.app, .notice, "Present interactive login")
                    interactiveManager.present(with: profile) {
                        await perform(with: $0)
                    }
                    return
                }
            }
            await perform(with: profile)
        }
    }

    func perform(with profile: Profile) async {
        do {
            if isInstalled {
                if canConnect {
                    try await tunnel.connect(with: profile)
                } else {
                    try await tunnel.disconnect()
                }
            } else {
                try await tunnel.connect(with: profile)
            }
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            onPurchaseRequired(requiredFeatures)
        } catch is CancellationError {
            //
        } catch {
            switch (error as? PassepartoutError)?.code {
            case .missingProviderEntity:
                onProviderEntityRequired(profile)
                return

            case .providerRequired:
                errorHandler.handle(
                    error,
                    title: Strings.Global.connection
                )
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
