//
//  SSIDReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import Combine

public class SSIDReader: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    private let publisher = PassthroughSubject<String, Never>()
    
    private var cancellables: Set<AnyCancellable> = []

    public func requestCurrentSSID(onSSID: @escaping (String) -> Void) {
        publisher
            .sink(receiveValue: onSSID)
            .store(in: &cancellables)
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .denied:
            notifyCurrentSSID()
            return

        default:
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
        }
    }

    private func notifyCurrentSSID() {
        let currentSSID = Utils.currentWifiNetworkName() ?? ""
        publisher.send(currentSSID)
        cancellables.removeAll()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways, .denied:
            notifyCurrentSSID()

        default:
            cancellables.removeAll()
        }
    }
}
