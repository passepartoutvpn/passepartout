//
//  ProviderManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/19/22.
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

public protocol ProviderManager {
    func allProviders() -> [ProviderMetadata]
    
    func provider(withName name: ProviderName) -> ProviderMetadata?
    
    func isAvailable(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Bool
    
    func defaultUsername(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> String?
    
    func lastUpdate(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Date?
    
    func categories(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> [ProviderCategory]

    func servers(forLocation location: ProviderLocation) -> [ProviderServer]

    func server(_ name: ProviderName, vpnProtocol: VPNProtocolType, apiId: String) -> ProviderServer?

    func anyDefaultServer(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> ProviderServer?
    
    func server(withId id: String) -> ProviderServer?

    func fetchProvidersIndexPublisher(priority: ProviderManagerFetchPriority) -> AnyPublisher<Void, Error>
    
    func fetchProviderPublisher(
        withName providerName: ProviderName,
        vpnProtocol: VPNProtocolType,
        priority: ProviderManagerFetchPriority
    ) -> AnyPublisher<Void, Error>
    
    func reset()
}
