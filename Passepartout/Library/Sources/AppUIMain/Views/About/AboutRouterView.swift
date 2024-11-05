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
    var navigationRoute: NavigationRoute?
}

extension AboutRouterView {
    enum NavigationRoute: Hashable {
        case donate

        case diagnostics

        case appDebugLog(title: String)

        case tunnelDebugLog(title: String, url: URL?)

        case links

        case credits
    }

    @ViewBuilder
    func pushDestination(for item: NavigationRoute?) -> some View {
        switch item {
        case .donate:
            DonateView()

        case .diagnostics:
            DiagnosticsView(
                profileManager: profileManager,
                tunnel: tunnel
            )

        case .appDebugLog(let title):
            DebugLogView.withApp(parameters: Constants.shared.log)
                .navigationTitle(title)

        case .tunnelDebugLog(let title, let url):
            if let url {
                DebugLogView.withURL(url)
                    .navigationTitle(title)
            } else {
                DebugLogView.withTunnel(tunnel, parameters: Constants.shared.log)
                    .navigationTitle(title)
            }

        case .links:
            LinksView()

        case .credits:
            CreditsView()

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
