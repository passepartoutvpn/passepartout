//
//  AppUI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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
import NetworkExtension
import PassepartoutKit

public enum AppUI {
    public static func configure(with context: AppContext) {
        assertMissingModuleImplementations()
        migrateBadKeychainEntries()
    }
}

private extension AppUI {
    static func assertMissingModuleImplementations() {
        ModuleType.allCases.forEach { moduleType in
            let module = moduleType.newModule()
            guard module is ModuleTypeProviding else {
                fatalError("\(moduleType): is not ModuleTypeProviding")
            }
            guard module is any ModuleViewProviding else {
                fatalError("\(moduleType): is not ModuleViewProviding")
            }
        }
    }

    static func migrateBadKeychainEntries() {
        Task {
            let teamId = BundleConfiguration.mainString(for: .teamId)
            let keychainGroupId = BundleConfiguration.mainString(for: .keychainGroupId)
            let keychain = AppleKeychain(group: keychainGroupId)
            let badKeychainGroupId = "\(teamId).\(keychainGroupId)"
            let badKeychain = AppleKeychain(group: badKeychainGroupId)

            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            for m in managers {
                guard let badReference = m.protocolConfiguration?.passwordReference else {
                    return
                }
                guard let profileIdString = (m.protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration?["CustomProviderKey.profileId"] as? String,
                      let profileId = UUID(rawValue: profileIdString) else {
                    return
                }
                do {
                    let newLabel = "Passepartout: \(m.localizedDescription ?? "")"
                    let badPassword = try badKeychain.password(forReference: badReference)
                    let newReference = try keychain.set(password: badPassword, for: profileIdString, context: "", label: newLabel)

                    m.protocolConfiguration?.passwordReference = newReference
                    try await m.saveToPreferences()
                    badKeychain.removePassword(forReference: badReference)

                    pp_log(.app, .info, "Migrated bad keychain item for \(profileId)")
                } catch {
                    pp_log(.app, .error, "Unable to migrate bad keychain item for \(profileId): \(error)")
                }
            }
        }
    }

    static func cleanUpOrphanedKeychainEntries() {
    }
}
