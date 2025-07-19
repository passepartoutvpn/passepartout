//
//  DiagnosticsProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/20/25.
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
import SwiftUI

public struct DiagnosticsProfileView: View {

    @ObservedObject
    private var tunnel: ExtendedTunnel

    public let profile: Profile

    public init(tunnel: ExtendedTunnel, profile: Profile) {
        self.tunnel = tunnel
        self.profile = profile
    }

    public var body: some View {
        Form {
            openVPNSection
        }
        .themeForm()
        .themeEmpty(if: isEmpty, message: Strings.Global.Nouns.noContent)
        .navigationTitle(profile.name)
    }
}

private extension DiagnosticsProfileView {
    var openVPNSection: some View {
        tunnel.value(
            forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration,
            ofProfileId: profile.id
        )
        .map { cfg in
            Group {
                NavigationLink(Strings.Views.Diagnostics.Openvpn.Rows.serverConfiguration) {
                    OpenVPNView(serverConfiguration: cfg)
                        .navigationTitle(Strings.Views.Diagnostics.Openvpn.Rows.serverConfiguration)
                }
            }
            .themeSection(header: Strings.Unlocalized.openVPN)
        }
    }
}

private extension DiagnosticsProfileView {
    var isEmpty: Bool {
        [
            tunnel.value(forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration, ofProfileId: profile.id)
        ]
            .filter {
                $0 != nil
            }
            .isEmpty
    }
}

#Preview {
    DiagnosticsProfileView(tunnel: .forPreviews, profile: .forPreviews)
        .withMockEnvironment()
}
