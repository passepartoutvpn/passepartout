//
//  GracefulVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/18.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class GracefulVPN {
    private let service: ConnectionService
    
    public var profile: ConnectionProfile?
    
    private var vpn: VPNProvider? {
        guard let profile = profile else {
            return nil
        }
        guard service.isActiveProfile(profile) else {
            return nil
        }
        return VPN.shared
    }
    
    public var isEnabled: Bool {
        return vpn?.isEnabled ?? false
    }
    
    public var status: VPNStatus? {
        return vpn?.status
    }
    
    public init(service: ConnectionService) {
        self.service = service
    }
    
    public func prepare(completionHandler: (() -> Void)?) {
        service.clearVpnLastError()
        guard let vpn = vpn else {
            completionHandler?()
            return
        }
        log.info("Preparing...")
        vpn.prepare(completionHandler: completionHandler)
    }
    
    public func reconnect(completionHandler: ((Error?) -> Void)?) {
        service.clearVpnLastError()
        guard let vpn = vpn else {
            completionHandler?(ApplicationError.inactiveProfile)
            return
        }
        do {
            log.info("Reconnecting...")
            try vpn.reconnect(configuration: service.vpnConfiguration(), completionHandler: completionHandler)
        } catch let e {
            guard e as? ApplicationError != .externalResources else {
                completionHandler?(e)
                return
            }
            log.error("Could not reconnect: \(e)")
        }
    }
    
    public func reinstall(completionHandler: ((Error?) -> Void)?) {
        service.clearVpnLastError()
        guard let vpn = vpn else {
            completionHandler?(ApplicationError.inactiveProfile)
            return
        }
        do {
            log.info("Reinstalling...")
            try vpn.install(configuration: service.vpnConfiguration(), completionHandler: completionHandler)
        } catch let e {
            guard e as? ApplicationError != .externalResources else {
                completionHandler?(e)
                return
            }
            log.error("Could not reinstall: \(e)")
        }
    }
    
    public func reinstallIfEnabled() {
        guard isEnabled else {
            log.warning("Not reinstalling (VPN is disabled)")
            return
        }
        if status != .disconnected {
            reconnect(completionHandler: nil)
        } else {
            reinstall(completionHandler: nil)
        }
    }
    
    public func disconnect(completionHandler: ((Error?) -> Void)?) {
        guard let vpn = vpn else {
            completionHandler?(ApplicationError.inactiveProfile)
            return
        }
        vpn.disconnect(completionHandler: completionHandler)
    }

    public func uninstall(completionHandler: (() -> Void)?) {
        guard let vpn = vpn else {
            completionHandler?()
            return
        }
        vpn.uninstall(completionHandler: completionHandler)
    }
    
    public func requestBytesCount(completionHandler: @escaping ((UInt, UInt)?) -> Void) {
        guard let vpn = vpn else {
            completionHandler(nil)
            return
        }
        vpn.requestBytesCount(completionHandler: completionHandler)
    }
}
