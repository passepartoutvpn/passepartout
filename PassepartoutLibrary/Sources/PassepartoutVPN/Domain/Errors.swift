//
//  Errors.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/30/23.
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

import Foundation
import PassepartoutCore
import PassepartoutProviders

extension Passepartout {
    public enum ProfileError: Error {
        case importFailure(error: Error)

        case decryptionFailure(error: Error)

        case notFound(profileId: UUID)

        case failedToFetchProvider(profileId: UUID, error: Error)
    }

    public enum VPNError: Error {
        case notProvider(profile: Profile)

        case providerServerNotFound(profile: Profile)

        case providerPresetNotFound(profile: Profile)

        case missingAccount(profile: Profile)

        case emptyEndpoints(server: ProviderServer)
    }
}
