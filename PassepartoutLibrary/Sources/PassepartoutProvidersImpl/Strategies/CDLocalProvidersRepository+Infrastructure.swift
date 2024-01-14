//
//  CDLocalProvidersRepository+Infrastructure.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/16/22.
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

extension CDLocalProvidersRepository: InfrastructureRepository {
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
                Utils.logFetchNotFound("\(name), \(vpnProtocol)")
                return nil
            }
            return infrastructureDTO.defaults?.usernamePlaceholder
        } catch {
            Utils.logFetchError(error)
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
                Utils.logFetchNotFound("\(name), \(vpnProtocol)")
                return nil
            }
            let recent = infrastructures.first!
            return recent.lastUpdate
        } catch {
            context.rollback()
            Utils.logFetchError(error)
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
}
