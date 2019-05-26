//
//  Infrastructure.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
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
import SSZipArchive

public struct Infrastructure: Codable {
    public enum Name: String, Codable, Comparable {
        case mullvad = "Mullvad"
        
        case nordVPN = "NordVPN"

        case pia = "PIA"
        
        case protonVPN = "ProtonVPN"

        case tunnelBear = "TunnelBear"
        
        case vyprVPN = "VyprVPN"
        
        case windscribe = "Windscribe"
    }
    
    public struct Defaults: Codable {
        public let username: String?

        public let pool: String

        public let preset: String
    }
    
    public let build: Int
    
    public let name: Name
    
    public let categories: [PoolCategory]

    public let presets: [InfrastructurePreset]

    public let defaults: Defaults
    
    public static func loaded(from url: URL) throws -> Infrastructure {
        let json = try Data(contentsOf: url)
        return try JSONDecoder().decode(Infrastructure.self, from: json)
    }
    
    public func defaultPool() -> Pool? {
        return pool(withPrefix: defaults.pool)
    }
    
    public func pool(for identifier: String) -> Pool? {
        for cat in categories {
            for group in cat.groups {
                guard let found = group.pools.first(where: { $0.id == identifier }) else {
                    continue
                }
                return found
            }
        }
        return nil
    }

    public func pool(withPrefix prefix: String) -> Pool? {
        for cat in categories {
            for group in cat.groups {
                guard let found = group.pools.first(where: { $0.id.hasPrefix(prefix) }) else {
                    continue
                }
                return found
            }
        }
        return nil
    }
    
    public func preset(for identifier: String) -> InfrastructurePreset? {
        return presets.first { $0.id == identifier }
    }
}

extension Infrastructure.Name {
    public var webName: String {
        return rawValue.lowercased()
    }
    
    public static func <(lhs: Infrastructure.Name, rhs: Infrastructure.Name) -> Bool {
        return lhs.webName < rhs.webName
    }
}

extension Infrastructure.Name {
    public var externalURL: URL {
        return GroupConstants.App.externalURL.appendingPathComponent(webName)
    }

    public func importExternalResources(from url: URL, completionHandler: @escaping () -> Void) {
        var task: () -> Void
        switch self {
        case .nordVPN:
            task = {
                SSZipArchive.unzipFile(atPath: url.path, toDestination: self.externalURL.path)
            }
            
        default:
            task = {}
        }
        execute(task: task, completionHandler: completionHandler)
    }

    private func execute(task: @escaping () -> Void, completionHandler: @escaping () -> Void) {
        let queue: DispatchQueue = .global(qos: .background)
        queue.async {
            task()
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}
