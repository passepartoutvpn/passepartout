//
//  ExtendedTunnel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
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
import PassepartoutKit

@MainActor
public final class ExtendedTunnel: ObservableObject {
    private let tunnel: Tunnel

    private let environment: TunnelEnvironment

    private let processor: TunnelProcessor?

    private let interval: TimeInterval

    public func value<T>(forKey key: TunnelEnvironmentKey<T>) -> T? where T: Decodable {
        environment.environmentValue(forKey: key)
    }

    @Published
    public private(set) var lastErrorCode: PassepartoutError.Code? {
        didSet {
            pp_log(.app, .info, "ExtendedTunnel.lastErrorCode -> \(lastErrorCode?.rawValue ?? "nil")")
        }
    }

    @Published
    public private(set) var dataCount: DataCount?

    private var subscriptions: Set<AnyCancellable>

    public init(
        tunnel: Tunnel,
        environment: TunnelEnvironment,
        processor: TunnelProcessor? = nil,
        interval: TimeInterval
    ) {
        self.tunnel = tunnel
        self.environment = environment
        self.processor = processor
        self.interval = interval
        subscriptions = []

        observeObjects()
    }
}

// MARK: - Public interface

extension ExtendedTunnel {
    public var status: TunnelStatus {
        tunnel.status
    }

    public var connectionStatus: TunnelStatus {
        tunnel.status.withEnvironment(environment)
    }
}

extension ExtendedTunnel {
    public var currentProfile: TunnelCurrentProfile? {
        tunnel.currentProfile
    }

    public var currentProfilePublisher: AnyPublisher<TunnelCurrentProfile?, Never> {
        tunnel
            .$currentProfile
            .eraseToAnyPublisher()
    }

    public func install(_ profile: Profile) async throws {
        pp_log(.app, .notice, "Install profile \(profile.id)...")
        let newProfile = try processedProfile(profile)
        try await tunnel.install(newProfile, connect: false, title: processedTitle)
    }

    public func connect(with profile: Profile, force: Bool = false) async throws {
        pp_log(.app, .notice, "Connect to profile \(profile.id)...")
        let newProfile = try processedProfile(profile)
        if !force && newProfile.isInteractive {
            throw AppError.interactiveLogin
        }
        try await tunnel.install(newProfile, connect: true, title: processedTitle)
    }

    public func disconnect() async throws {
        pp_log(.app, .notice, "Disconnect...")
        try await tunnel.disconnect()
    }

    public func currentLog(parameters: Constants.Log) async -> [String] {
        let output = try? await tunnel.sendMessage(.localLog(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.maxLevel
        ))
        switch output {
        case .debugLog(let log):
            return log.lines.map(parameters.formatter.formattedLine)

        default:
            return []
        }
    }
}

// MARK: - Observation

private extension ExtendedTunnel {
    func observeObjects() {
        tunnel
            .$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else {
                    return
                }
                switch $0 {
                case .activating:
                    lastErrorCode = nil

                default:
                    lastErrorCode = value(forKey: TunnelEnvironmentKeys.lastErrorCode)
                }
                if $0 != .active {
                    dataCount = nil
                }
            }
            .store(in: &subscriptions)

        tunnel
            .$currentProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)

        Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                guard tunnel.status == .active else {
                    return
                }
                dataCount = value(forKey: TunnelEnvironmentKeys.dataCount)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Processing

private extension ExtendedTunnel {
    var processedTitle: (Profile) -> String {
        if let processor {
            return processor.title
        }
        return \.name
    }

    func processedProfile(_ profile: Profile) throws -> Profile {
        if let processor {
            return try processor.willInstall(profile)
        }
        return profile
    }
}

// MARK: - Helpers

extension TunnelStatus {
    public func withEnvironment(_ environment: TunnelEnvironment) -> TunnelStatus {
        var status = self
        if status == .active, let connectionStatus = environment.environmentValue(forKey: TunnelEnvironmentKeys.connectionStatus) {
            if connectionStatus == .connected {
                status = .active
            } else {
                status = .activating
            }
        }
        return status
    }
}
