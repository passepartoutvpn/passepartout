// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileV2 {
    struct Header: Codable, Identifiable, Hashable {
        let uuid: UUID

        var name: String

        let providerName: ProviderName?

        let lastUpdate: Date?

        init(
            uuid: UUID = UUID(),
            name: String = "",
            providerName: ProviderName? = nil,
            lastUpdate: Date? = nil
        ) {
            self.uuid = uuid
            self.name = name
            self.providerName = providerName
            self.lastUpdate = lastUpdate ?? Date()
        }

        // MARK: Hashable

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.uuid == rhs.uuid &&
            lhs.name == rhs.name &&
            lhs.providerName == rhs.providerName
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
            hasher.combine(name)
            hasher.combine(providerName)
        }

        // MARK: Identifiable

        var id: UUID {
            uuid
        }
    }
}
