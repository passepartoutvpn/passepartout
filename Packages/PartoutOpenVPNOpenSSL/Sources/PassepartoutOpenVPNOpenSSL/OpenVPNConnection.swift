//
//  OpenVPNConnection.swift
//  Partout
//
//  Created by Davide De Rosa on 3/15/24.
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

import Combine
import Foundation
import Partout

public actor OpenVPNConnection {

    // MARK: Initialization

    private let moduleId: UUID

    private let controller: TunnelController

    private let environment: TunnelEnvironment

    private let options: ConnectionParameters.Options

    private let configuration: OpenVPN.Configuration

    // MARK: State

    let backend: CyclingConnection

    let session: OpenVPNSessionProtocol

    init(
        parameters: ConnectionParameters,
        module: OpenVPNModule,
        prng: PRNGProtocol,
        dns: DNSResolver,
        session: OpenVPNSessionProtocol
    ) async throws {
        moduleId = module.id
        controller = parameters.controller
        environment = parameters.environment
        options = parameters.options

        guard let configuration = module.configuration else {
            fatalError("No OpenVPN configuration defined?")
        }
        guard let endpoints = configuration.processedRemotes(prng: prng),
              !endpoints.isEmpty else {
            fatalError("No OpenVPN remotes defined?")
        }

        self.configuration = try configuration.withModules(from: parameters.controller.profile)

        backend = CyclingConnection(
            factory: parameters.factory,
            controller: controller,
            options: options,
            endpoints: endpoints
        )

        self.session = session

        // post-configuration

        let hooks = CyclingConnection.Hooks(dns: dns) { newLink in

            // wrap new link into a specific OpenVPN link
            newLink.openVPNLink(xorMethod: configuration.xorMethod)

        } startBlock: { [weak self] newLink in

            try await self?.session.setLink(newLink)

        } upgradeBlock: { [weak self] in

            // TODO: ###, may improve this with floating
            pp_log(.openvpn, .notice, "Link has a better path, shut down session to reconnect")
            await self?.session.shutdown(PartoutError(.networkChanged))

        } stopBlock: { [weak self] _, timeout in

            guard let session = await self?.session else {
                return
            }

            // stop the OpenVPN connection on user request
            await session.shutdown(nil, timeout: TimeInterval(timeout) / 1000.0)

            // XXX: poll session status until link clean-up
            // in the future, make OpenVPNSession.shutdown() wait for stop async-ly
            let delta = 500
            var remaining = timeout
            while remaining > 0, await session.hasLink() {
                pp_log(.openvpn, .notice, "Link active, wait \(delta) milliseconds more")
                try? await Task.sleep(milliseconds: delta)
                remaining = max(0, remaining - delta)
            }
            if remaining > 0 {
                pp_log(.openvpn, .notice, "Link shut down gracefully")
            } else {
                pp_log(.openvpn, .error, "Link shut down due to timeout")
            }
        } onStatusBlock: { [weak self] status in

            self?.onStatus(status)

        } onErrorBlock: { [weak self] error in

            self?.onError(error)
        }

        await backend.setHooks(hooks)
        await session.setDelegate(self)

        // set this once
        guard let tunnelInterface = parameters.factory.tunnelInterface() else {
            throw PartoutError(.releasedObject)
        }
        await session.setTunnel(tunnelInterface)
    }
}

// MARK: - Connection

extension OpenVPNConnection: Connection {
    public nonisolated var statusPublisher: AnyPublisher<ConnectionStatus, Error> {
        backend.statusPublisher
    }

    @discardableResult
    public func start() async throws -> Bool {
        do {
            return try await backend.start()
        } catch let error as PartoutError {
            if error.code == .exhaustedEndpoints, let reason = error.reason {
                throw reason
            }
            throw error
        }
    }

    public func stop(timeout: Int) async {
        await backend.stop(timeout: timeout)
    }
}

// MARK: - OpenVPNSessionDelegate

