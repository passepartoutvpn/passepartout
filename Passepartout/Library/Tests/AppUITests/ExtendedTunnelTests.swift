//
//  ExtendedTunnelTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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

@testable import AppUI
import Foundation
import PassepartoutKit
import XCTest

final class ExtendedTunnelTests: XCTestCase {
}

@MainActor
extension ExtendedTunnelTests {
    func test_givenTunnel_whenDisconnectWithError_thenPublishesLastErrorCode() async throws {
        let env = InMemoryEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy(environment: env))
        let sut = ExtendedTunnel(tunnel: tunnel, environment: env, interval: 0.1)
        sut.observeObjects()

        let profile = try Profile.Builder().tryBuild()
        try await tunnel.install(profile, connect: true, title: \.name)
        env.setEnvironmentValue(.crypto, forKey: TunnelEnvironmentKeys.lastErrorCode)

        try await tunnel.disconnect()
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertEqual(sut.lastErrorCode, .crypto)
    }

    func test_givenTunnel_whenConnect_thenPublishesDataCount() async throws {
        let env = InMemoryEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy(environment: env))
        let sut = ExtendedTunnel(tunnel: tunnel, environment: env, interval: 0.1)
        sut.observeObjects()

        let profile = try Profile.Builder().tryBuild()
        try await tunnel.install(profile, connect: false, title: \.name)

        let dataCount = DataCount(500, 700)
        env.setEnvironmentValue(dataCount, forKey: TunnelEnvironmentKeys.dataCount)
        XCTAssertEqual(sut.dataCount, nil)

        try await tunnel.install(profile, connect: true, title: \.name)
        try await Task.sleep(for: .milliseconds(300))
        XCTAssertEqual(sut.dataCount, dataCount)
    }
}
