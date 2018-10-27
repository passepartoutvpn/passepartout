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
            log.error("Could not migrate service: \(e)")
        }
    }
    
    static func migrateJSON(at from: URL) throws -> Data {
        let data = try Data(contentsOf: from)
        guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ApplicationError.migration
        }

        // replace migration logic here
        // TODO: remove this code after 1.0 release
        let build = json["build"] as? Int ?? 0
        if build <= 1084 {
            try migrateToWrappedSessionConfiguration(&json)
            try migrateToBaseConfiguration(&json)
            try migrateToBuildNumber(&json)
            try migrateHostProfileConfigurations()
            try migrateSplitProfileSerialization(&json)
        }

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    // MARK: Atomic migrations

    static func migrateToWrappedSessionConfiguration(_ json: inout [String: Any]) throws {
        guard let profiles = json["profiles"] as? [[String: Any]] else {
            // migrated
            return
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
            // migrated
            return
        }
        migrateSessionConfiguration(in: &baseConfiguration)
        json["baseConfiguration"] = baseConfiguration
        json.removeValue(forKey: "tunnelConfiguration")
    }

    static func migrateToBuildNumber(_ json: inout [String: Any]) throws {
        json["build"] = GroupConstants.App.buildNumber
    }

    static func migrateHostProfileConfigurations() throws {
        let fm = FileManager.default
        let oldDirectory = fm.userURL(for: .documentDirectory, appending: "Configurations")
        guard fm.fileExists(atPath: oldDirectory.path) else {
            return
        }
        
        let newDirectory = fm.userURL(for: .documentDirectory, appending: AppConstants.Store.hostsDirectory)
        try fm.moveItem(at: oldDirectory, to: newDirectory)
        let list = try fm.contentsOfDirectory(at: newDirectory, includingPropertiesForKeys: nil, options: [])
        let prefix = "host."
        for url in list {
            let filename = url.lastPathComponent
            guard filename.hasPrefix(prefix) else {
                continue
            }
            let postPrefixIndex = filename.index(filename.startIndex, offsetBy: prefix.count)
            let newFilename = String(filename[postPrefixIndex..<filename.endIndex])
            var newURL = url
            newURL.deleteLastPathComponent()
            newURL.appendPathComponent(newFilename)
            try fm.moveItem(at: url, to: newURL)
        }
    }
    
    static func migrateSplitProfileSerialization(_ json: inout [String: Any]) throws {
        guard let profiles = json["profiles"] as? [[String: Any]] else {
            return
        }

        let fm = FileManager.default
        let providersParentURL = fm.userURL(for: .documentDirectory, appending: AppConstants.Store.providersDirectory)
        let hostsParentURL = fm.userURL(for: .documentDirectory, appending: AppConstants.Store.hostsDirectory)
        try? fm.createDirectory(at: providersParentURL, withIntermediateDirectories: false, attributes: nil)
        try? fm.createDirectory(at: hostsParentURL, withIntermediateDirectories: false, attributes: nil)

        for p in profiles {
            if var provider = p["provider"] as? [String: Any] {
                guard let id = provider["name"] as? String else {
                    continue
                }
//                provider["id"] = id
//                provider.removeValue(forKey: "name")
        
                let url = providersParentURL.appendingPathComponent(id).appendingPathExtension("json")
                let data = try JSONSerialization.data(withJSONObject: provider, options: [])
                try data.write(to: url)
            } else if var host = p["host"] as? [String: Any] {
                guard let id = host["title"] as? String else {
                    continue
                }
//                host["id"] = id
//                host.removeValue(forKey: "title")

                let url = hostsParentURL.appendingPathComponent(id).appendingPathExtension("json")
                let data = try JSONSerialization.data(withJSONObject: host, options: [])
                try data.write(to: url)
            }
        }
        
        guard let activeProfileId = json["activeProfileId"] else {
            return
        }
        json["activeProfileKey"] = activeProfileId
        json.removeValue(forKey: "activeProfileId")
        json.removeValue(forKey: "profiles")
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

        map.removeValue(forKey: "debugLogKey")
        map.removeValue(forKey: "lastErrorKey")
    }
}
