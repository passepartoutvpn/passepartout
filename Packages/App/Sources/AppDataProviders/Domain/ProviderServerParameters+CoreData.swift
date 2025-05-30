//
//  ProviderServerParameters+CoreData.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

extension ProviderID {
    var predicate: NSPredicate {
        NSPredicate(format: predicateFormat, predicateArg)
    }

    fileprivate var predicateFormat: String {
        "providerId == %@"
    }

    fileprivate var predicateArg: String {
        rawValue
    }
}

extension ProviderSortField {
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .localizedCountry:
            return NSSortDescriptor(key: "localizedCountry", ascending: true)

        case .area:
            return NSSortDescriptor(key: "area", ascending: true)

        case .serverId:
            return NSSortDescriptor(key: "serverId", ascending: true)

        @unknown default:
            return NSSortDescriptor()
        }
    }
}

extension ProviderFilters {
    func predicate(for providerId: ProviderID) -> NSPredicate {
        var formats: [String] = []
        var args: [Any] = []

        formats.append(providerId.predicateFormat)
        args.append(providerId.rawValue)

        if let moduleType {
            formats.append("supportedModuleTypes contains %@")
            args.append(moduleType.rawValue)
        }
        if let presetId {
            formats.append("(supportedPresetIds == NULL OR supportedPresetIds contains %@)")
            args.append(presetId)
        }
        if let categoryName {
            formats.append("categoryName == %@")
            args.append(categoryName)
        }
        if let countryCode {
            formats.append("countryCode == %@")
            args.append(countryCode)
        }
        if let area {
            formats.append("area == %@")
            args.append(area)
        }

        let format = formats.joined(separator: " AND ")
        return NSPredicate(format: format, argumentArray: args)
    }
}