extension OpenVPNConnection: OpenVPNSessionDelegate {
    func sessionDidStart(_ session: OpenVPNSessionProtocol, remoteAddress: String, remoteProtocol: EndpointProtocol, remoteOptions: OpenVPN.Configuration) async {
        let addressObject = Address(rawValue: remoteAddress)
        if addressObject == nil {
            pp_log(.openvpn, .error, "Unable to parse remote tunnel address")
        }

        pp_log(.openvpn, .notice, "Session did start")
        pp_log(.openvpn, .info, "\tAddress: \(remoteAddress.asSensitiveAddress)")
        pp_log(.openvpn, .info, "\tProtocol: \(remoteProtocol)")

        pp_log(.openvpn, .notice, "Local options:")
        configuration.print(isLocal: true)
        pp_log(.openvpn, .notice, "Remote options:")
        remoteOptions.print(isLocal: false)

        environment.setEnvironmentValue(remoteOptions, forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration)

        let builder = NetworkSettingsBuilder(localOptions: configuration, remoteOptions: remoteOptions)
        builder.print()
        do {
            try await controller.setTunnelSettings(with: TunnelRemoteInfo(
                originalModuleId: moduleId,
                address: addressObject,
                modules: builder.modules()
            ))

            // in this suspended interval, sessionDidStop may have been called and
            // the status may have changed to .disconnected in the meantime
            //
            // sendStatus() should prevent .connected from happening when in the
            // .disconnected state, because it must go through .connecting first

            // signal success and show the "VPN" icon
            if await backend.sendStatus(.connected) {
                pp_log(.openvpn, .notice, "Tunnel interface is now UP")
            }
        } catch {
            pp_log(.openvpn, .error, "Unable to start tunnel: \(error)")
            await session.shutdown(error)
        }
    }

    func sessionDidStop(_ session: OpenVPNSessionProtocol, withError error: Error?) async {
        if let error {
            pp_log(.openvpn, .error, "Session did stop: \(error)")
        } else {
            pp_log(.openvpn, .notice, "Session did stop")
        }

        // if user stopped the tunnel, let it go
        if await backend.status == .disconnecting {
            pp_log(.openvpn, .info, "User requested disconnection")
            return
        }

        // if error is not recoverable, just fail
        if let error, !error.isOpenVPNRecoverable {
            pp_log(.openvpn, .error, "Disconnection is not recoverable")
            await backend.sendError(error)
            return
        }

        // go back to the disconnected state (e.g. daemon will reconnect)
        await backend.sendStatus(.disconnected)
    }

    func session(_ session: OpenVPNSessionProtocol, didUpdateDataCount dataCount: DataCount) async {
        guard await backend.status == .connected else {
            return
        }
        pp_log(.openvpn, .debug, "Updated data count: \(dataCount.debugDescription)")
        environment.setEnvironmentValue(dataCount, forKey: TunnelEnvironmentKeys.dataCount)
    }
}

// MARK: - Helpers

private extension OpenVPN.Configuration {
    func withModules(from profile: Profile) throws -> Self {
        var newBuilder = builder()
        let ipModules = profile.activeModules
            .compactMap {
                $0 as? IPModule
            }

        ipModules.forEach { ipModule in
            var policies = newBuilder.routingPolicies ?? []
            if !policies.contains(.IPv4), ipModule.shouldAddIPv4Policy {
                policies.append(.IPv4)
            }
            if !policies.contains(.IPv6), ipModule.shouldAddIPv6Policy {
                policies.append(.IPv6)
            }
            newBuilder.routingPolicies = policies
        }
        return try newBuilder.tryBuild(isClient: true)
    }
}

private extension IPModule {
    var shouldAddIPv4Policy: Bool {
        guard let ipv4 else {
            return false
        }
        let defaultRoute = Route(defaultWithGateway: nil)
        return ipv4.includedRoutes.contains(defaultRoute) && !ipv4.excludedRoutes.contains(defaultRoute)
    }

    var shouldAddIPv6Policy: Bool {
        guard let ipv6 else {
            return false
        }
        let defaultRoute = Route(defaultWithGateway: nil)
        return ipv6.includedRoutes.contains(defaultRoute) && !ipv6.excludedRoutes.contains(defaultRoute)
    }
}

private extension OpenVPNConnection {
    nonisolated func onStatus(_ connectionStatus: ConnectionStatus) {
        switch connectionStatus {
        case .connected:
            break

        case .disconnected:
            environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.dataCount)
            environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration)

        default:
            break
        }
    }

    nonisolated func onError(_ connectionError: Error) {
        environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.dataCount)
        environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration)
    }
}

private extension LinkInterface {
    func openVPNLink(xorMethod: OpenVPN.XORMethod?) -> LinkInterface {
        switch linkType.plainType {
        case .udp:
            return OpenVPNUDPLink(link: self, xorMethod: xorMethod)

        case .tcp:
            return OpenVPNTCPLink(link: self, xorMethod: xorMethod)
        }
    }
}

private let ppRecoverableCodes: [PartoutError.Code] = [
    .timeout,
    .linkFailure,
    .networkChanged,
    .OpenVPN.connectionFailure,
    .OpenVPN.serverShutdown
]

extension Error {
    var isOpenVPNRecoverable: Bool {
        let ppError = PartoutError(self)
        if ppRecoverableCodes.contains(ppError.code) {
            return true
        }
        if case .recoverable = ppError.reason as? OpenVPNSessionError {
            return true
        }
        return false
    }
}
