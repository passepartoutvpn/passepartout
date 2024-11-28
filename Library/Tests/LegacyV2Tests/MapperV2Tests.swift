//
//  MapperV2Tests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/12/24.
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

import Foundation
@testable import LegacyV2
import PassepartoutKit
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
