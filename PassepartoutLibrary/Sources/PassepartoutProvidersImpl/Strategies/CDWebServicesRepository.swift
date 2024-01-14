//
//  CDWebServicesRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/22/23.
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

import CoreData
import Foundation
import PassepartoutCore
import PassepartoutProviders
import PassepartoutServices

final class CDWebServicesRepository: WebServicesRepository {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
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

    func saveInfrastructure(
        _ infrastructure: WSProviderInfrastructure,
        vpnProtocol: VPNProtocolType,
        lastUpdate: Date
    ) throws {
        do {
            let provider = try providerDTO(forName: infrastructure.name) ?? {
                let provider = CDProvider(context: context)
                provider.name = infrastructure.name
                provider.fullName = infrastructure.fullName
                provider.lastUpdate = Date()
                return provider
            }()

            let request = fetchRequest(infrastructure.name, vpnProtocol)
            let existing = try context.fetch(request)
            existing.forEach(context.delete)

            let dto = InfrastructureMapper(
                context,
                infrastructure.name,
                vpnProtocol
            ).toDTO(infrastructure)
            dto.provider = provider
            dto.lastUpdate = lastUpdate
            provider.addToInfrastructures(dto)

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func fetchRequest(_ name: ProviderName, _ vpnProtocol: VPNProtocolType) -> NSFetchRequest<CDInfrastructure> {
        let request = CDInfrastructure.fetchRequest()
        request.predicate = NSPredicate(
            format: "provider.name == %@ AND vpnProtocol == %@",
            name,
            vpnProtocol.rawValue
        )
        return request
    }

    private func providerDTO(forName name: ProviderName) throws -> CDProvider? {
        let request = CDProvider.fetchRequest()
        request.sortDescriptors = [
            .init(keyPath: \CDProvider.lastUpdate, ascending: false)
        ]
        request.predicate = NSPredicate(
            format: "name == %@",
            name
        )
        return try context.fetch(request).first
    }
}
