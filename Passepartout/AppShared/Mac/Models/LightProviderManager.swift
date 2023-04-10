//
//  DefaultLightProviderManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/7/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

@objc(LightProviderCategory)
public protocol LightProviderCategory {
    var name: String { get }

    var locations: [LightProviderLocation] { get }
}

@objc(LightProviderLocation)
public protocol LightProviderLocation {
    var description: String { get }

    var id: String { get }

    var countryCode: String { get }

    var servers: [LightProviderServer] { get }
}

@objc(LightProviderServer)
public protocol LightProviderServer {
    var description: String { get }

    var longDescription: String { get }

    var categoryName: String { get }

    var locationId: String { get }

    var serverId: String { get }
}

@MainActor
@objc
public protocol LightProviderManager {
    var delegate: LightProviderManagerDelegate? { get set }

    func categories(_ name: String, vpnProtocol: String) -> [LightProviderCategory]

    func downloadIfNeeded(_ name: String, vpnProtocol: String)
}

@objc
public protocol LightProviderManagerDelegate {
    func didUpdateProviders()
}
