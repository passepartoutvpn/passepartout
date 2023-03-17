//
//  ProviderManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
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
import Combine
import PassepartoutCore
import PassepartoutServices
import PassepartoutUtils

public final class ProviderManager: ObservableObject, RateLimited {
    private let appBuild: Int

    private let bundleServices: WebServices

    private let webServices: WebServices

    private let persistence: Persistence

    private let providerRepository: ProviderRepository

    private let infrastructureRepository: InfrastructureRepository

    private let serverRepository: ServerRepository

    public let didUpdateProviders = PassthroughSubject<Void, Never>()

    public init(appBuild: Int, bundleServices: WebServices, webServices: WebServices, persistence: Persistence) {
        self.appBuild = appBuild
        self.bundleServices = bundleServices
        self.webServices = webServices
        self.persistence = persistence
        providerRepository = ProviderRepository(persistence.context)
        infrastructureRepository = InfrastructureRepository(persistence.context)
        serverRepository = ServerRepository(persistence.context)

        _ = allProviders()
    }

    // MARK: Queries

    public func allProviders() -> [ProviderMetadata] {
        providerRepository.allProviders()
    }

    public func provider(withName name: ProviderName) -> ProviderMetadata? {
        providerRepository.provider(withName: name)
    }

    public func isAvailable(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Bool {
        infrastructureRepository.lastInfrastructureUpdate(withName: name, vpnProtocol: vpnProtocol) != nil
    }

    public func defaultUsername(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> String? {
        infrastructureRepository.defaultUsername(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func lastUpdate(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> Date? {
        infrastructureRepository.lastInfrastructureUpdate(withName: name, vpnProtocol: vpnProtocol)
    }

    public func categories(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> [ProviderCategory] {
        serverRepository.categories(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func servers(forLocation location: ProviderLocation) -> [ProviderServer] {
        serverRepository.servers(forLocation: location)
    }

    public func server(_ name: ProviderName, vpnProtocol: VPNProtocolType, apiId: String) -> ProviderServer? {
        serverRepository.server(forProviderWithName: name, vpnProtocol: vpnProtocol, apiId: apiId)
    }

    public func anyDefaultServer(_ name: ProviderName, vpnProtocol: VPNProtocolType) -> ProviderServer? {
        serverRepository.anyDefaultServer(forProviderWithName: name, vpnProtocol: vpnProtocol)
    }

    public func server(withId id: String) -> ProviderServer? {
        serverRepository.server(withId: id)
    }

    // MARK: Modification

    public func fetchProvidersIndexPublisher(priority: ProviderManagerFetchPriority) -> AnyPublisher<Void, Error> {
        guard !isRateLimited(indexActionName) else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let publisher = priority.publisher(remote: {
            self.webServices.providersIndex()
        }, bundle: {
            self.bundleServices.providersIndex()
        })

        return publisher
            .receive(on: DispatchQueue.main)
            .tryMap { index in
                self.saveLastAction(self.indexActionName)
                try self.providerRepository.mergeIndex(index)

                self.didUpdateProviders.send()
            }.eraseToAnyPublisher()
    }

    public func fetchProviderPublisher(withName providerName: ProviderName, vpnProtocol: VPNProtocolType, priority: ProviderManagerFetchPriority) -> AnyPublisher<Void, Error> {
        guard !isRateLimited(providerName) else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let publisher = priority.publisher(remote: {
            let ifModifiedSince = self.infrastructureRepository.lastInfrastructureUpdate(withName: providerName, vpnProtocol: vpnProtocol)
            return self.webServices.providerNetwork(
                with: providerName.asWSProviderName,
                vpnProtocol: vpnProtocol.asWSVPNProtocol,
                ifModifiedSince: ifModifiedSince
            )
        }, bundle: {
            self.bundleServices.providerNetwork(
                with: providerName.asWSProviderName,
                vpnProtocol: vpnProtocol.asWSVPNProtocol,
                ifModifiedSince: nil
            )
        })

        return publisher
            .receive(on: DispatchQueue.main)
            .flatMap { pub -> AnyPublisher<Void, Error> in
                self.saveLastAction(providerName)

                // ignores empty responses (e.g. HTTP 304)
                guard let infrastructure = pub.value else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                guard self.appBuild >= infrastructure.build else {
                    pp_log.error("Infrastructure requires app build >= \(infrastructure.build) (app is \(self.appBuild))")
                    return Fail(error: ProviderManagerError.outdatedBuild(self.appBuild, infrastructure.build))
                        .eraseToAnyPublisher()
                }

                do {
                    try self.infrastructureRepository.saveInfrastructure(
                        infrastructure,
                        vpnProtocol: vpnProtocol,
                        lastUpdate: pub.lastModified ?? Date()
                    )

                    self.didUpdateProviders.send()
                } catch {
                    pp_log.error("Unable to persist \(providerName) infrastructure (\(vpnProtocol)): \(error)")
                }
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    public func reset() {
        persistence.truncate()

        didUpdateProviders.send()
    }

    // MARK: RateLimited

    private let indexActionName = ""

    public var lastActionDate: [String: Date] = [:]

    public var rateLimitMilliseconds: Int?
}

private enum ProviderManagerError: LocalizedError {
    case outdatedBuild(Int, Int)

    var errorDescription: String? {
        switch self {
        case .outdatedBuild(let current, let min):
            return "Build is outdated (found \(current), required \(min))"
        }
    }
}

private extension ProviderManagerFetchPriority {
    func publisher<T>(
        remote: @escaping () -> AnyPublisher<T, Error>,
        bundle: @escaping () -> AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        switch self {
        case .bundle:
            return bundle()

        case .remote:
            return remote()

        case .remoteThenBundle:
            return remote()
                .catch { error -> AnyPublisher<T, Error> in
                    pp_log.warning("Unable to fetch remotely: \(error)")
                    pp_log.warning("Falling back to bundle")
                    return bundle()
                }.eraseToAnyPublisher()
        }
    }
}

private extension ProviderName {
    var asWSProviderName: WSProviderName {
        self
    }
}

private extension VPNProtocolType {
    var asWSVPNProtocol: WSVPNProtocol {
        switch self {
        case .openVPN:
            return .openVPN

        case .wireGuard:
            return .wireGuard
        }
    }
}
