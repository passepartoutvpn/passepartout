//
//  ProviderManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
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

import Combine
import Foundation
import PassepartoutCore

@MainActor
public final class ProviderManager: ObservableObject, RateLimited {
    private let localProvidersRepository: LocalProvidersRepository

    private let remoteProvidersStrategy: RemoteProvidersStrategy

    public let didUpdateProviders = PassthroughSubject<Void, Never>()

    public init(
        localProvidersRepository: LocalProvidersRepository,
        remoteProvidersStrategy: RemoteProvidersStrategy
    ) {
        self.localProvidersRepository = localProvidersRepository
        self.remoteProvidersStrategy = remoteProvidersStrategy

        _ = allProviders()
    }

    // MARK: Queries

    public func allProviders() -> [ProviderMetadata] {
        localProvidersRepository.allProviders()
    }

    public func provider(withName name: ProviderName) -> ProviderMetadata? {
        localProvidersRepository.provider(withName: name)
    }

    public func isAvailable(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Bool {
        localProvidersRepository.lastInfrastructureUpdate(withName: name, vpnProtocol: vpnProtocol) != nil
    }

    public func defaultUsername(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> String? {
        localProvidersRepository.defaultUsername(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func lastUpdate(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Date? {
        localProvidersRepository.lastInfrastructureUpdate(withName: name, vpnProtocol: vpnProtocol)
    }

    public func categories(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> [ProviderCategory] {
        localProvidersRepository.categories(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func servers(forLocation location: ProviderLocation) -> [ProviderServer] {
        localProvidersRepository.servers(forLocation: location)
    }

    public func server(_ name: ProviderName, vpnProtocol: VPNProtocolType, apiId: String) -> ProviderServer? {
        localProvidersRepository.server(forProviderWithName: name, vpnProtocol: vpnProtocol, apiId: apiId)
    }

    public func anyDefaultServer(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> ProviderServer? {
        localProvidersRepository.anyDefaultServer(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func server(withId id: String) -> ProviderServer? {
        localProvidersRepository.server(withId: id)
    }

    // MARK: Modification

    public func fetchProvidersIndexPublisher(priority: RemoteProvidersPriority) -> AnyPublisher<Void, Passepartout.ProviderError> {
        guard !isRateLimited(indexActionName) else {
            return Just(())
                .setFailureType(to: Passepartout.ProviderError.self)
                .eraseToAnyPublisher()
        }

        let savePublisher = remoteProvidersStrategy.saveIndex(priority: priority) {
            self.saveLastAction(self.indexActionName)
        }
        return savePublisher
            .map {
                self.didUpdateProviders.send()
            }.mapError {
                .fetchFailure(error: $0)
            }.eraseToAnyPublisher()
    }

    public func fetchProviderPublisher(withName providerName: ProviderName, vpnProtocol: VPNProtocolType, priority: RemoteProvidersPriority) -> AnyPublisher<Void, Passepartout.ProviderError> {
        guard !isRateLimited(providerName) else {
            return Just(())
                .setFailureType(to: Passepartout.ProviderError.self)
                .eraseToAnyPublisher()
        }

        let lastUpdate = localProvidersRepository.lastInfrastructureUpdate(withName: providerName, vpnProtocol: vpnProtocol)
        let savePublisher = remoteProvidersStrategy.saveProvider(
            withName: providerName,
            vpnProtocol: vpnProtocol,
            lastUpdate: lastUpdate,
            priority: priority
        ) {
            self.saveLastAction(providerName)
        }
        return savePublisher
            .map {
                self.didUpdateProviders.send()
            }.mapError {
                .fetchFailure(error: $0)
            }.eraseToAnyPublisher()
    }

    // MARK: RateLimited

    private let indexActionName = ""

    public var lastActionDate: [String: Date] = [:]

    public var rateLimitMilliseconds: Int?
}
