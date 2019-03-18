//
//  VPNProvider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/6/18.
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

public protocol VPNProvider: class {
    var isPrepared: Bool { get }
    
    var isEnabled: Bool { get }
    
    var status: VPNStatus { get }
    
    func prepare(completionHandler: (() -> Void)?)
    
    func install(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?)
    
    func connect(completionHandler: ((Error?) -> Void)?)
    
    func disconnect(completionHandler: ((Error?) -> Void)?)
    
    func reconnect(configuration: VPNConfiguration, completionHandler: ((Error?) -> Void)?)
    
    func uninstall(completionHandler: (() -> Void)?)
    
    func requestDebugLog(fallback: (() -> String)?, completionHandler: @escaping (String) -> Void)
    
    func requestBytesCount(completionHandler: @escaping ((UInt, UInt)?) -> Void)
}

public extension Notification.Name {
    static let VPNDidPrepare = Notification.Name("VPNDidPrepare")
    
    static let VPNDidChangeStatus = Notification.Name("VPNDidChangeStatus")

    static let VPNDidReinstall = Notification.Name("VPNDidReinstall")
}
