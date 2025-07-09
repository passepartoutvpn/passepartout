//
//  KeyValueManager+AppPreference.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/17/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonUtils
import Foundation

extension KeyValueManager {
    public var preferences: AppPreferenceValues {
        get {
            var values = AppPreferenceValues()
            values.dnsFallsBack = bool(forKey: AppPreference.dnsFallsBack.key)
            values.lastUsedProfileId = object(forKey: AppPreference.lastUsedProfileId.key)
            values.logsPrivateData = bool(forKey: AppPreference.logsPrivateData.key)
            values.skipsPurchases = bool(forKey: AppPreference.skipsPurchases.key)
            values.usesModernCrypto = bool(forKey: AppPreference.usesModernCrypto.key)
            return values
        }
        set {
            set(newValue.dnsFallsBack, forKey: AppPreference.dnsFallsBack.key)
            set(newValue.lastUsedProfileId, forKey: AppPreference.lastUsedProfileId.key)
            set(newValue.logsPrivateData, forKey: AppPreference.logsPrivateData.key)
            set(newValue.skipsPurchases, forKey: AppPreference.skipsPurchases.key)
            set(newValue.usesModernCrypto, forKey: AppPreference.usesModernCrypto.key)
        }
    }

    public convenience init(store: KeyValueStore, fallback: AppPreferenceValues) {
        let values = [
            AppPreference.dnsFallsBack.key: fallback.dnsFallsBack,
            AppPreference.logsPrivateData.key: fallback.logsPrivateData,
            AppPreference.usesModernCrypto.key: fallback.usesModernCrypto
        ]
        self.init(store: store, fallback: values)
    }
}
