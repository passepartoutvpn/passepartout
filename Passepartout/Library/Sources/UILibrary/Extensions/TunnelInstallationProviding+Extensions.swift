//
//  TunnelInstallationProviding+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

@MainActor
extension TunnelInstallationProviding {
    public var installation: TunnelInstallation? {
        guard let currentProfile = tunnel.currentProfile else {
            return nil
        }
        guard let preview = profileManager.previews.first(where: {
            $0.id == currentProfile.id
        }) else {
            return nil
        }
        return TunnelInstallation(preview: preview, onDemand: currentProfile.onDemand)
    }

    public var currentProfile: Profile? {
        guard let id = tunnel.currentProfile?.id else {
            return nil
        }
        return profileManager.profile(withId: id)
    }
}
