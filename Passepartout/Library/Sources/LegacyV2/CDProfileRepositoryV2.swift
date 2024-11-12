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

    // FIXME: #642, migrate profiles properly
    func migratedProfiles() async throws -> [Profile] {
        try await context.perform { [weak self] in
            guard let self else {
                return []
            }
            do {
                let request = CDProfile.fetchRequest()
                let existing = try context.fetch(request)
                var decoded: [ProfileV2] = []
                let decoder = JSONDecoder()
                existing.forEach {
                    guard let json = $0.encryptedJSON ?? $0.json,
                          let string = String(data: json, encoding: .utf8) else {
                        return
                    }
                    print(">>> \(string)")
                    do {
                        let profile = try decoder.decode(ProfileV2.self, from: json)
                        decoded.append(profile)
                    } catch {
                        print(">>> failed: \(error)")
                    }
                }
                return decoded
            } catch {
                throw error
            }
        }
    }
}
