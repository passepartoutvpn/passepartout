//
//  TrustedNetworks.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/21/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

public protocol TrustedNetworksModelDelegate: class {
    func trustedNetworksCouldDisconnect(_: TrustedNetworksModel) -> Bool

    func trustedNetworksShouldConfirmDisconnection(_: TrustedNetworksModel, triggeredAt rowIndex: Int, completionHandler: @escaping () -> Void)

    func trustedNetworks(_: TrustedNetworksModel, shouldInsertWifiAt rowIndex: Int)
    
    func trustedNetworks(_: TrustedNetworksModel, shouldReloadWifiAt rowIndex: Int, isTrusted: Bool)

    func trustedNetworks(_: TrustedNetworksModel, shouldDeleteWifiAt rowIndex: Int)

    func trustedNetworksShouldReinstall(_: TrustedNetworksModel)
}

public class TrustedNetworksModel {
    public enum RowType {
        case trustsMobile
        
        case trustedWiFi
        
        case addCurrentWiFi
    }
    
    public private(set) var trustedWifis: [String: Bool]
    
    public private(set) var sortedWifis: [String]
    
    #if os(iOS)
    private let hasMobileNetwork: Bool
    
    public private(set) var trustsMobileNetwork: Bool

    public private(set) var rows: [RowType]
    #endif
    
    public weak var delegate: TrustedNetworksModelDelegate?
    
    public init() {
        trustedWifis = [:]
        sortedWifis = []

        #if os(iOS)
        hasMobileNetwork = Utils.hasCellularData()
        trustsMobileNetwork = false
        rows = []
        #endif
    }

    public func load(from preferences: Preferences) {
        trustedWifis = preferences.trustedWifis
        sortedWifis = trustedWifis.keys.sorted()

        #if os(iOS)
        trustsMobileNetwork = preferences.trustsMobileNetwork
        rows.removeAll()
        if hasMobileNetwork {
            rows.append(.trustsMobile)
        }
        for _ in sortedWifis {
            rows.append(.trustedWiFi)
        }
        rows.append(.addCurrentWiFi)
        #endif
    }
    
    #if os(iOS)
    public func setMobile(_ isTrusted: Bool) {
        let completionHandler: () -> Void = {
            self.trustsMobileNetwork = isTrusted
            self.delegate?.trustedNetworksShouldReinstall(self)
        }
        guard !(isTrusted && mightDisconnect()) else {
            delegate?.trustedNetworksShouldConfirmDisconnection(self, triggeredAt: 0, completionHandler: completionHandler)
            return
        }
        completionHandler()
    }
    #endif
    
    public func wifi(at rowIndex: Int) -> (String, Bool) {
        let index = indexForWifi(at: rowIndex)
        let wifiName = sortedWifis[index]
        let isTrusted = trustedWifis[wifiName] ?? false
        return (wifiName, isTrusted)
    }

    public func addCurrentWifi() -> Bool {
        guard let currentWifi = Utils.currentWifiNetworkName() else {
            return false
        }
        addWifi(currentWifi)
        return true
    }
    
    public func addWifi(_ wifiToAdd: String) {
        var index = 0
        var isDuplicate = false
        for wifi in sortedWifis {
            guard wifiToAdd != wifi else {
                isDuplicate = true
                break
            }
            guard wifiToAdd > wifi else {
                break
            }
            index += 1
        }

        guard !(trustedWifis[wifiToAdd] ?? false) else {
            return
        }

        let isTrusted = false
        let rowIndex = rowIndexForWifi(at: index)
        trustedWifis[wifiToAdd] = isTrusted

        if !isDuplicate {
            sortedWifis.insert(wifiToAdd, at: index)
            #if os(iOS)
            rows.insert(.trustedWiFi, at: rowIndex)
            #endif
            delegate?.trustedNetworks(self, shouldInsertWifiAt: rowIndex)
        } else {
            delegate?.trustedNetworks(self, shouldReloadWifiAt: rowIndex, isTrusted: isTrusted)
        }

        delegate?.trustedNetworksShouldReinstall(self)
    }
    
    public func removeWifi(at rowIndex: Int) {
        let index = indexForWifi(at: rowIndex)
        let removedWifi = sortedWifis.remove(at: index)
        trustedWifis.removeValue(forKey: removedWifi)
        #if os(iOS)
        rows.remove(at: rowIndex)
        #endif
        
        delegate?.trustedNetworks(self, shouldDeleteWifiAt: rowIndex)
        delegate?.trustedNetworksShouldReinstall(self)
    }
    
    public func enableWifi(at rowIndex: Int) {
        let index = indexForWifi(at: rowIndex)
        let wifi = sortedWifis[index]

        let completionHandler: () -> Void = {
            self.trustedWifis[wifi] = true

            self.delegate?.trustedNetworks(self, shouldReloadWifiAt: rowIndex, isTrusted: true)
            self.delegate?.trustedNetworksShouldReinstall(self)
        }
        guard !mightDisconnect() else {
            delegate?.trustedNetworksShouldConfirmDisconnection(self, triggeredAt: rowIndex, completionHandler: completionHandler)
            return
        }
        completionHandler()
    }

    public func disableWifi(at rowIndex: Int) {
        let index = indexForWifi(at: rowIndex)
        let wifi = sortedWifis[index]

        trustedWifis[wifi] = false
        
        delegate?.trustedNetworks(self, shouldReloadWifiAt: rowIndex, isTrusted: false)
        delegate?.trustedNetworksShouldReinstall(self)
    }
    
    public func isTrusted(wifi: String) -> Bool {
        return trustedWifis[wifi] ?? false
    }
    
    private func indexForWifi(at rowIndex: Int) -> Int {
        #if os(iOS)
        return hasMobileNetwork ? (rowIndex - 1) : rowIndex
        #else
        return rowIndex
        #endif
    }

    private func rowIndexForWifi(at index: Int) -> Int {
        #if os(iOS)
        return index + (hasMobileNetwork ? 1 : 0)
        #else
        return index
        #endif
    }

    private func mightDisconnect() -> Bool {
        return delegate?.trustedNetworksCouldDisconnect(self) ?? false
    }
}
