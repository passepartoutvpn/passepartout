//
//  ProfileMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/18/22.
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
import PassepartoutUtils

struct ProfileMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: Profile) throws -> CDProfile {
        let profile = ProfileHeaderMapper(context).toDTO(ws)
        do {
            profile.json = try JSONEncoder().encode(ws)
        } catch {
            assertionFailure("Unable to encode profile: \(error)")
            throw error
        }
        return profile
    }

    static func toModel(_ dto: CDProfile) throws -> Profile? {
        guard let json = dto.json else {
            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }
        do {
            return try JSONDecoder().decode(Profile.self, from: json)
        } catch {
            assertionFailure("Unable to decode profile: \(error)")
            throw error
        }
    }
}

struct ProfileHeaderMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: Profile) -> CDProfile {
        let profile = CDProfile(context: context)
        profile.uuid = ws.header.id
        profile.name = ws.header.name
        profile.providerName = ws.header.providerName
        profile.lastUpdate = Date()
        return profile
    }

    static func toModel(_ dto: CDProfile) -> Profile.Header? {
        guard let uuid = dto.uuid,
              let name = dto.name else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }
        return Profile.Header(
            uuid: uuid,
            name: name,
            providerName: dto.providerName,
            lastUpdate: dto.lastUpdate
        )
    }
}
