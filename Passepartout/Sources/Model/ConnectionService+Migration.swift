//
//  ConnectionService+Migration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

extension ConnectionService {
    static func migrateJSON(at from: URL, to: URL) {
        do {
            let newData = try migrateJSON(at: from)
//            log.verbose(String(data: newData, encoding: .utf8)!)
            try newData.write(to: to)
        } catch let e {
            log.warning("Could not migrate service: \(e)")
        }
    }
    
    static func migrateJSON(at from: URL) throws -> Data {
        let data = try Data(contentsOf: from)
        guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ApplicationError.migration
        }

        // replace migration logic here
        try migrateToWrappedSessionConfiguration(&json)
        try migrateToBaseConfiguration(&json)
        try migrateToBuildNumber(&json)

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }

    static func migrateToWrappedSessionConfiguration(_ json: inout [String: Any]) throws {
        guard let profiles = json["profiles"] as? [[String: Any]] else {
            throw ApplicationError.migration
        }
        var newProfiles: [[String: Any]] = []
        for var container in profiles {
            guard var hostProfile = container["host"] as? [String: Any] else {
                newProfiles.append(container)
                continue
            }
            guard var parameters = hostProfile["parameters"] as? [String: Any] else {
                throw ApplicationError.migration
            }
            guard parameters["sessionConfiguration"] == nil else {
                newProfiles.append(container)
                continue
            }
            migrateSessionConfiguration(in: &parameters)
            hostProfile["parameters"] = parameters
            container["host"] = hostProfile
            newProfiles.append(container)
        }
        json["profiles"] = newProfiles
    }
    
    static func migrateToBaseConfiguration(_ json: inout [String: Any]) throws {
        guard var baseConfiguration = json["tunnelConfiguration"] as? [String: Any] else {
            return
        }
        migrateSessionConfiguration(in: &baseConfiguration)
        json["baseConfiguration"] = baseConfiguration
        json.removeValue(forKey: "tunnelConfiguration")
    }

    static func migrateToBuildNumber(_ json: inout [String: Any]) throws {
        json["build"] = GroupConstants.App.buildNumber
    }

    // MARK: Helpers
    
    private static func migrateSessionConfiguration(in map: inout [String: Any]) {
        let scKeys = [
            "cipher",
            "digest",
            "ca",
            "clientCertificate",
            "clientKey",
            "compressionFraming",
            "tlsWrap",
//            "keepAliveSeconds", // renamed
//            "renegotiatesAfterSeconds", // renamed
            "usesPIAPatches"
        ]
        var sessionConfiguration: [String: Any] = [:]
        for key in scKeys {
            guard let value = map[key] else {
                continue
            }
            sessionConfiguration[key] = value
            map.removeValue(forKey: key)
        }
        if let value = map["keepAliveSeconds"] {
            sessionConfiguration["keepAliveInterval"] = value
        }
        if let value = map["renegotiatesAfterSeconds"] {
            sessionConfiguration["renegotiatesAfter"] = value
        }
        map["sessionConfiguration"] = sessionConfiguration
    }
}
