//
//  ProfileManager+Keychain.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/8/22.
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
import TunnelKitManager
import PassepartoutCore
import PassepartoutUtils

extension ProfileManager {
    public func savePassword(forProfile profile: Profile, newPassword: String? = nil) {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return
        }
        guard let keychainEntry = profile.keychainEntry else {
            return
        }
        let password = newPassword ?? profile.account.password
        guard !password.isEmpty else {
            keychain.removePassword(
                for: keychainEntry,
                context: appGroup,
                userDefined: profile.id.uuidString
            )
            return
        }
        do {
            try keychain.set(
                password: password,
                for: keychainEntry,
                context: appGroup,
                userDefined: profile.id.uuidString,
                label: keychainLabel(profile.header.name, profile.currentVPNProtocol)
            )
        } catch {
            pp_log.error("Unable to save password to keychain: \(error)")
        }
    }

    public func passwordReference(forProfile profile: Profile) -> Data? {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return nil
        }
        guard let keychainEntry = profile.keychainEntry else {
            return nil
        }
        do {
            return try keychain.passwordReference(
                for: keychainEntry,
                context: appGroup,
                userDefined: profile.id.uuidString
            )
        } catch {
            pp_log.debug("Unable to load password reference from keychain: \(error)")
            return nil
        }
    }
}

private extension Profile {
    var keychainEntry: String? {
        "\(id.uuidString):\(currentVPNProtocol.description):\(account.username)"
    }
}

extension Keychain {
    func debugAllPasswords(matching id: UUID, context: String) {
        var query = allPasswordsQuery(id, context)
        query[kSecReturnAttributes as String] = true

        var list: CFTypeRef?
        switch SecItemCopyMatching(query as CFDictionary, &list) {
        case errSecSuccess:
            break

        default:
            return
        }
        guard let list = list else {
            pp_log.debug("Keychain items: none")
            return
        }
        pp_log.debug("Keychain items: \(list)")
    }

    func removeAllPasswords(matching id: UUID, context: String) {
        _ = SecItemDelete(allPasswordsQuery(id, context) as CFDictionary)
    }

    private func allPasswordsQuery(_ id: UUID, _ context: String) -> [String: Any] {
        var query = [String: Any]()
        setScope(query: &query, context: context, userDefined: id.uuidString)
        query[kSecClass as String] = kSecClassGenericPassword
        return query
    }
}
