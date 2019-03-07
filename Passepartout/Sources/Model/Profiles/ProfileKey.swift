//
//  ProfileKey.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/6/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

struct ProfileKey: RawRepresentable, Hashable, Codable {
    let context: Context
    
    let id: String
    
    init(_ context: Context, _ id: String) {
        self.context = context
        self.id = id
    }
    
    init(_ profile: ConnectionProfile) {
        context = profile.context
        id = profile.id
    }
    
    // MARK: RawRepresentable
    
    var rawValue: String {
        return "\(context).\(id)"
    }
    
    init?(rawValue: String) {
        var comps = rawValue.components(separatedBy: ".")
        guard comps.count >= 2 else {
            return nil
        }
        guard let context = Context(rawValue: comps[0]) else {
            return nil
        }
        self.context = context
        comps.removeFirst()
        id = comps.joined(separator: ".")
    }
}
