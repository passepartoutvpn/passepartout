//
//  ProviderRepository.swift
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

class ProviderRepository: Repository {
    private let context: NSManagedObjectContext

    required init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func allProviders() -> [ProviderMetadata] {
        let request = CDProvider.fetchRequest()
        request.sortDescriptors = [
            .init(keyPath: \CDProvider.name, ascending: true),
            .init(keyPath: \CDProvider.lastUpdate, ascending: false)
        ]
        request.relationshipKeyPathsForPrefetching = [
            "infrastructures"
        ]
        do {
            let providers = try context.fetch(request)
            guard !providers.isEmpty else {
                return []
            }
            return providers.compactMap(ProviderMapper.toModel)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return []
        }
    }

    func provider(withName name: ProviderName) -> ProviderMetadata? {
        let request = CDProvider.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.sortDescriptors = [
            .init(keyPath: \CDProvider.lastUpdate, ascending: false)
        ]
        request.relationshipKeyPathsForPrefetching = [
            "infrastructures"
        ]
        do {
            let providers = try context.fetch(request)
            guard !providers.isEmpty else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            let recent = providers.first!
            return ProviderMapper.toModel(recent)
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }

    func mergeIndex(_ index: WSProvidersIndex) throws {
        let request = CDProvider.fetchRequest()
        request.propertiesToFetch = [
            "name",
            "fullName"
        ]
        do {
            let providers = try context.fetch(request)

            let indexNames = index.metadata.map(\.name)
            let existingNames = providers.compactMap(\.name)
            pp_log.debug("Fetched providers: \(indexNames)")
            pp_log.debug("Existing providers: \(existingNames)")

            let newNames = Set(indexNames).subtracting(existingNames)
            pp_log.info("New providers: \(newNames)")

            // add new
            index.metadata.filter {
                newNames.contains($0.name)
            }.forEach {
                _ = ProviderMapper(context).toDTO($0)
                pp_log.info("Creating new provider metadata: \($0)")
            }

            // update existing
            providers.forEach { dto in
                guard let name = dto.name else {
                    return
                }
                guard let ws = index.metadata.first(where: {
                    $0.name == name
                }) else {
                    // delete if not in new index
                    pp_log.info("Deleting provider: \(name)")
                    context.delete(dto)
                    return
                }
                pp_log.info("Updating provider: \(name)")
                dto.fullName = ws.fullName
                dto.lastUpdate = Date()
            }

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func reassignInfrastructures(from oldProvider: CDProvider, to newProvider: CDProvider) {
        oldProvider.infrastructures?.forEach {
            guard let infra = $0 as? CDInfrastructure else {
                return
            }
            pp_log.debug("Reassigning provider infrastructure: \(infra)")
            oldProvider.removeFromInfrastructures(infra)
            newProvider.addToInfrastructures(infra)
        }
    }
}
