//
//  KeychainSecretRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/23/23.
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
import PassepartoutCore
import PassepartoutVPN
import TunnelKitManager

public final class KeychainSecretRepository: SecretRepository {
    private let appGroup: String

    private let keychain: Keychain

    public init(appGroup: String) {
        guard UserDefaults(suiteName: appGroup) != nil else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        self.appGroup = appGroup
        keychain = Keychain(group: appGroup)
    }

    public func set(password: String, for entry: String, userDefined: String, label: String) throws {
        try keychain.set(password: password, for: entry, context: appGroup, userDefined: userDefined, label: label)
    }

    public func removePassword(for entry: String, userDefined: String) {
        keychain.removePassword(for: entry, context: appGroup, userDefined: userDefined)
    }

    public func passwordReference(for entry: String, userDefined: String) throws -> Data {
        try keychain.passwordReference(for: entry, context: appGroup, userDefined: userDefined)
    }
}

extension KeychainSecretRepository {
    public func debugAllPasswords(matching id: UUID) {
        var query = allPasswordsQuery(id, appGroup)
        query[kSecReturnAttributes as String] = true

        var list: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &list) {
        case errSecSuccess:
            break

        default:
            return
        }
        guard let list = list else {
            pp_log.verbose("Keychain items: none")
            return
        }
        pp_log.verbose("Keychain items: \(list)")
    }

    public func removeAllPasswords(matching id: UUID) {
        _ = SecItemDelete(allPasswordsQuery(id, appGroup) as CFDictionary)
    }

    private func allPasswordsQuery(_ id: UUID, _ context: String) -> [String: Any] {
        var query = [String: Any]()
        keychain.setScope(query: &query, context: context, userDefined: id.uuidString)
        query[kSecClass as String] = kSecClassGenericPassword
        return query
    }
}
