//
//  ServerRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/22.
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
import CoreData
import PassepartoutCore
import PassepartoutServices
import PassepartoutUtils

class ServerRepository: Repository {
    private let context: NSManagedObjectContext

    required init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func categories(forProviderWithName name: ProviderName, vpnProtocol: VPNProtocolType) -> [ProviderCategory] {
        let request = CDInfrastructureCategory.fetchRequest()
        request.predicate = NSPredicate(
            format: "infrastructure.provider.name == %@ AND infrastructure.vpnProtocol == %@",
            name,
            vpnProtocol.rawValue
        )
        request.relationshipKeyPathsForPrefetching = [
            "infrastructure",
            "infrastructure.provider",
            "locations",
            "locations.servers",
            "presets"
        ]
        do {
            let categoryDTOs = try context.fetch(request)
            return categoryDTOs.compactMap(CategoryMapper.toModel)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return []
        }
    }

    func servers(forLocation location: ProviderLocation) -> [ProviderServer] {
        let request = CDInfrastructureServer.fetchRequest()
        request.predicate = NSPredicate(
            format: "category.infrastructure.provider.name == %@ AND category.name == %@ AND category.infrastructure.vpnProtocol == %@ AND countryCode == %@",
            location.providerMetadata.name,
            location.categoryName,
            location.vpnProtocol.rawValue,
            location.countryCode
        )
        request.relationshipKeyPathsForPrefetching = [
            "category",
            "category.infrastructure",
            "category.infrastructure.provider",
            "category.presets"
        ]
        do {
            let serverDTOs = try context.fetch(request)

            // just preset ids, no full ProviderServer.Preset
            return serverDTOs.compactMap(ServerMapper.toModel)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return []
        }
    }

    func server(forProviderWithName providerName: ProviderName, vpnProtocol: VPNProtocolType, apiId: String) -> ProviderServer? {
        let request = CDInfrastructureServer.fetchRequest()
        request.predicate = NSPredicate(
            format: "apiId == %@ AND category.infrastructure.provider.name == %@ AND category.infrastructure.vpnProtocol == %@",
            apiId,
            providerName,
            vpnProtocol.rawValue
        )
        request.relationshipKeyPathsForPrefetching = [
            "category",
            "category.infrastructure",
            "category.infrastructure.provider",
            "category.presets"
        ]
        do {
            guard let serverDTO = try context.fetch(request).first else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            return ServerMapper.toModelWithPresets(serverDTO)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }

    func anyServer(forProviderWithName providerName: ProviderName, vpnProtocol: VPNProtocolType, countryCode: String) -> ProviderServer? {
        let request = CDInfrastructureServer.fetchRequest()
        request.predicate = NSPredicate(
            format: "countryCode == %@ AND category.infrastructure.provider.name == %@ AND category.infrastructure.vpnProtocol == %@",
            countryCode,
            providerName,
            vpnProtocol.rawValue
        )
        request.relationshipKeyPathsForPrefetching = [
            "category",
            "category.infrastructure",
            "category.infrastructure.provider",
            "category.presets"
        ]
        do {
            try Utils.randomizeFetchResults(request, in: context)
            guard let serverDTO = try context.fetch(request).first else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            return ServerMapper.toModelWithPresets(serverDTO)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }

    func anyDefaultServer(forProviderWithName providerName: ProviderName, vpnProtocol: VPNProtocolType) -> ProviderServer? {
        let request = CDInfrastructureServer.fetchRequest()
        request.predicate = NSPredicate(
            format: "countryCode == category.infrastructure.defaults.countryCode AND category.infrastructure.provider.name == %@ AND category.infrastructure.vpnProtocol == %@",
            providerName,
            vpnProtocol.rawValue
        )
        request.relationshipKeyPathsForPrefetching = [
            "category",
            "category.infrastructure",
            "category.infrastructure.provider",
            "category.infrastructure.defaults",
            "category.presets"
        ]
        do {
            try Utils.randomizeFetchResults(request, in: context)
            guard let serverDTO = try context.fetch(request).first else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            return ServerMapper.toModelWithPresets(serverDTO)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }

    func server(withId id: String) -> ProviderServer? {
        let request = CDInfrastructureServer.fetchRequest()
        request.predicate = NSPredicate(
            format: "uniqueId == %@",
            id
        )
        request.relationshipKeyPathsForPrefetching = [
            "category",
            "category.infrastructure",
            "category.presets"
        ]
        do {
            guard let serverDTO = try context.fetch(request).first else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            return ServerMapper.toModelWithPresets(serverDTO)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }
}
