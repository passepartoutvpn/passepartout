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

import Combine
@testable import CommonLibrary
import Foundation
import PassepartoutKit
import XCTest

final class ExtendedTunnelTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable> = []
}

@MainActor
extension ExtendedTunnelTests {
    func test_givenTunnel_whenDisconnectWithError_thenPublishesLastErrorCode() async throws {
        let env = InMemoryEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy(environment: env))
        let sut = ExtendedTunnel(tunnel: tunnel, environment: env, interval: 0.1)

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.connect(with: profile)
        env.setEnvironmentValue(.crypto, forKey: TunnelEnvironmentKeys.lastErrorCode)

        let exp = expectation(description: "Last error code")
        var didCall = false
        sut
            .$lastErrorCode
            .sink {
                if !didCall, $0 != nil {
                    didCall = true
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)

        try await tunnel.disconnect()
        await fulfillment(of: [exp], timeout: 0.5)
        XCTAssertEqual(sut.lastErrorCode, .crypto)
    }

    func test_givenTunnel_whenConnect_thenPublishesDataCount() async throws {
        let env = InMemoryEnvironment()
        let tunnel = Tunnel(strategy: FakeTunnelStrategy(environment: env))
        let sut = ExtendedTunnel(tunnel: tunnel, environment: env, interval: 0.1)

        let module = try DNSModule.Builder().tryBuild()
        let profile = try Profile.Builder(modules: [module], activatingModules: true).tryBuild()
        try await sut.install(profile)

        let dataCount = DataCount(500, 700)
        env.setEnvironmentValue(dataCount, forKey: TunnelEnvironmentKeys.dataCount)
        XCTAssertEqual(sut.dataCount, nil)

        let exp = expectation(description: "Data count")
        var didCall = false
        sut
            .$dataCount
            .sink {
                if !didCall, $0 != nil {
                    didCall = true
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)

        try await tunnel.install(profile, connect: true, title: \.name)
        await fulfillment(of: [exp], timeout: 0.5)
        XCTAssertEqual(sut.dataCount, dataCount)
    }
}
