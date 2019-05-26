//
//  MockVPNProvider.swift
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

public class MockVPNProvider: VPNProvider {
    public let isPrepared: Bool = true

    public private(set) var isEnabled: Bool = false
    
    public private(set) var status: VPNStatus = .disconnected
    
    public func prepare(completionHandler: (() -> Void)?) {
        NotificationCenter.default.post(name: .VPNDidPrepare, object: nil)
        completionHandler?()
    }
    
    public func install(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?) {
        isEnabled = true
        completionHandler?(nil)
    }
    
    public func connect(completionHandler: ((Error?) -> Void)?) {
        isEnabled = true
        status = .connected
        NotificationCenter.default.post(name: .VPNDidChangeStatus, object: self)
        completionHandler?(nil)
    }
    
    public func disconnect(completionHandler: ((Error?) -> Void)?) {
        isEnabled = false
        status = .disconnected
        NotificationCenter.default.post(name: .VPNDidChangeStatus, object: self)
        completionHandler?(nil)
    }
    
    public func reconnect(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?) {
        isEnabled = true
        status = .connected
        NotificationCenter.default.post(name: .VPNDidChangeStatus, object: self)
        completionHandler?(nil)
    }
    
    public func uninstall(completionHandler: (() -> Void)?) {
        isEnabled = false
        status = .disconnected
        NotificationCenter.default.post(name: .VPNDidChangeStatus, object: self)
        completionHandler?()
    }
    
    public func requestDebugLog(fallback: (() -> String)?, completionHandler: @escaping (String) -> Void) {
        let log = [String](repeating: "lorem ipsum", count: 1000).joined(separator: " ")
        completionHandler(log)
    }
    
    public func requestBytesCount(completionHandler: @escaping ((UInt, UInt)?) -> Void) {
        completionHandler((0, 0))
    }
}
