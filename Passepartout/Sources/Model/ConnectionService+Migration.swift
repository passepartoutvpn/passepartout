//
//  ConnectionService+Migration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

public extension ConnectionService {
    static func migrateJSON(from: URL, to: URL) {
        do {
            let newData = try migrateJSON(at: from)
//            log.verbose(String(data: newData, encoding: .utf8)!)
            try newData.write(to: to)
        } catch let e {
            log.error("Could not migrate service: \(e)")
        }
    }
    
    static func migrateJSON(at url: URL) throws -> Data {
        let data = try Data(contentsOf: url)
        guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ApplicationError.migration
        }

        // put migration logic here
        let _ = json["build"] as? Int ?? 0

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}
