//
//  AboutRouterView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/22/24.
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
import PassepartoutKit
import SwiftUI

struct AboutRouterView: View {

    @Environment(\.dismiss)
    var dismiss

    let profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    @State
    var path = NavigationPath()

    @State
    var navigationRoute: NavigationRoute?
}

extension AboutRouterView {
    enum NavigationRoute: Hashable {
        case appDebugLog(title: String)

        case credits

        case diagnostics

        case donate

        case links

        case tunnelDebugLog(title: String, url: URL?)
    }

    @ViewBuilder
    func pushDestination(for item: NavigationRoute?) -> some View {
        switch item {
        case .appDebugLog(let title):
            DebugLogView.withApp(parameters: Constants.shared.log)
                .navigationTitle(title)

        case .credits:
            CreditsView()

        case .diagnostics:
            DiagnosticsView(
                profileManager: profileManager,
                tunnel: tunnel
            )

        case .donate:
            DonateView()

        case .links:
            LinksView()

        case .tunnelDebugLog(let title, let url):
            if let url {
                DebugLogView.withURL(url)
                    .navigationTitle(title)
            } else {
                DebugLogView.withTunnel(tunnel, parameters: Constants.shared.log)
                    .navigationTitle(title)
            }

        default:
            Text(Strings.Global.noSelection)
                .themeEmptyMessage()
        }
    }
}

#Preview {
    AboutRouterView(
        profileManager: .mock,
        tunnel: .mock
    )
    .withMockEnvironment()
}
