//
//  StandardVPNProvider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/18.
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
import NetworkExtension
import TunnelKit

public class StandardVPNProvider: VPNProvider {
    private let bundleIdentifier: String
    
    private var manager: NETunnelProviderManager?
    
    private var lastNotifiedStatus: VPNStatus?
    
    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vpnDidUpdate(_:)), name: .NEVPNStatusDidChange, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidReinstall(_:)), name: .NEVPNConfigurationChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: VPNProvider
    
    public var isPrepared: Bool {
        return manager != nil
    }
    
    public var isEnabled: Bool {
        guard let manager = manager else {
            return false
        }
        return manager.isEnabled && manager.isOnDemandEnabled
    }
    
    public var status: VPNStatus {
        guard let neStatus = manager?.connection.status else {
            return .disconnected
        }
        switch neStatus {
        case .connected:
            return .connected
            
        case .connecting, .reasserting:
            return .connecting
            
        case .disconnecting:
            return .disconnecting
            
        case .disconnected, .invalid:
            return .disconnected

        @unknown default:
            return .disconnected
        }
    }
    
    public func prepare(completionHandler: (() -> Void)?) {
        find(with: bundleIdentifier) {
            self.manager = $0
            NotificationCenter.default.post(name: .VPNDidPrepare, object: nil)
            completionHandler?()
        }
    }
    
    public func install(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?) {
        guard let configuration = configuration as? NetworkExtensionVPNConfiguration else {
            fatalError("Not a NetworkExtensionVPNConfiguration")
        }
        find(with: bundleIdentifier) {
            guard let manager = $0 else {
                completionHandler?(nil)
                return
            }
            self.manager = manager
            manager.protocolConfiguration = configuration.protocolConfiguration
            manager.onDemandRules = configuration.onDemandRules
            manager.isOnDemandEnabled = true
            manager.isEnabled = true
            manager.saveToPreferences { (error) in
                guard error == nil else {
                    manager.isOnDemandEnabled = false
                    manager.isEnabled = false
                    completionHandler?(error)
                    return
                }
                manager.loadFromPreferences { (error) in
                    completionHandler?(error)
                }
            }
        }
    }
    
    public func connect(completionHandler: ((Error?) -> Void)?) {
        do {
            try manager?.connection.startVPNTunnel()
            completionHandler?(nil)
        } catch let e {
            completionHandler?(e)
        }
    }
    
    public func disconnect(completionHandler: ((Error?) -> Void)?) {
        guard let manager = manager else {
            completionHandler?(nil)
            return
        }
        manager.connection.stopVPNTunnel()
        manager.isOnDemandEnabled = false
        manager.isEnabled = false
        manager.saveToPreferences(completionHandler: completionHandler)
    }
    
    public func reconnect(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?) {
        guard let configuration = configuration as? NetworkExtensionVPNConfiguration else {
            fatalError("Not a NetworkExtensionVPNConfiguration")
        }
        install(configuration: configuration) { (error) in
            guard error == nil else {
                completionHandler?(nil)
                return
            }
            let connectBlock = {
                self.connect(completionHandler: completionHandler)
            }
            if self.status != .disconnected {
                self.manager?.connection.stopVPNTunnel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: connectBlock)
            } else {
                connectBlock()
            }
        }
    }
    
    public func uninstall(completionHandler: (() -> Void)?) {
        find(with: bundleIdentifier) { (manager) in
            guard let manager = manager else {
                completionHandler?()
                return
            }
            manager.connection.stopVPNTunnel()
            manager.removeFromPreferences { (error) in
                self.manager = nil
                completionHandler?()
            }
        }
    }
    
    public func requestDebugLog(fallback: (() -> String)?, completionHandler: @escaping (String) -> Void) {
        guard status != .disconnected else {
            completionHandler(fallback?() ?? "")
            return
        }
        findAndRequestDebugLog { (recent) in
            DispatchQueue.main.async {
                guard let recent = recent else {
                    completionHandler(fallback?() ?? "")
                    return
                }
                completionHandler(recent)
            }
        }
    }
    
    public func requestBytesCount(completionHandler: @escaping ((UInt, UInt)?) -> Void) {
        find(with: bundleIdentifier) {
            self.manager = $0
            guard let session = self.manager?.connection as? NETunnelProviderSession else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            do {
                try session.sendProviderMessage(OpenVPNTunnelProvider.Message.dataCount.data) { (data) in
                    guard let data = data, data.count == 16 else {
                        DispatchQueue.main.async {
                            completionHandler(nil)
                        }
                        return
                    }
                    let bytesIn: UInt = data.subdata(in: 0..<8).withUnsafeBytes { $0.load(as: UInt.self) }
                    let bytesOut: UInt = data.subdata(in: 8..<16).withUnsafeBytes { $0.load(as: UInt.self) }
                    DispatchQueue.main.async {
                        completionHandler((bytesIn, bytesOut))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    
    // MARK: Helpers
    
    private func find(with bundleIdentifier: String, completionHandler: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard error == nil else {
                completionHandler(nil)
                return
            }
            let manager = managers?.first {
                guard let ptm = $0.protocolConfiguration as? NETunnelProviderProtocol else {
                    return false
                }
                return (ptm.providerBundleIdentifier == bundleIdentifier)
            }
            completionHandler(manager ?? NETunnelProviderManager())
        }
    }

    private func findAndRequestDebugLog(completionHandler: @escaping (String?) -> Void) {
        find(with: bundleIdentifier) {
            self.manager = $0
            guard let session = self.manager?.connection as? NETunnelProviderSession else {
                completionHandler(nil)
                return
            }
            StandardVPNProvider.requestDebugLog(session: session, completionHandler: completionHandler)
        }
    }
    
    private static func requestDebugLog(session: NETunnelProviderSession, completionHandler: @escaping (String?) -> Void) {
        do {
            try session.sendProviderMessage(OpenVPNTunnelProvider.Message.requestLog.data) { (data) in
                guard let data = data, !data.isEmpty else {
                    completionHandler(nil)
                    return
                }
                let newestLog = String(data: data, encoding: .utf8)
                completionHandler(newestLog)
            }
        } catch {
            completionHandler(nil)
        }
    }
    
    // MARK: Notifications
    
    @objc private func vpnDidUpdate(_ notification: Notification) {
//        guard let connection = notification.object as? NETunnelProviderSession else {
//            return
//        }
//        log.debug("VPN status did change: \(connection.status.rawValue)")

        let status = self.status
        if let last = lastNotifiedStatus {
            guard status != last else {
                return
            }
        }
        lastNotifiedStatus = status

        NotificationCenter.default.post(name: .VPNDidChangeStatus, object: self)
    }

    @objc private func vpnDidReinstall(_ notification: Notification) {
        NotificationCenter.default.post(name: .VPNDidReinstall, object: self)
    }
}
