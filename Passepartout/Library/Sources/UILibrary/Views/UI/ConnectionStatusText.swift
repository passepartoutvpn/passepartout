//
//  ConnectionStatusText.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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
import Foundation
import PassepartoutKit
import SwiftUI

public struct ConnectionStatusText: View, ThemeProviding {

    @EnvironmentObject
    public var theme: Theme

    @ObservedObject
    private var tunnel: ExtendedTunnel

    public init(tunnel: ExtendedTunnel) {
        self.tunnel = tunnel
    }

    public var body: some View {
        Text(statusDescription)
    }
}

private extension ConnectionStatusText {
    var statusDescription: String {
        if let lastErrorCode = tunnel.lastErrorCode {
            return lastErrorCode.localizedDescription(style: .tunnel)
        }
        let status = tunnel.connectionStatus
        switch status {
        case .active:
            if let dataCount = tunnel.dataCount {
                let down = dataCount.received.descriptionAsDataUnit
                let up = dataCount.sent.descriptionAsDataUnit
                return "↓\(down) ↑\(up)"
            }

        case .inactive:
            var desc = status.localizedDescription
            if let profile = tunnel.currentProfile {
                if profile.onDemand {
                    desc += Strings.Views.Ui.ConnectionStatus.onDemandSuffix
                }
            }
            return desc

        default:
            break
        }
        return status.localizedDescription
    }
}

#Preview("Connected") {
    ConnectionStatusText(tunnel: .mock)
        .task {
            try? await ExtendedTunnel.mock.connect(with: .mock)
        }
        .frame(width: 100, height: 100)
        .withMockEnvironment()
}

#Preview("On-Demand") {
    var builder = Profile.Builder()
    var onDemand = OnDemandModule.Builder()
    onDemand.isEnabled = true
    builder.modules = [onDemand.tryBuild()]
    let profile: Profile
    do {
        profile = try builder.tryBuild()
    } catch {
        fatalError()
    }
    return ConnectionStatusText(tunnel: .mock)
        .task {
            try? await ExtendedTunnel.mock.connect(with: profile)
        }
        .frame(width: 100, height: 100)
        .withMockEnvironment()
}
