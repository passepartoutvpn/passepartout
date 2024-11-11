//
//  Profile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/22.
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

enum VPNProtocolType: Codable {
    case openVPN

    case wireGuard
}

protocol VPNProtocolProviding {
    var vpnProtocol: VPNProtocolType { get }
}

protocol ProfileSubtype {
    var vpnProtocols: [VPNProtocolType] { get }
}

struct ProfileV2: Identifiable, Codable, Equatable {
    var header: Header

    var currentVPNProtocol: VPNProtocolType

    var networkSettings = NetworkSettings()

    var onDemand = OnDemand()

    var connectionExpirationDate: Date?

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

    init(_ id: UUID = UUID(), name: String, provider: Provider) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: provider.name
        )
        self.init(header, provider: provider)
    }

    init(_ header: Header, provider: Provider) {
        guard let firstVPNProtocol = provider.vpnSettings.keys.first else {
            fatalError("No VPN protocols defined in provider")
        }
        self.header = header
        currentVPNProtocol = firstVPNProtocol
        self.provider = provider
    }

    // MARK: Identifiable

    var id: UUID {
        header.id
    }
}

extension ProfileV2 {
    static let placeholder = ProfileV2(
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        name: ""
    )

    static func isPlaceholder(_ id: UUID) -> Bool {
        id == placeholder.id
    }

    var isPlaceholder: Bool {
        header.id == Self.placeholder.id
    }
}

extension ProfileV2 {
    var isExpired: Bool {
        guard let connectionExpirationDate else {
            return false
        }
        return Date().distance(to: connectionExpirationDate) <= .zero
    }
}
