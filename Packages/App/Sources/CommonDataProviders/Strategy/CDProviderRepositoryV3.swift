//
//  CDProviderRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/26/24.
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

import CommonData
import CommonLibrary
import CommonUtils
import CoreData
import Foundation

final class CDProviderRepositoryV3: ProviderRepository {
    private let context: NSManagedObjectContext

    let providerId: ProviderID

    init(context: NSManagedObjectContext, providerId: ProviderID) {
        self.context = context
        self.providerId = providerId
    }

    func availableOptions(for moduleType: ModuleType) async throws -> ProviderFilterOptions {
        try await context.perform {
            let mapper = DomainMapper()

            let serversRequest = NSFetchRequest<NSDictionary>(entityName: "CDProviderServerV3")
            serversRequest.predicate = self.providerId.predicate
            serversRequest.resultType = .dictionaryResultType
            serversRequest.returnsDistinctResults = true
            serversRequest.propertiesToFetch = [
                "categoryName",
                "countryCode"
            ]
            let serversResults = try serversRequest.execute()

            var countriesByCategoryName: [String: Set<String>] = [:]
            var countryCodes: Set<String> = []
            serversResults.forEach {
                guard let categoryName = $0.object(forKey: "categoryName") as? String,
                      let countryCode = $0.object(forKey: "countryCode") as? String else {
                    return
                }
                var codes: Set<String> = countriesByCategoryName[categoryName] ?? []
                codes.insert(countryCode)
                countriesByCategoryName[categoryName] = codes
                countryCodes.insert(countryCode)
            }

            let presetsRequest = CDProviderPresetV3.fetchRequest()
            presetsRequest.predicate = NSPredicate(
                format: "providerId == %@ AND moduleType == %@",
                self.providerId.rawValue,
                moduleType.rawValue
            )
            let presetsResults = try presetsRequest.execute()

            return ProviderFilterOptions(
                countriesByCategoryName: countriesByCategoryName,
                countryCodes: Set(countryCodes),
                presets: Set(try presetsResults.compactMap {
                    try mapper.preset(from: $0)
                })
            )
        }
    }

    func filteredServers(with parameters: ProviderServerParameters?) async throws -> [ProviderServer] {
        try await context.perform {
            let request = CDProviderServerV3.fetchRequest()
            request.sortDescriptors = parameters?.sorting.map(\.sortDescriptor)
            request.predicate = parameters?.filters.predicate(for: self.providerId)
            let results = try request.execute()
            let mapper = DomainMapper()
            return try results.compactMap(mapper.server(from:))
        }
    }
}
