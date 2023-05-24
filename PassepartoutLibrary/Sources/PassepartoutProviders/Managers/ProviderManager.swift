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

import Combine
import Foundation
import PassepartoutCore
import PassepartoutServices

public final class ProviderManager: ObservableObject, RateLimited {
    public enum FetchPriority {
        case bundle

        case remote

        case remoteThenBundle
    }

    private let appBuild: Int

    private let bundleServices: WebServices

    private let webServices: WebServices

    private let webServicesRepository: WebServicesRepository

    private let localProvidersRepository: LocalProvidersRepository

    public let didUpdateProviders = PassthroughSubject<Void, Never>()

    public init(
        appBuild: Int,
        bundleServices: WebServices,
        webServices: WebServices,
        webServicesRepository: WebServicesRepository,
        localProvidersRepository: LocalProvidersRepository
    ) {
        self.appBuild = appBuild
        self.bundleServices = bundleServices
        self.webServices = webServices
        self.webServicesRepository = webServicesRepository
        self.localProvidersRepository = localProvidersRepository

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

    public func fetchProvidersIndexPublisher(priority: FetchPriority) -> AnyPublisher<Void, Error> {
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
                try self.webServicesRepository.mergeIndex(index)

                self.didUpdateProviders.send()
            }.eraseToAnyPublisher()
    }

    public func fetchProviderPublisher(withName providerName: ProviderName, vpnProtocol: VPNProtocolType, priority: FetchPriority) -> AnyPublisher<Void, Error> {
        guard !isRateLimited(providerName) else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let publisher = priority.publisher(remote: {
            let ifModifiedSince = self.localProvidersRepository.lastInfrastructureUpdate(withName: providerName, vpnProtocol: vpnProtocol)
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
                    try self.webServicesRepository.saveInfrastructure(
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

    // MARK: RateLimited

    private let indexActionName = ""

    public var lastActionDate: [String: Date] = [:]

    public var rateLimitMilliseconds: Int?
}

// MARK: Private extensions

private enum ProviderManagerError: LocalizedError {
    case outdatedBuild(Int, Int)

    var errorDescription: String? {
        switch self {
        case .outdatedBuild(let current, let min):
            return "Build is outdated (found \(current), required \(min))"
        }
    }
}

private extension ProviderManager.FetchPriority {
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
