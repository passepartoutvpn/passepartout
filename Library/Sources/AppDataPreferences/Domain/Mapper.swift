//
//  Mapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/7/24.
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
import CoreData
import Foundation
import PassepartoutKit

struct DomainMapper {
    func excludedEndpoints(from entities: Set<CDExcludedEndpoint>?) -> Set<ExtendedEndpoint> {
        entities.map {
            Set($0.compactMap {
                $0.endpoint.map {
                    ExtendedEndpoint(rawValue: $0)
                } ?? nil
            })
        } ?? []
    }
}

struct CoreDataMapper {
    let context: NSManagedObjectContext

    func cdExcludedEndpoint(from endpoint: ExtendedEndpoint) -> CDExcludedEndpoint {
        let cdEndpoint = CDExcludedEndpoint(context: context)
        cdEndpoint.endpoint = endpoint.rawValue
        return cdEndpoint
    }

    func cdExcludedEndpoints(from endpoints: Set<ExtendedEndpoint>) -> Set<CDExcludedEndpoint> {
        Set(endpoints.map(cdExcludedEndpoint(from:)))
    }
}
