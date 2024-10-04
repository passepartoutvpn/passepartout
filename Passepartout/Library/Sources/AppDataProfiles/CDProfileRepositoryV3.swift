//
//  CDProfileRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/11/24.
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

import AppData
import CoreData
import Foundation
import PassepartoutKit
import UtilsLibrary

extension AppData {
    public static func cdProfileRepositoryV3(
        registry: Registry,
        coder: ProfileCoder,
        context: NSManagedObjectContext,
        onResultError: ((Error) -> CoreDataResultAction)?
    ) -> any ProfileRepository {
        let repository = CoreDataRepository<CDProfileV3, Profile>(context: context) {
            $0.sortDescriptors = [
                .init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare)),
                .init(key: "lastUpdate", ascending: true)
            ]
        } fromMapper: {
            guard let encoded = $0.encoded else {
                return nil
            }
            return try registry.decodedProfile(from: encoded, with: coder)
        } toMapper: {
            let encoded = try registry.encodedProfile($0, with: coder)

            let cdProfile = CDProfileV3(context: $1)
            cdProfile.uuid = $0.id
            cdProfile.name = $0.name
            cdProfile.encoded = encoded
            cdProfile.lastUpdate = Date()
            return cdProfile
        } onResultError: {
            onResultError?($0) ?? .ignore
        }

        return repository
    }
}

extension CDProfileV3: CoreDataUniqueEntity {
}

extension CoreDataRepository: ProfileRepository where T == Profile {
}
