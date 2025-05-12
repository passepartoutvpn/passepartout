//
//  ConnectionStatusText.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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
import Foundation
import SwiftUI

public struct ConnectionStatusText: View {

    @ObservedObject
    var tunnel: ExtendedTunnel

    let profileId: Profile.ID?

    let withColors: Bool

    public init(tunnel: ExtendedTunnel, profileId: Profile.ID?, withColors: Bool = true) {
        self.tunnel = tunnel
        self.profileId = profileId
        self.withColors = withColors
    }

    public var body: some View {
        if let profileId, tunnel.isActiveProfile(withId: profileId) {
            ConnectionStatusDynamicText(tunnel: tunnel, profileId: profileId, withColors: withColors)
        } else {
            ConnectionStatusStaticText(status: .inactive, color: .secondary)
        }
    }
}

public struct ConnectionStatusStaticText: View {
    private let statusDescription: String

    private let color: Color?

    public init(status: TunnelStatus, color: Color?) {
        statusDescription = status.localizedDescription
        self.color = color
    }

    fileprivate init(statusDescription: String, color: Color?) {
        self.statusDescription = statusDescription
        self.color = color
    }

    public var body: some View {
        Text(statusDescription)
            .foregroundStyle(color ?? .primary)
    }
}

private struct ConnectionStatusDynamicText: View {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    var tunnel: ExtendedTunnel

    let profileId: Profile.ID

    let withColors: Bool

    public var body: some View {
        ConnectionStatusStaticText(
            statusDescription: statusDescription,
            color: withColors ? tunnel.statusColor(ofProfileId: profileId, theme) : nil
        )
    }
}

private extension ConnectionStatusDynamicText {
    var statusDescription: String {
        if let lastErrorCode = tunnel.lastErrorCode(ofProfileId: profileId) {
            return lastErrorCode.localizedDescription(style: .tunnel)
        }
        let status = tunnel.connectionStatus(ofProfileId: profileId)
        switch status {
        case .active:
            if let dataCount = tunnel.dataCount(ofProfileId: profileId) {
                let down = dataCount.received.descriptionAsDataUnit
                let up = dataCount.sent.descriptionAsDataUnit
                return "↓\(down) ↑\(up)"
            }

        case .inactive:
            var desc = status.localizedDescription
            if let profile = tunnel.activeProfiles[profileId], profile.onDemand {
                desc += Strings.Views.Ui.ConnectionStatus.onDemandSuffix
            }
            return desc

        default:
            break
        }
        return status.localizedDescription
    }
}

#Preview("Status (Static)") {
    ConnectionStatusStaticText(status: .deactivating, color: .cyan)
        .frame(width: 400, height: 100)
        .withMockEnvironment()
}

#Preview("Connected (Dynamic)") {
    ConnectionStatusDynamicText(tunnel: .forPreviews, profileId: Profile.forPreviews.id, withColors: true)
        .task {
            try? await ExtendedTunnel.forPreviews.connect(with: .forPreviews)
        }
        .frame(width: 400, height: 100)
        .withMockEnvironment()
}

#Preview("On-Demand (Dynamic)") {
    var builder = Profile.Builder()
    let onDemand = OnDemandModule.Builder()
    builder.modules = [onDemand.tryBuild()]
    builder.activeModulesIds = [onDemand.id]
    let profile: Profile
    do {
        profile = try builder.tryBuild()
    } catch {
        fatalError()
    }
    return ConnectionStatusDynamicText(tunnel: .forPreviews, profileId: profile.id, withColors: true)
        .task {
            try? await ExtendedTunnel.forPreviews.connect(with: profile)
        }
        .frame(width: 400, height: 100)
        .withMockEnvironment()
}
