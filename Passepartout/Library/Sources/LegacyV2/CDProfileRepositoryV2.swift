//
//  CDProfileRepositoryV2.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/1/24.
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

final class CDProfileRepositoryV2 {
    static var model: NSManagedObjectModel {
        guard let model: NSManagedObjectModel = .mergedModel(from: [.module]) else {
            fatalError("Unable to build Core Data model (Profiles v2)")
        }
        return model
    }

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func profiles() async throws -> [ProfileV2] {
        try await context.perform { [weak self] in
            guard let self else {
                return []
            }
            let request = CDProfile.fetchRequest()
            request.sortDescriptors = [
                .init(key: "lastUpdate", ascending: false)
            ]

            let existing = try context.fetch(request)
            var decoded: [UUID: ProfileV2] = [:]
            let decoder = JSONDecoder()
            existing.forEach {
                guard let uuid = $0.uuid else {
                    return
                }
                guard !decoded.keys.contains(uuid) else {
                    pp_log(.App.migration, .info, "Skip older duplicate of profile \(uuid)")
                    return
                }
                guard let json = $0.encryptedJSON ?? $0.json else {
                    pp_log(.App.migration, .error, "Unable to migrate profile \(uuid) with name '\($0.name ?? "")': missing JSON")
                    return
                }
                do {
                    let profile = try decoder.decode(ProfileV2.self, from: json)
                    decoded[profile.id] = profile
                } catch {
                    pp_log(.App.migration, .error, "Unable to migrate profile \(uuid) with name '\($0.name ?? "")': \(error)")
                }
            }
            return Array(decoded.values)
        }
    }
}
