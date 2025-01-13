//
//  CDProfileV3.swift
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

import CoreData
import Foundation

@objc(CDProfileV3)
final class CDProfileV3: NSManagedObject {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDProfileV3> {
        NSFetchRequest<CDProfileV3>(entityName: "CDProfileV3")
    }

    @NSManaged var uuid: UUID?
    @NSManaged var name: String?
    @NSManaged var encoded: String?
    @NSManaged var isAvailableForTV: NSNumber?
    @NSManaged var lastUpdate: Date?
    @NSManaged var fingerprint: UUID?
}
