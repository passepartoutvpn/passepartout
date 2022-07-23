//
//  VPNManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/22.
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
import Combine

public protocol VPNManager {
    var lastError: Error? { get }
    
    var configurationError: PassthroughSubject<VPNConfigurationError, Never> { get }

    var tunnelLogPath: String? { get set }

    var tunnelLogFormat: String? { get set }
    
    var masksPrivateData: Bool { get set }

    func connectWithActiveProfile(toServer newServerId: String?) async throws

    @discardableResult
    func connect(with profileId: UUID) async throws -> Profile
    
    @discardableResult
    func connect(with profileId: UUID, toServer newServerId: String) async throws -> Profile
    
    func reconnect() async

    func modifyActiveProfile(_ block: (inout Profile) -> Void) async throws

    func disable() async

    func uninstall() async

    func serverConfiguration(forProtocol vpnProtocol: VPNProtocolType) -> Any?

    func debugLogURL(forProtocol vpnProtocol: VPNProtocolType) -> URL?

    func observeUpdates()
}
