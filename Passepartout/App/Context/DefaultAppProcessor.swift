//
//  DefaultAppProcessor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/6/24.
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
import PassepartoutKit

final class DefaultAppProcessor: Sendable {
    private let apiManager: APIManager

    private let iapManager: IAPManager

    private let registry: Registry

    private let title: @Sendable (Profile) -> String

    init(
        apiManager: APIManager,
        iapManager: IAPManager,
        registry: Registry,
        title: @escaping @Sendable (Profile) -> String
    ) {
        self.apiManager = apiManager
        self.iapManager = iapManager
        self.registry = registry
        self.title = title
    }
}

extension DefaultAppProcessor: ProfileProcessor {
    func isIncluded(_ profile: Profile) -> Bool {
#if os(tvOS)
        profile.attributes.isAvailableForTV == true
#else
        true
#endif
    }

    func preview(from profile: Profile) -> ProfilePreview {
        profile.localizedPreview
    }

    func requiredFeatures(_ profile: Profile) -> Set<AppFeature>? {
        do {
            try iapManager.verify(profile)
            return nil
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            return requiredFeatures
        } catch {
            return nil
        }
    }

    func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        builder
    }
}

extension DefaultAppProcessor: AppTunnelProcessor {
    func title(for profile: Profile) -> String {
        title(profile)
    }

    func willInstall(_ profile: Profile) async throws -> Profile {

        // apply connection heuristic
        var newProfile = profile
        do {
            if let builder = newProfile.activeProviderModule?.moduleBuilder() as? ProviderModule.Builder,
               let heuristic = builder.entity?.heuristic {
                pp_log(.app, .info, "Apply connection heuristic: \(heuristic)")
                newProfile.activeProviderModule?.entity.map {
                    pp_log(.app, .info, "\tOld server: \($0.server)")
                }
                newProfile = try await profile.withNewServer(using: heuristic, apiManager: apiManager)
                newProfile.activeProviderModule?.entity.map {
                    pp_log(.app, .info, "\tNew server: \($0.server)")
                }
            }
        } catch {
            pp_log(.app, .error, "Unable to pick new provider server: \(error)")
        }

        // validate provider modules
        do {
            _ = try newProfile.resolvingProviderModules(with: registry)
            return newProfile
        } catch {
            pp_log(.app, .error, "Unable to inject provider modules: \(error)")
            throw error
        }
    }
}

// MARK: - Heuristics

// FIXME: #1263, these should be implemented in the library

private extension Profile {

    @MainActor
    func withNewServer(using heuristic: ProviderHeuristic, apiManager: APIManager) async throws -> Profile {
        guard var providerModule = activeProviderModule?.moduleBuilder() as? ProviderModule.Builder else {
            return self
        }
        try await providerModule.setRandomServer(using: heuristic, apiManager: apiManager)

        var newBuilder = builder()
        newBuilder.saveModule(try providerModule.tryBuild())
        return try newBuilder.tryBuild()
    }
}

private extension ProviderModule.Builder {

    @MainActor
    mutating func setRandomServer(using heuristic: ProviderHeuristic, apiManager: APIManager) async throws {
        guard let providerId, let providerModuleType, let entity else {
            return
        }
        let repo = try await apiManager.providerRepository(for: providerId)
        let providerManager = ProviderManager()
        try await providerManager.setRepository(repo, for: providerModuleType)

        var filters = ProviderFilters()
        filters.presetId = entity.preset.presetId

        switch heuristic {
        case .exact(let server):
            filters.serverIds = [server.serverId]
        case .sameCountry(let code):
            filters.countryCode = code
        case .sameRegion(let region):
            filters.countryCode = region.countryCode
            filters.area = region.area
        }

        var servers = try await providerManager.filteredServers(with: filters)
        servers.removeAll {
            $0.serverId == entity.server.serverId
        }
        guard let randomServer = servers.randomElement() else {
            return
        }
        self.entity = ProviderEntity(
            server: randomServer,
            preset: entity.preset,
            heuristic: entity.heuristic
        )
    }
}
