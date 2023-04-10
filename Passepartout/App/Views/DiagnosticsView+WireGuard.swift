//
//  DiagnosticsView+WireGuard.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/11/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import SwiftUI
import PassepartoutLibrary
import TunnelKitWireGuard

extension DiagnosticsView {
    struct WireGuardView: View {
        @ObservedObject private var vpnManager: VPNManager

        private let providerName: ProviderName?

        init(providerName: ProviderName?) {
            vpnManager = .shared
            self.providerName = providerName
        }

        var body: some View {
            List {
                Section {
                    DebugLogSection(appLogURL: appLogURL, tunnelLogURL: tunnelLogURL)
                } header: {
                    Text(L10n.DebugLog.title)
                }
            }
        }
    }
}

extension DiagnosticsView.WireGuardView {
    private var appLogURL: URL? {
        LogManager.shared.logFile
    }

    private var tunnelLogURL: URL? {
        vpnManager.debugLogURL(forProtocol: .wireGuard)
    }
}
