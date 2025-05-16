//
//  ExtendedTunnel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonUtils
import Foundation

@MainActor
public final class ExtendedTunnel: ObservableObject {
    public static nonisolated let isManualKey = "isManual"

    private let tunnel: Tunnel

    private let kvStore: KeyValueManager?

    private let processor: AppTunnelProcessor?

    private let interval: TimeInterval

    private var subscriptions: [Task<Void, Never>]

    // FIXME: #218, keep "last used profile" until .multiple
    public init(
        tunnel: Tunnel,
        kvStore: KeyValueManager? = nil,
        processor: AppTunnelProcessor? = nil,
        interval: TimeInterval
    ) {
        self.tunnel = tunnel
        self.kvStore = kvStore
        self.processor = processor
        self.interval = interval
        subscriptions = []

        observeObjects()
    }
}

// MARK: - Public interface

extension ExtendedTunnel {
    public func install(_ profile: Profile) async throws {
        pp_log_g(.app, .notice, "Install profile \(profile.id)...")
        let newProfile = try await processedProfile(profile)
        try await tunnel.install(
            newProfile,
            connect: false,
            options: .init(values: [Self.isManualKey: true as NSNumber]),
            title: processedTitle
        )
    }

    public func connect(with profile: Profile, force: Bool = false) async throws {
        pp_log_g(.app, .notice, "Connect to profile \(profile.id)...")
        let newProfile = try await processedProfile(profile)
        if !force && newProfile.isInteractive {
            throw AppError.interactiveLogin
        }
        try await tunnel.install(
            newProfile,
            connect: true,
            options: .init(values: [Self.isManualKey: true as NSNumber]),
            title: processedTitle
        )
    }

    public func disconnect(from profileId: Profile.ID) async throws {
        pp_log_g(.app, .notice, "Disconnect...")
        try await tunnel.disconnect(from: profileId)
    }

    // FIXME: #1373, diagnostics/logs must be per-tunnel
    public func currentLog(parameters: Constants.Log) async -> [String] {
        guard let anyProfile = tunnel.activeProfiles.first?.value else {
            return []
        }
        let output = try? await tunnel.sendMessage(.debugLog(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.options.maxLevel
        ), to: anyProfile.id)
        switch output {
        case .debugLog(let log):
            return log.lines.map(parameters.formatter.formattedLine)
        default:
            return []
        }
    }
}

extension ExtendedTunnel {
#if os(iOS) || os(tvOS)
    public var activeProfile: TunnelActiveProfile? {
        tunnel.activeProfile
    }
#endif
    public var activeProfiles: [Profile.ID: TunnelActiveProfile] {
        guard !tunnel.activeProfiles.isEmpty else {
            if let last = lastUsedProfile {
                return [last.id: last]
            }
            return [:]
        }
        return tunnel.activeProfiles
    }

    public var activeProfilesStream: AsyncStream<[Profile.ID: TunnelActiveProfile]> {
        tunnel.activeProfilesStream
    }

    public func isActiveProfile(withId profileId: Profile.ID) -> Bool {
        tunnel.activeProfiles.keys.contains(profileId)
    }

    public func status(ofProfileId profileId: Profile.ID) -> TunnelStatus {
        activeProfiles[profileId]?.status ?? .inactive
    }

    public func connectionStatus(ofProfileId profileId: Profile.ID) -> TunnelStatus {
        let status = status(ofProfileId: profileId)
        guard let environment = tunnel.environment(for: profileId) else {
            return status
        }
        return status.withEnvironment(environment)
    }

    public func dataCount(ofProfileId profileId: Profile.ID) -> DataCount? {
        tunnel
            .environment(for: profileId)?
            .environmentValue(forKey: TunnelEnvironmentKeys.dataCount)
    }

    public func lastErrorCode(ofProfileId profileId: Profile.ID) -> PartoutError.Code? {
        tunnel
            .environment(for: profileId)?
            .environmentValue(forKey: TunnelEnvironmentKeys.lastErrorCode)
    }

    public func value<T>(forKey key: TunnelEnvironmentKey<T>, ofProfileId profileId: Profile.ID) -> T? where T: Decodable {
        tunnel
            .environment(for: profileId)?
            .environmentValue(forKey: key)
    }
}

// MARK: - Observation

private extension ExtendedTunnel {
    func observeObjects() {
        let tunnelSubscription = Task { [weak self] in
            guard let self else {
                return
            }
            for await newActiveProfiles in tunnel.activeProfilesStream.removeDuplicates() {
                guard !Task.isCancelled else {
                    pp_log_g(.app, .debug, "Cancelled ExtendedTunnel.tunnelSubscription")
                    break
                }
                objectWillChange.send()

                // FIXME: #218, keep "last used profile" until .multiple
                if let first = newActiveProfiles.first {
                    kvStore?.set(first.key.uuidString, forKey: AppPreference.lastUsedProfileId.key)
                }
            }
        }

        let timerSubscription = Task { [weak self] in
            while true {
                guard let self else {
                    return
                }
                guard !Task.isCancelled else {
                    pp_log_g(.app, .debug, "Cancelled ExtendedTunnel.timerSubscription")
                    break
                }
                objectWillChange.send()

                try? await Task.sleep(interval: interval)
            }
        }

        subscriptions = [tunnelSubscription, timerSubscription]
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

    func processedProfile(_ profile: Profile) async throws -> Profile {
        if let processor {
            return try await processor.willInstall(profile)
        }
        return profile
    }
}

// MARK: - Helpers

// FIXME: #218, keep "last used profile" until .multiple
private extension ExtendedTunnel {
    var lastUsedProfile: TunnelActiveProfile? {
        guard let uuidString = kvStore?.string(forKey: AppPreference.lastUsedProfileId.key),
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return TunnelActiveProfile(
            id: uuid,
            status: .inactive,
            onDemand: false
        )
    }
}

extension TunnelStatus {
    func withEnvironment(_ environment: TunnelEnvironmentReader) -> TunnelStatus {
        var status = self
        if status == .active, let connectionStatus = environment.environmentValue(forKey: TunnelEnvironmentKeys.connectionStatus) {
            switch connectionStatus {
            case .connecting:
                status = .activating
            case .connected:
                status = .active
            case .disconnecting:
                status = .deactivating
            case .disconnected:
                status = .inactive
            }
        }
        return status
    }
}
