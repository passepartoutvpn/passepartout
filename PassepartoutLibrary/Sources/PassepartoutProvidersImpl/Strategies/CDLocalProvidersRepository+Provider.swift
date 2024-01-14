//
//  CDLocalProvidersRepository+Provider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/22.
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

extension CDLocalProvidersRepository: ProviderRepository {
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
            Utils.logFetchError(error)
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
                Utils.logFetchNotFound(name)
                return nil
            }
            let recent = providers.first!
            return ProviderMapper.toModel(recent)
        } catch {
            Utils.logFetchError(error)
            return nil
        }
    }
}
