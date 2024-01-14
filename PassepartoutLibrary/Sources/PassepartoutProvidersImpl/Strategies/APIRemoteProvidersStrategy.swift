//
//  APIRemoteProvidersStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/24/23.
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
import CoreData
import Foundation
import PassepartoutCore
import PassepartoutProviders
import PassepartoutServices

public final class APIRemoteProvidersStrategy: RemoteProvidersStrategy {
    private let appBuild: Int

    private let bundleServices: WebServices

    private let remoteServices: WebServices

    private let webServicesRepository: WebServicesRepository

    public init(appBuild: Int, bundleServices: WebServices, remoteServices: WebServices, webServicesRepository: WebServicesRepository) {
        self.appBuild = appBuild
        self.bundleServices = bundleServices
        self.remoteServices = remoteServices
        self.webServicesRepository = webServicesRepository
    }

    public func saveIndex(
        priority: RemoteProvidersPriority,
        onFetch: @escaping () -> Void
    ) -> AnyPublisher<Void, Error> {
        let publisher = priority.publisher(remote: {
            self.remoteServices.providersIndex()
        }, bundle: {
            self.bundleServices.providersIndex()
        })

        return publisher
            .receive(on: DispatchQueue.main)
            .tryMap { index in
                onFetch()
                try self.webServicesRepository.mergeIndex(index)
            }.eraseToAnyPublisher()
    }

    public func saveProvider(
        withName providerName: ProviderName,
        vpnProtocol: VPNProtocolType,
        lastUpdate: Date?,
        priority: RemoteProvidersPriority,
        onFetch: @escaping () -> Void
    ) -> AnyPublisher<Void, Error> {
        let publisher = priority.publisher(remote: {
            self.remoteServices.providerNetwork(
                with: providerName.asWSProviderName,
                vpnProtocol: vpnProtocol.asWSVPNProtocol,
                ifModifiedSince: lastUpdate
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
                onFetch()

                // ignores empty responses (e.g. HTTP 304)
                guard let infrastructure = pub.value else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                guard self.appBuild >= infrastructure.build else {
                    pp_log.error("Infrastructure requires app build >= \(infrastructure.build) (app is \(self.appBuild))")
                    return Fail(error: APIRemoteProvidersStrategyError.outdatedBuild(self.appBuild, infrastructure.build))
                        .eraseToAnyPublisher()
                }

                do {
                    try self.webServicesRepository.saveInfrastructure(
                        infrastructure,
                        vpnProtocol: vpnProtocol,
                        lastUpdate: pub.lastModified ?? Date()
                    )
                } catch {
                    pp_log.error("Unable to persist \(providerName) infrastructure (\(vpnProtocol)): \(error)")
                }
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

private extension RemoteProvidersPriority {
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
private enum APIRemoteProvidersStrategyError: LocalizedError {
    case outdatedBuild(Int, Int)

    var errorDescription: String? {
        switch self {
        case .outdatedBuild(let current, let min):
            return "Build is outdated (found \(current), required \(min))"
        }
    }
}
