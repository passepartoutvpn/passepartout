//
//  SSIDReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/22.
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
import CoreLocation

@MainActor
public class SSIDReader: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    private var continuation: CheckedContinuation<String, Error>?

    private func currentSSID() async -> String {
        await Utils.currentWifiSSID() ?? ""
    }

    public func requestCurrentSSID() async throws -> String {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .denied:
            return await currentSSID()

        default:
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation

                manager.delegate = self
                manager.requestWhenInUseAuthorization()
            }
        }
    }
}

extension SSIDReader: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways, .denied:
            Task {
                continuation?.resume(returning: await currentSSID())
                continuation = nil
            }

        default:
            continuation?.resume(with: .success(""))
            continuation = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
