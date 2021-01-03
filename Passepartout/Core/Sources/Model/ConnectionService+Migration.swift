//
//  ConnectionService+Migration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import TunnelKit

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
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ApplicationError.migration
        }

        // put migration logic here
        let _ = json["build"] as? Int ?? 0

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }

    func migrateProvidersToLowercase() {

        // migrate providers to lowercase names
        guard let files = try? FileManager.default.contentsOfDirectory(at: providersURL, includingPropertiesForKeys: nil, options: []) else {
            log.debug("No providers to migrate")
            return
        }
        for entry in files {
            let filename = entry.lastPathComponent

            // old names contain at least an uppercase letter
            guard let _ = filename.rangeOfCharacter(from: .uppercaseLetters) else {
                continue
            }
            
            log.debug("Migrating provider in \(filename) to new name")
            do {
                let data = try Data(contentsOf: entry)
                guard var obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let name = obj["name"] as? String else {
                    log.warning("Skipping provider \(filename), not a JSON or no 'name' key found")
                    continue
                }

                // replace name and overwrite
                obj["name"] = name.lowercased()
                let migratedData = try JSONSerialization.data(withJSONObject: obj, options: [])
                try? migratedData.write(to: entry)
                
                // rename file if it makes sense
                let newEntry = entry.deletingLastPathComponent().appendingPathComponent(filename.lowercased())
                try? FileManager.default.moveItem(at: entry, to: newEntry)

                log.debug("Migrated provider: \(name)")
            } catch let e {
                log.warning("Unable to migrate provider \(filename): \(e)")
            }
        }
    }
    
    func migrateHostsToUUID() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: hostsURL, includingPropertiesForKeys: nil, options: []) else {
            log.debug("No hosts to migrate")
            return
        }

        // initialize titles mapping
        hostTitles = [:]
        
        for entry in files {
            let filename = entry.lastPathComponent
            guard filename.hasSuffix(".json") else {
                continue
            }

            log.debug("Migrating host \(filename) to UUID-based")
            do {
                let data = try Data(contentsOf: entry)
                guard var obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let title = obj["title"] as? String else {
                    log.warning("Skipping host \(filename), not a JSON or no 'title' key found")
                    continue
                }
                
                // pick unique id
                let uuid = UUID().uuidString
                
                // remove title from JSON (will move to index)
                obj["id"] = uuid
//                obj.removeValue(forKey: "title")

                // save mapping for later
                hostTitles[uuid] = title
                
                // migrate active profile if necessary (= it's a host)
                if let key = activeProfileKey, key.context == .host && key.id == title {
                    activeProfileKey = ProfileKey(.host, uuid)
                }

                // replace name and overwrite
                let migratedData = try JSONSerialization.data(withJSONObject: obj, options: [])
                try? migratedData.write(to: entry)
                
                let parent = entry.deletingLastPathComponent()
                
                // rename file to UUID
                let newFilename = "\(uuid).json"
                let newEntry = parent.appendingPathComponent(newFilename)
                try? FileManager.default.moveItem(at: entry, to: newEntry)
                
                // rename associated .ovpn (if any)
                let ovpnFilename = "\(title).ovpn"
                let ovpnNewFilename = "\(uuid).ovpn"
                try? FileManager.default.moveItem(
                    at: parent.appendingPathComponent(ovpnFilename),
                    to: parent.appendingPathComponent(ovpnNewFilename)
                )

                log.debug("Migrated host: \(filename) -> \(newFilename)")
            } catch let e {
                log.warning("Unable to migrate host \(filename): \(e)")
            }
        }
    }
    
    func migrateKeychainContext() {
        for key in allProfileKeys() {
            guard let profile = profile(withKey: key), let username = profile.username else {
                continue
            }
            let keychain = Keychain(group: GroupConstants.App.groupId)
            let prefix = "com.algoritmico.ios.Passepartout"

            // profiles
            do {
                let oldUsername = "\(prefix).\(key.context).\(key.id).\(username)"
                let password = try keychain.password(for: oldUsername)
                try profile.setPassword(password, in: keychain)
                keychain.removePassword(for: oldUsername)

                // tunnel
                if isActiveProfile(key) {
                    let oldTunnelUsername = prefix
                    let tunnelContext = "\(prefix).Tunnel"
                    try keychain.set(password: password, for: username, context: tunnelContext)
                    keychain.removePassword(for: oldTunnelUsername)
                }
            } catch {
                //
            }
        }
    }
}
