//
//  WireGuardConnection.swift
//  Partout
//
//  Created by Davide De Rosa on 3/31/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//  SPDX-License-Identifier: MIT
//  Copyright © 2018-2024 WireGuard LLC. All Rights Reserved.

import Combine
import Foundation
import NetworkExtension
import Partout
import os
internal import WireGuardKit
internal import WireGuardKitGo

public final class WireGuardConnection: Connection {
    private let statusSubject: CurrentValueSubject<ConnectionStatus, Error>

    private let moduleId: UUID

    private let controller: TunnelController

    private let environment: TunnelEnvironment

    private let tunnelConfiguration: TunnelConfiguration

    private var dataCountTimer: AnyCancellable?

    private lazy var adapter: WireGuardAdapter = {
        WireGuardAdapter(with: delegate, backend: WireGuardBackendGo()) { logLevel, message in
            pp_log(.wireguard, osLogLevel: logLevel.osLogLevel, message)
        }
    }()

    private lazy var delegate: WireGuardAdapterDelegate = AdapterDelegate(connection: self)

    public init(
        parameters: ConnectionParameters,
        module: WireGuardModule
    ) throws {
        statusSubject = CurrentValueSubject(.disconnected)
        moduleId = module.id
        controller = parameters.controller
        environment = parameters.environment

        guard let configuration = module.configuration else {
            fatalError("No WireGuard configuration defined?")
        }

        let tweakedConfiguration = try configuration.withModules(from: parameters.controller.profile)
        tunnelConfiguration = try tweakedConfiguration.toWireGuardConfiguration()

        let interval = TimeInterval(parameters.options.minDataCountInterval) / 1000.0
        dataCountTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.onDataCountTimer()
            }
    }

    public var statusPublisher: AnyPublisher<ConnectionStatus, Error> {
        statusSubject.eraseToAnyPublisher()
    }

    public func start() async throws -> Bool {
        pp_log(.wireguard, .info, "Start tunnel")
        statusSubject.send(.connecting)

        do {
            try await withUnsafeThrowingContinuation { [weak self] continuation in
                guard let self else {
                    continuation.resume()
                    return
                }
                adapter.start(tunnelConfiguration: tunnelConfiguration) { [weak self] adapterError in
                    guard let self else {
                        continuation.resume()
                        return
                    }
                    if let adapterError {
                        switch adapterError {
                        case .cannotLocateTunnelFileDescriptor:
                            pp_log(.wireguard, .error, "Starting tunnel failed: could not determine file descriptor")
                            continuation.resume(throwing: WireGuardConnectionError.couldNotDetermineFileDescriptor)

                        case .dnsResolution(let dnsErrors):
                            let hostnamesWithDnsResolutionFailure = dnsErrors.map(\.address)
                                .joined(separator: ", ")
                            pp_log(.wireguard, .error, "DNS resolution failed for the following hostnames: \(hostnamesWithDnsResolutionFailure)")
                            continuation.resume(throwing: WireGuardConnectionError.dnsResolutionFailure)

                        case .setNetworkSettings(let error):
                            pp_log(.wireguard, .error, "Starting tunnel failed with setTunnelNetworkSettings returning \(error.localizedDescription)")
                            continuation.resume(throwing: WireGuardConnectionError.couldNotSetNetworkSettings)

                        case .startWireGuardBackend(let errorCode):
                            pp_log(.wireguard, .error, "Starting tunnel failed with wgTurnOn returning \(errorCode)")
                            continuation.resume(throwing: WireGuardConnectionError.couldNotStartBackend)

                        case .invalidState:
                            // Must never happen
                            fatalError()
                        }
                        return
                    }
                    let interfaceName = self.adapter.interfaceName ?? "unknown"
                    pp_log(.wireguard, .info, "Tunnel interface is \(interfaceName)")
                    continuation.resume()
                }
            }
            return true
        } catch {
            statusSubject.send(.disconnected)
            throw error
        }
    }

    public func stop(timeout: Int) async {
        pp_log(.wireguard, .info, "Stop tunnel")
        statusSubject.send(.disconnecting)

        // TODO: #2, handle WireGuard adapter timeout

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
            self.adapter.stop { error in
                if let error {
                    pp_log(.wireguard, .error, "Unable to stop WireGuard adapter: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
        statusSubject.send(.disconnected)
    }
}

// MARK: - WireGuardAdapterDelegate

private extension WireGuardConnection {
    final class AdapterDelegate: WireGuardAdapterDelegate {
        private weak var connection: WireGuardConnection?

        init(connection: WireGuardConnection) {
            self.connection = connection
        }

        func adapterShouldReassert(_ adapter: WireGuardAdapter, reasserting: Bool) {
            if reasserting {
                connection?.statusSubject.send(.connecting)
            }
        }

        func adapterShouldSetNetworkSettings(_ adapter: WireGuardAdapter, settings: NEPacketTunnelNetworkSettings, completionHandler: ((Error?) -> Void)?) {
            guard let connection else {
                pp_log(.wireguard, .error, "Lost weak reference to connection?")
                return
            }
            let module = NESettingsModule(fullSettings: settings)
            let addressObject = Address(rawValue: settings.tunnelRemoteAddress)
            if addressObject == nil {
                pp_log(.wireguard, .error, "Unable to parse remote tunnel address")
            }

            Task {
                do {
                    try await connection.controller.setTunnelSettings(with: TunnelRemoteInfo(
                        originalModuleId: connection.moduleId,
                        address: addressObject,
                        modules: [module]
                    ))
                    completionHandler?(nil)
                    pp_log(.wireguard, .info, "Tunnel interface is now UP")
                    connection.statusSubject.send(.connected)
                } catch {
                    completionHandler?(error)
                    pp_log(.wireguard, .error, "Unable to configure tunnel settings: \(error)")
                    connection.statusSubject.send(.disconnected)
                }
            }
        }
    }
}

// MARK: - Data count

private extension WireGuardConnection {
    func onDataCountTimer() {
        guard statusSubject.value == .connected else {
            return
        }
        adapter.getRuntimeConfiguration { [weak self] configurationString in
            guard let configurationString = configurationString,
                  let dataCount = DataCount.from(wireGuardString: configurationString) else {
                return
            }
            self?.environment.setEnvironmentValue(dataCount, forKey: TunnelEnvironmentKeys.dataCount)
        }
    }
}

private extension DataCount {
    static func from(wireGuardString string: String) -> DataCount? {
        var bytesReceived: UInt?
        var bytesSent: UInt?

        string.enumerateLines { line, stop in
            if bytesReceived == nil, let value = line.getPrefix("rx_bytes=") {
                bytesReceived = value
            } else if bytesSent == nil, let value = line.getPrefix("tx_bytes=") {
                bytesSent = value
            }
            if bytesReceived != nil, bytesSent != nil {
                stop = true
            }
        }

        guard let bytesReceived, let bytesSent else {
            return nil
        }

        return DataCount(bytesReceived, bytesSent)
    }
}

private extension String {
    func getPrefix(_ prefixKey: String) -> UInt? {
        guard hasPrefix(prefixKey) else {
            return nil
        }
        return UInt(dropFirst(prefixKey.count))
    }
}

// MARK: - Helpers

private extension WireGuard.Configuration {
    func withModules(from profile: Profile) throws -> Self {
        var newBuilder = builder()

        // add IPModule.*.includedRoutes to AllowedIPs
        profile.activeModules
            .compactMap {
                $0 as? IPModule
            }
            .forEach { ipModule in
                newBuilder.peers = peers
                    .map { oldPeer in
                        var peer = oldPeer.builder()
                        ipModule.ipv4?.includedRoutes.forEach { route in
                            peer.allowedIPs.append(route.destination?.rawValue ?? "0.0.0.0/0")
                        }
                        ipModule.ipv6?.includedRoutes.forEach { route in
                            peer.allowedIPs.append(route.destination?.rawValue ?? "::/0")
                        }
                        return peer
                    }
            }

        // if routesThroughVPN, add DNSModule.servers to AllowedIPs
        profile.activeModules
            .compactMap {
                $0 as? DNSModule
            }
            .filter {
                $0.routesThroughVPN == true
            }
            .forEach { dnsModule in
                newBuilder.peers = peers
                    .map { oldPeer in
                        var peer = oldPeer.builder()
                        dnsModule.servers.forEach {
                            switch $0 {
                            case .ip(let addr, let family):
                                switch family {
                                case .v4:
                                    peer.allowedIPs.append("\(addr)/32")
                                case .v6:
                                    peer.allowedIPs.append("\(addr)/128")
                                }
                            case .hostname:
                                break
                            }
                        }
                        return peer
                    }
            }

        return try newBuilder.tryBuild()
    }
}

private extension WireGuardLogLevel {
    var osLogLevel: OSLogType {
        switch self {
        case .verbose:
            return .debug

        case .error:
            return .error
        }
    }
}
