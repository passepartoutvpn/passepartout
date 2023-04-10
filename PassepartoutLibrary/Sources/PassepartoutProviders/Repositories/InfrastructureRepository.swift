//
//  InfrastructureRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/16/22.
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

class InfrastructureRepository: Repository {
    private let context: NSManagedObjectContext

    required init(_ context: NSManagedObjectContext) {
        self.context = context
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

    func defaultUsername(forProviderWithName name: ProviderName, vpnProtocol: VPNProtocolType) -> String? {
        let request = fetchRequest(name, vpnProtocol)
        request.sortDescriptors = [
            .init(keyPath: \CDInfrastructure.lastUpdate, ascending: false)
        ]
        request.relationshipKeyPathsForPrefetching = [
            "defaults"
        ]
        do {
            guard let infrastructureDTO = try context.fetch(request).first else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            return infrastructureDTO.defaults?.usernamePlaceholder
        } catch {
            Utils.logFetchError(#file, #function, #line, error)
            return nil
        }
    }

    func lastInfrastructureUpdate(withName name: ProviderName, vpnProtocol: VPNProtocolType) -> Date? {
        let request = fetchRequest(name, vpnProtocol)
        request.sortDescriptors = [
            .init(keyPath: \CDInfrastructure.lastUpdate, ascending: false)
        ]
        request.relationshipKeyPathsForPrefetching = [
            "provider",
            "provider.infrastructures"
        ]
        do {
            let infrastructures = try context.fetch(request)
            guard !infrastructures.isEmpty else {
                Utils.logFetchNotFound(#file, #function, #line)
                return nil
            }
            let recent = infrastructures.first!
            return recent.lastUpdate
        } catch {
            context.rollback()
            Utils.logFetchError(#file, #function, #line, error)
            return nil
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
