// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

@testable import CommonLegacyV2
import CommonLibrary
import Foundation
import XCTest

final class MapperV2Tests: XCTestCase {
    func test_givenMapper_whenDefaultGateway_thenIncludesDefaultRoute() throws {
        let sut = MapperV2()
        var settings = Network.GatewaySettings(choice: .manual)
        var module: IPModule

        settings.isDefaultIPv4 = true
        module = try sut.toIPModule(settings, v2MTU: nil)
        XCTAssertTrue(module.ipv4?.includesDefaultRoute ?? false)

        settings.isDefaultIPv6 = true
        module = try sut.toIPModule(settings, v2MTU: nil)
        XCTAssertTrue(module.ipv6?.includesDefaultRoute ?? false)
    }

    func test_givenMapper_whenNotDefaultGateway_thenExcludesDefaultRoute() throws {
        let sut = MapperV2()
        var settings = Network.GatewaySettings(choice: .manual)
        var module: IPModule
        let defaultRoute = Route(defaultWithGateway: nil)

        settings.isDefaultIPv4 = false
        module = try sut.toIPModule(settings, v2MTU: nil)
        XCTAssertTrue(module.ipv4?.excludedRoutes.contains(defaultRoute) ?? false)

        settings.isDefaultIPv6 = false
        module = try sut.toIPModule(settings, v2MTU: nil)
        XCTAssertTrue(module.ipv6?.excludedRoutes.contains(defaultRoute) ?? false)
    }
}
