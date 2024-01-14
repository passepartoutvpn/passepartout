//
//  DiagnosticsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/20/22.
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

import PassepartoutLibrary
import SwiftUI

struct DiagnosticsView: View {
    let profile: Profile

    var body: some View {
        Group {
            if !profile.isPlaceholder {
                #if !os(tvOS)
                vpnView
                #endif
            } else {
                genericView
            }
        }.navigationTitle(L10n.Diagnostics.title)
    }
}

private extension DiagnosticsView {

    #if !os(tvOS)
    var vpnView: some View {
        Group {
            switch profile.currentVPNProtocol {
            case .openVPN:
                DiagnosticsView.OpenVPNView(
                    providerName: profile.header.providerName
                )

            case .wireGuard:
                DiagnosticsView.WireGuardView(
                    providerName: profile.header.providerName
                )
            }
        }
    }
    #endif

    var genericView: some View {
        List {
            Section {
                DebugLogGroup(
                    appLogURL: Passepartout.shared.logger.logFile,
                    tunnelLogURL: nil
                )
            } header: {
                Text(L10n.DebugLog.title)
            }
        }
    }
}

extension DiagnosticsView {
    struct DebugLogGroup: View {
        let appLogURL: URL?

        let tunnelLogURL: URL?

        private let refreshInterval = Constants.Log.refreshInterval

        var body: some View {
            appLink
            tunnelLink
        }
    }
}

// MARK: -

private extension DiagnosticsView.DebugLogGroup {
    var appLink: some View {
        navigationLink(
            withTitle: L10n.Diagnostics.Items.AppLog.title,
            url: appLogURL,
            filename: Unlocalized.Issues.Filenames.appLog,
            refreshInterval: nil
        )
    }

    var tunnelLink: some View {
        navigationLink(
            withTitle: Unlocalized.VPN.vpn,
            url: tunnelLogURL,
            filename: Unlocalized.Issues.Filenames.tunnelLog,
            refreshInterval: refreshInterval
        )
    }

    func navigationLink(withTitle title: String, url: URL?, filename: String, refreshInterval: TimeInterval?) -> some View {
        NavigationLink(title) {
            url.map {
                DebugLogView(
                    title: title,
                    url: $0,
                    filename: filename,
                    refreshInterval: refreshInterval
                )
            }
        }
        .disabled(url == nil)
    }
}
