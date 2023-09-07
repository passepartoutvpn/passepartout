//
//  KeyValueStore+CloudKit.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/23.
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
import PassepartoutLibrary

extension KeyValueStore {
    static var cloudKitToken: Any? {
        FileManager.default.ubiquityIdentityToken
    }

    static var isCloudKitGloballyEnabled: Bool {
        cloudKitToken != nil
    }

    var isCloudKitEnabled: Bool {
        guard let token = Self.cloudKitToken else {
            pp_log.debug("CloudKit unavailable")
            return false
        }
        pp_log.debug("CloudKit available: \(token)")
        let isEnabled = value(forLocation: AppPreference.enablesCloudSyncing) ?? false
        pp_log.debug("CloudKit enabled: \(isEnabled)")
        return isEnabled
    }
}
