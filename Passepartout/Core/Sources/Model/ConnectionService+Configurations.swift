//
//  ConnectionService+Configurations.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/22/18.
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

private let log = SwiftyBeaver.self

public extension ConnectionService {
    func save(configurationURL: URL, for key: ProfileKey) throws -> URL {
        let destinationURL = targetConfigurationURL(for: key)
        let fm = FileManager.default
        try? fm.removeItem(at: destinationURL)
        try fm.copyItem(at: configurationURL, to: destinationURL)
        return destinationURL
    }
    
    func save(configurationURL: URL, for profile: ConnectionProfile) throws -> URL {
        return try save(configurationURL: configurationURL, for: ProfileKey(profile))
    }
    
    func configurationURL(for key: ProfileKey) -> URL? {
        let url = targetConfigurationURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return url
    }
    
    func configurationURL(for profile: ConnectionProfile) -> URL? {
        return configurationURL(for: ProfileKey(profile))
    }

    func targetConfigurationURL(for key: ProfileKey) -> URL {
        return contextURL(key).appendingPathComponent(key.id).appendingPathExtension("ovpn")
    }
    
    func pendingConfigurationURLs() -> [URL] {
        do {
            let list = try FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: nil, options: [])
            return list.filter { $0.pathExtension == "ovpn" }
        } catch let e {
            log.error("Could not list imported configurations: \(e)")
            return []
        }
    }
}
