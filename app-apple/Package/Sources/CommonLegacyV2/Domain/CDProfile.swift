// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CoreData
import Foundation

@objc(CDProfile)
final class CDProfile: NSManagedObject {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDProfile> {
        NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged var json: Data?
    @NSManaged var encryptedJSON: Data?
    @NSManaged var name: String?
    @NSManaged var providerName: String?
    @NSManaged var uuid: UUID?
    @NSManaged var lastUpdate: Date?
}
