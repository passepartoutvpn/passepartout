//
//  LightProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
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

@objc(LightProfile)
public protocol LightProfile {
    var id: UUID { get }

    var name: String { get }

    var vpnProtocol: String { get }

    var isActive: Bool { get }

    var providerName: String? { get }

    var providerServer: LightProviderServer? { get }
}

extension LightProfile {
    public var isProvider: Bool {
        providerName != nil
    }
}

@MainActor
@objc
public protocol LightProfileManager {
    var hasProfiles: Bool { get }

    var profiles: [LightProfile] { get }

    var activeProfileId: UUID? { get }

    var activeProfileName: String? { get }

    var delegate: LightProfileManagerDelegate? { get set }
}

@objc
public protocol LightProfileManagerDelegate {
    func didUpdateProfiles()
}
