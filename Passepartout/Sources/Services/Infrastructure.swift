//
//  Infrastructure.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
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
import TunnelKit

struct Infrastructure: Codable {
    enum Name: String, Codable {
        case pia = "PIA"
        
        var webName: String {
            return rawValue.lowercased()
        }
    }
    
    struct Defaults: Codable {
        let username: String?

        let pool: String

        let preset: String
    }
    
    let name: Name
    
    let pools: [Pool]

    let presets: [InfrastructurePreset]

    let defaults: Defaults
    
    static func loaded(from url: URL) throws -> Infrastructure {
        let json = try Data(contentsOf: url)
        return try JSONDecoder().decode(Infrastructure.self, from: json)
    }
    
    func pool(for identifier: String) -> Pool? {
        return pools.first { $0.id == identifier }
    }

    func preset(for identifier: String) -> InfrastructurePreset? {
        return presets.first { $0.id == identifier }
    }
}
