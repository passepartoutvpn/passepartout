//
//  ExtendedTunnelTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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

import Combine
@testable import CommonLibrary
import Foundation
import XCTest

final class ExtendedTunnelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable> = []
}

@MainActor
extension ExtendedTunnelTests {
    func test_givenTunnel_whenDisconnectWithError_thenPublishesLastErrorCode() async throws {
        let env = SharedTunnelEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy()) { _ in
            env
        }
        let sut = ExtendedTunnel(tunnel: tunnel, interval: 0.1)

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.connect(with: profile)
        env.setEnvironmentValue(.crypto, forKey: TunnelEnvironmentKeys.lastErrorCode)

        let exp = expectation(description: "Last error code")
        var didCall = false
        sut
            .objectWillChange
            .sink {
                if !didCall, sut.lastErrorCode(ofProfileId: profile.id) != nil {
                    didCall = true
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)

        try await tunnel.disconnect(from: profile.id)
        await fulfillment(of: [exp], timeout: CommonLibraryTests.timeout)
        XCTAssertEqual(sut.lastErrorCode(ofProfileId: profile.id), .crypto)
    }

    func test_givenTunnel_whenPublishesDataCount_thenIsAvailable() async throws {
        let env = SharedTunnelEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy()) { _ in
            env
        }
        let sut = ExtendedTunnel(tunnel: tunnel, interval: 0.1)
        let dataCount = DataCount(500, 700)

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.install(profile)

        env.setEnvironmentValue(dataCount, forKey: TunnelEnvironmentKeys.dataCount)
        XCTAssertEqual(sut.dataCount(ofProfileId: profile.id), dataCount)
    }

    func test_givenTunnelAndProcessor_whenInstall_thenProcessesProfile() async throws {
        let env = SharedTunnelEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy()) { _ in
            env
        }
        let processor = MockTunnelProcessor()
        let sut = ExtendedTunnel(tunnel: tunnel, processor: processor, interval: 0.1)

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.install(profile)

        await sut.activeProfilesStream.waitForNext()
        XCTAssertEqual(tunnel.activeProfiles.first?.key, profile.id)
//        XCTAssertEqual(processor.titleCount, 1) // unused by FakeTunnelStrategy
        XCTAssertEqual(processor.willInstallCount, 1)
    }

    func test_givenTunnel_whenStatusChanges_thenConnectionStatusIsExpected() async throws {
        let env = SharedTunnelEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy()) { _ in
            env
        }
        let processor = MockTunnelProcessor()
        let sut = ExtendedTunnel(tunnel: tunnel, processor: processor, interval: 0.1)
        let stream = sut.activeProfilesStream

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.install(profile)

        await stream.waitForNext() // include initial nil
        await stream.waitForNext()
        XCTAssertEqual(tunnel.activeProfiles.first?.key, profile.id)
//        XCTAssertEqual(processor.titleCount, 1) // unused by FakeTunnelStrategy
        XCTAssertEqual(processor.willInstallCount, 1)
    }

    func test_givenTunnelStatus_thenConnectionStatusIsExpected() async throws {
        let allTunnelStatuses: [TunnelStatus] = [
            .inactive,
            .activating,
            .active,
            .deactivating
        ]
        let allConnectionStatuses: [ConnectionStatus] = [
            .disconnected,
            .connecting,
            .connected,
            .disconnecting
        ]

        let env = SharedTunnelEnvironment()
        let key = TunnelEnvironmentKeys.connectionStatus

        // no connection status, tunnel status unaffected
        allTunnelStatuses.forEach {
            XCTAssertEqual($0.withEnvironment(env), $0)
        }

        // has connection status

        // affected if .active
        let tunnelActive: TunnelStatus = .active
        env.setEnvironmentValue(ConnectionStatus.connected, forKey: key)
        XCTAssertEqual(tunnelActive.withEnvironment(env), .active)
        allConnectionStatuses
            .forEach {
                env.setEnvironmentValue($0, forKey: key)
                let statusWithEnv = tunnelActive.withEnvironment(env)
                switch $0 {
                case .connecting:
                    XCTAssertEqual(statusWithEnv, .activating)
                case .connected:
                    XCTAssertEqual(statusWithEnv, .active)
                case .disconnecting:
                    XCTAssertEqual(statusWithEnv, .deactivating)
                case .disconnected:
                    XCTAssertEqual(statusWithEnv, .inactive)
                }
            }

        // unaffected otherwise
        allTunnelStatuses
            .filter {
                $0 != .active
            }
            .forEach {
                XCTAssertEqual($0.withEnvironment(env), $0)
            }
    }
}
