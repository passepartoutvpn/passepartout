// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonUtils
import Foundation

extension KeyValueManager {

    // TODO: #1513, refactor to keep automatically in sync with AppPreference
    public var preferences: AppPreferenceValues {
        get {
            var values = AppPreferenceValues()
            values.deviceId = string(forKey: AppPreference.deviceId.key)
            values.dnsFallsBack = bool(forKey: AppPreference.dnsFallsBack.key)
            values.lastCheckedVersionDate = double(forKey: AppPreference.lastCheckedVersionDate.key)
            values.lastCheckedVersion = object(forKey: AppPreference.lastCheckedVersion.key)
            values.lastUsedProfileId = object(forKey: AppPreference.lastUsedProfileId.key)
            values.logsPrivateData = bool(forKey: AppPreference.logsPrivateData.key)
            values.skipsPurchases = bool(forKey: AppPreference.skipsPurchases.key)
            values.usesModernCrypto = bool(forKey: AppPreference.usesModernCrypto.key)
            values.usesNESocket = bool(forKey: AppPreference.usesNESocket.key)
            return values
        }
        set {
            set(newValue.deviceId, forKey: AppPreference.dnsFallsBack.key)
            set(newValue.dnsFallsBack, forKey: AppPreference.dnsFallsBack.key)
            set(newValue.lastCheckedVersionDate, forKey: AppPreference.lastCheckedVersionDate.key)
            set(newValue.lastCheckedVersion, forKey: AppPreference.lastCheckedVersion.key)
            set(newValue.lastUsedProfileId, forKey: AppPreference.lastUsedProfileId.key)
            set(newValue.logsPrivateData, forKey: AppPreference.logsPrivateData.key)
            set(newValue.skipsPurchases, forKey: AppPreference.skipsPurchases.key)
            set(newValue.usesModernCrypto, forKey: AppPreference.usesModernCrypto.key)
            set(newValue.usesNESocket, forKey: AppPreference.usesNESocket.key)
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
