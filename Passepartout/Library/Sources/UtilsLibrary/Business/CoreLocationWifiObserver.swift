//
//  CoreLocationWifiObserver.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/21/23.
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

import CoreLocation
import Foundation

public actor CoreLocationWifiObserver: NSObject, WifiObserver {
    private let locationManager = CLLocationManager()

    private var pendingTask: Task<String, Error>?

    private var continuation: CheckedContinuation<String, Error>?

    public func currentSSID() async throws -> String {
        if let pendingTask {
            return try await pendingTask.value
        }
        let pendingTask = Task {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse, .denied:
                return await currentSSIDWithoutAuthorization()

            default:
                return try await withCheckedThrowingContinuation { continuation in
                    self.continuation = continuation

                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }
        self.pendingTask = pendingTask
        let result = try await pendingTask.value
        self.pendingTask = nil
        continuation = nil
        return result
    }

    private func currentSSIDWithoutAuthorization() async -> String {
        await Utils.currentWifiSSID() ?? ""
    }
}

extension CoreLocationWifiObserver: CLLocationManagerDelegate {
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            let ssid = await currentSSIDWithoutAuthorization()
            await continuation?.resume(returning: ssid)
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await continuation?.resume(throwing: error)
        }
    }
}
