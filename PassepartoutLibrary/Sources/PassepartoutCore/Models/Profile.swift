//
//  Profile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/22.
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

import Foundation
import TunnelKitOpenVPN
import TunnelKitWireGuard

public protocol ProfileSubtype {
    var vpnProtocols: [VPNProtocolType] { get }
}

public struct Profile: Identifiable, Codable, Equatable {
    public var header: Header

    public var currentVPNProtocol: VPNProtocolType

    public var networkSettings = Profile.NetworkSettings()

    public var onDemand = Profile.OnDemand()

    var host: Host?

    var provider: Provider?

    init(_ header: Header) {
        self.header = header
        currentVPNProtocol = .openVPN
    }

    init(_ id: UUID = UUID(), name: String) {
        header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        currentVPNProtocol = .openVPN
    }

    init(_ id: UUID = UUID(), name: String, configuration: OpenVPN.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ id: UUID = UUID(), name: String, configuration: WireGuard.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ id: UUID = UUID(), name: String, provider: Profile.Provider) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: provider.name
        )
        self.init(header, provider: provider)
    }

    public init(_ header: Header, configuration: OpenVPN.Configuration) {
        self.header = header
        currentVPNProtocol = .openVPN
        host = Host()
        host?.ovpnSettings = OpenVPNSettings(configuration: configuration)
    }

    public init(_ header: Header, configuration: WireGuard.Configuration) {
        self.header = header
        currentVPNProtocol = .wireGuard
        host = Host()
        host?.wgSettings = WireGuardSettings(configuration: configuration)
    }

    public init(_ header: Header, provider: Profile.Provider) {
        guard let firstVPNProtocol = provider.vpnSettings.keys.first else {
            fatalError("No VPN protocols defined in provider")
        }
        self.header = header
        currentVPNProtocol = firstVPNProtocol
        self.provider = provider
    }

    // MARK: Identifiable

    public var id: UUID {
        header.id
    }
}

extension Profile {
    public static let placeholder = Profile(
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        name: ""
    )

    public static func isPlaceholder(_ id: UUID) -> Bool {
        id == placeholder.id
    }

    public var isPlaceholder: Bool {
        header.id == Self.placeholder.id
    }
}
