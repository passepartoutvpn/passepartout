//
//  ConnectionStatusView.swift
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

import Foundation
import PassepartoutKit
import SwiftUI

struct ConnectionStatusView: View, TunnelContextProviding, ThemeProviding {

    @EnvironmentObject
    var theme: Theme

    @EnvironmentObject
    var connectionObserver: ConnectionObserver

    @ObservedObject
    var tunnel: Tunnel

    var body: some View {
        Text(statusDescription)
            .foregroundStyle(tunnelStatusColor)
    }
}

private extension ConnectionStatusView {
    var statusDescription: String {
        if let lastErrorCode = connectionObserver.lastErrorCode {
            return lastErrorCode.localizedDescription
        }
        let status = tunnelConnectionStatus
        switch status {
        case .active:
            if let dataCount = connectionObserver.dataCount {
                let down = dataCount.received.descriptionAsDataUnit
                let up = dataCount.sent.descriptionAsDataUnit
                return "↓\(down) ↑\(up)"
            }

        case .inactive:
            var desc = status.localizedDescription
            if tunnel.currentProfile?.onDemand ?? false {
                desc += Strings.Ui.ConnectionStatus.onDemandSuffix
            }
            return desc

        default:
            break
        }
        return status.localizedDescription
    }
}

#Preview("Connected") {
    ConnectionStatusView(tunnel: .mock)
        .task {
            try? await Tunnel.mock.connect(with: .mock, processor: .mock)
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
    return ConnectionStatusView(tunnel: .mock)
        .task {
            try? await Tunnel.mock.connect(with: profile, processor: .mock)
        }
        .frame(width: 100, height: 100)
        .withMockEnvironment()
}
