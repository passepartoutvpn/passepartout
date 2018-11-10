//
//  InfrastructureTests.swift
//  PassepartoutTests-iOS
//
//  Created by Davide De Rosa on 6/11/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

import XCTest
@testable import Passepartout
import TunnelKit

class InfrastructureTests: XCTestCase {
    private let infra = InfrastructureFactory.shared.get(.pia)

    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsing() {
        print(infra.pools)
        XCTAssertEqual(infra.pools.count, 53)
    }

    func testIdentifier() {
        let id = "us-east"
        guard let pool = infra.pool(for: id) else {
            XCTAssert(false)
            return
        }
        print(pool)
        XCTAssertEqual(pool.id, id)
    }
    
    func testStableSort() {
        let original: [TunnelKitProvider.EndpointProtocol] = [
            TunnelKitProvider.EndpointProtocol(.udp, 1194),
            TunnelKitProvider.EndpointProtocol(.udp, 8080),
            TunnelKitProvider.EndpointProtocol(.udp, 9201),
            TunnelKitProvider.EndpointProtocol(.udp, 53),
            TunnelKitProvider.EndpointProtocol(.udp, 1197),
            TunnelKitProvider.EndpointProtocol(.udp, 198),
            TunnelKitProvider.EndpointProtocol(.tcp, 443),
            TunnelKitProvider.EndpointProtocol(.tcp, 110),
            TunnelKitProvider.EndpointProtocol(.tcp, 80),
            TunnelKitProvider.EndpointProtocol(.tcp, 500),
            TunnelKitProvider.EndpointProtocol(.tcp, 501),
            TunnelKitProvider.EndpointProtocol(.tcp, 502)
        ]
        var preferredType: TunnelKitProvider.SocketType
        
        preferredType = .udp
        let sorted1 = original.stableSorted {
            return ($0.socketType == preferredType) && ($1.socketType != preferredType)
        }
        XCTAssertEqual(sorted1, original)

        preferredType = .tcp
        let sorted2 = original.stableSorted {
            return ($0.socketType == preferredType) && ($1.socketType != preferredType)
        }
        XCTAssertNotEqual(sorted2, original)
    }
}
