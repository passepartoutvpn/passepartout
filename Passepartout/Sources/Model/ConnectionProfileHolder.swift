//
//  ConnectionProfileHolder.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/18.
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

class ConnectionProfileHolder: Codable {
    private let provider: ProviderConnectionProfile?
    
    private let host: HostConnectionProfile?
    
    convenience init(_ profile: ConnectionProfile) {
        if let p = profile as? ProviderConnectionProfile {
            self.init(p)
        } else if let p = profile as? HostConnectionProfile {
            self.init(p)
        } else {
            fatalError("Unexpected ConnectionProfile subtype: \(type(of: profile))")
        }
    }
    
    init(_ provider: ProviderConnectionProfile) {
        self.provider = provider
        host = nil
    }

    init(_ host: HostConnectionProfile) {
        provider = nil
        self.host = host
    }

    var contained: ConnectionProfile? {
        let found: ConnectionProfile? = provider ?? host
        assert(found != nil, "Either provider or host must be non-nil")
        return found
    }
}
