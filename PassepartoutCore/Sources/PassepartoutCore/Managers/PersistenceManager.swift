//
//  PersistenceManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

public class PersistenceManager {
    private let author: String?
    
    public init(author: String?) {
        self.author = author
    }

    public func profilesPersistence(withName containerName: String) -> Persistence {
        let model = PassepartoutDataModels.profiles
        return Persistence(withCloudKitName: containerName, model: model, author: author)
    }
    
    public func providersPersistence(withName containerName: String) -> Persistence {
        let model = PassepartoutDataModels.providers
        return Persistence(withLocalName: containerName, model: model, author: author)
    }
}
