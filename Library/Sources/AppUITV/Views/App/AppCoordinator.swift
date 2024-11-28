//
//  AppCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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
import UILibrary

public struct AppCoordinator: View, AppCoordinatorConforming {
    private let profileManager: ProfileManager

    private let tunnel: ExtendedTunnel

    private let registry: Registry

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    public init(profileManager: ProfileManager, tunnel: ExtendedTunnel, registry: Registry) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        debugChanges()
        return NavigationStack {
            TabView {
                profileView
                    .tabItem {
                        Text(Strings.Global.Nouns.profile)
                    }

//                searchView
//                    .tabItem {
//                        ThemeImage(.search)
//                    }

                settingsView
                    .tabItem {
                        ThemeImage(.settings)
                    }
            }
            .navigationDestination(for: AppCoordinatorRoute.self, destination: pushDestination)
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
        }
    }
}

private extension AppCoordinator {
    var profileView: some View {
        ProfileView(
            profileManager: profileManager,
            tunnel: tunnel,
            errorHandler: errorHandler,
            flow: .init(
                onProviderEntityRequired: onProviderEntityRequired,
                onPurchaseRequired: onPurchaseRequired
            )
        )
    }

//    var searchView: some View {
//        VStack {
//            Text("Search")
//        }
//    }

    var settingsView: some View {
        SettingsView(tunnel: tunnel)
    }
}

private extension AppCoordinator {

    @ViewBuilder
    func pushDestination(_ item: AppCoordinatorRoute?) -> some View {
        switch item {
        case .appLog:
            DebugLogView(withAppParameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }

        case .tunnelLog:
            DebugLogView(withTunnel: tunnel, parameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }

        default:
            EmptyView()
        }
    }
}

private extension AppCoordinator {
    func onProviderEntityRequired(_ profile: Profile) {
        errorHandler.handle(
            title: profile.name,
            message: Strings.Alerts.Providers.MissingServer.message
        )
    }

    func onPurchaseRequired(_ features: Set<AppFeature>) {
        setLater(.init(features, needsConfirmation: true)) {
            paywallReason = $0
        }
    }
}

// MARK: -

#Preview {
    AppCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        registry: Registry()
    )
    .withMockEnvironment()
}
