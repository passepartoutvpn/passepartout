// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

enum VPNProtocolType: String, RawRepresentable, Codable {
    case openVPN = "ovpn"

    case wireGuard = "wg"
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
