//
//  ProfileManager+Testing.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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

extension ProfileManager {
    public static func forUITesting(withRegistry registry: Registry, processor: ProfileProcessor) -> ProfileManager {
        let repository = InMemoryProfileRepository()
        let remoteRepository = InMemoryProfileRepository()
        let manager = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        }, processor: processor)

        Task {
            do {
                try await manager.observeLocal()
                try await manager.observeRemote(true)

                for parameters in mockParameters {
                    var builder = Profile.Builder()
                    builder.name = parameters.name
                    builder.attributes.isAvailableForTV = parameters.isTV

                    for moduleType in parameters.moduleTypes {
                        var moduleBuilder = moduleType.newModule(with: registry, providerId: parameters.providerId)

                        if moduleBuilder.buildsConnectionModule {
                            assert((moduleBuilder as? any ProviderSelecting)?.providerId == parameters.providerId)
                        }

                        if parameters.name == "Hide.me",
                           var ovpnBuilder = moduleBuilder as? OpenVPNModule.Builder {
                            ovpnBuilder.isInteractive = true
                            moduleBuilder = ovpnBuilder
                        }

                        let module = try moduleBuilder.tryBuild()
                        builder.modules.append(module)
                    }
                    builder.activateAllModules()

                    let profile = try builder.tryBuild()
                    try await manager.save(profile, isLocal: true, remotelyShared: parameters.isShared)
                }
            } catch {
                pp_log(.App.profiles, .error, "Unable to build ProfileManager for UI testing: \(error)")
            }
        }

        return manager
    }
}

private extension ProfileManager {
    struct Parameters {
        let name: String

        let isShared: Bool

        let isTV: Bool

        let moduleTypes: [ModuleType]

        let providerId: ProviderID?

        init(_ name: String, _ isShared: Bool, _ isTV: Bool, _ moduleTypes: [ModuleType], _ providerId: ProviderID? = nil) {
            self.name = name
            self.isShared = isShared
            self.isTV = isTV
            self.moduleTypes = moduleTypes
            self.providerId = providerId
        }
    }

    static let mockParameters: [Parameters] = [
        Parameters("CloudFlare DoT", false, false, [.dns]),
        Parameters("Coffee VPN", true, false, [.wireGuard, .onDemand]),
        Parameters("Hide.me", true, true, [.openVPN, .onDemand, .ip], .hideme),
        Parameters("My VPS", true, true, [.openVPN]),
        Parameters("Office", true, false, [.onDemand, .httpProxy]),
        Parameters("Personal DoH", false, false, [.dns, .onDemand])
    ]
}
