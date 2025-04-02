//
//  SettingsCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/22/24.
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
import UILibrary

struct SettingsCoordinator: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.dismiss)
    private var dismiss

    let profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    @State
    private var path = NavigationPath()

    @State
    private var navigationRoute: SettingsCoordinatorRoute?

    var body: some View {
        SettingsContentView(
            profileManager: profileManager,
            isBeta: iapManager.isBeta,
            path: $path,
            navigationRoute: $navigationRoute,
            linkContent: linkView(to:),
            settingsDestination: pushDestination(for:),
            diagnosticsDestination: pushDestination(for:)
        )
    }
}

extension SettingsCoordinator {
    func linkView(to route: SettingsCoordinatorRoute) -> some View {
        NavigationLink(value: route) {
            linkLabel(for: route)
        }
    }

    func title(for route: SettingsCoordinatorRoute) -> String {
        switch route {
        case .changelog:
            Strings.Unlocalized.changelog

        case .credits:
            Strings.Views.Settings.Credits.title

        case .diagnostics:
            Strings.Views.Diagnostics.title

        case .donate:
            Strings.Views.Donate.title

        case .links:
            Strings.Views.Settings.Links.title

        case .preferences:
            Strings.Global.Nouns.preferences

        case .purchases:
            Strings.Global.Nouns.purchases

        case .version:
            Strings.Views.Settings.title
        }
    }

    @ViewBuilder
    func linkLabel(for route: SettingsCoordinatorRoute) -> some View {
        switch route {
        case .version:
            Text(Strings.Global.Nouns.version)
#if os(iOS)
                .themeTrailingValue(BundleConfiguration.mainVersionString)
#endif

        default:
            Text(title(for: route))
        }
    }

    @ViewBuilder
    func pushDestination(for item: SettingsCoordinatorRoute?) -> some View {
        switch item {
        case .changelog:
            ChangelogView()
                .navigationTitle(title(for: .changelog))

        case .credits:
            CreditsView()
                .navigationTitle(title(for: .credits))

        case .diagnostics:
            DiagnosticsView(profileManager: profileManager, tunnel: tunnel)
                .navigationTitle(title(for: .diagnostics))

        case .donate:
            DonateView(modifier: DonateViewModifier())
                .navigationTitle(title(for: .donate))

        case .links:
            LinksView()
                .navigationTitle(title(for: .links))

        case .preferences:
            PreferencesView(profileManager: profileManager)
                .navigationTitle(title(for: .preferences))

        case .purchases:
            PurchasedView()
                .navigationTitle(Strings.Global.Nouns.purchases)

        case .version:
            VersionView(changelogRoute: SettingsCoordinatorRoute.changelog)

        default:
            Text(Strings.Global.Nouns.noSelection)
                .themeEmptyMessage()
        }
    }

    @ViewBuilder
    func pushDestination(for item: DiagnosticsRoute?) -> some View {
        switch item {
        case .appLog(let title):
            DebugLogView(withAppParameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }
            .navigationTitle(title)

        case .tunnelLog(let title, let url):
            if let url {
                DebugLogView(withURL: url) {
                    DebugLogContentView(lines: $0)
                }
                .navigationTitle(title)
            } else {
                DebugLogView(withTunnel: tunnel, parameters: Constants.shared.log) {
                    DebugLogContentView(lines: $0)
                }
                .navigationTitle(title)
            }

        default:
            Text(Strings.Global.Nouns.noSelection)
                .themeEmptyMessage()
        }
    }
}

#Preview {
    SettingsCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews
    )
    .withMockEnvironment()
#if os(macOS)
    .environmentObject(MacSettingsModel())
#endif
}
