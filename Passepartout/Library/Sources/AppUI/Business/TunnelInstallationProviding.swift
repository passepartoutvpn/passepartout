//
//  TunnelInstallationProviding.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import AppLibrary
import Foundation
import PassepartoutKit

protocol TunnelInstallationProviding {
    var profileManager: ProfileManager { get }

    var tunnel: Tunnel { get }
}

struct TunnelInstallation {
    let header: ProfileHeader

    let isEnabled: Bool
}

@MainActor
extension TunnelInstallationProviding {
    var installation: TunnelInstallation? {
        guard let installedProfile = tunnel.installedProfile else {
            return nil
        }
        guard let header = profileManager.headers.first(where: {
            $0.id == installedProfile.id
        }) else {
            return nil
        }
        return TunnelInstallation(header: header, isEnabled: installedProfile.isEnabled)
    }

    var installedProfile: Profile? {
        guard let id = tunnel.installedProfile?.id else {
            return nil
        }
        return profileManager.profile(withId: id)
    }
}
