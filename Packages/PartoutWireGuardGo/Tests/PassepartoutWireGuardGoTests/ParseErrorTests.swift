//
//  ParseErrorTests.swift
//  Partout
//
//  Created by Davide De Rosa on 11/25/24.
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

import Partout
@testable import PartoutWireGuardGo
internal import WireGuardKit
import XCTest

final class ParseErrorTests: XCTestCase {
    func test_givenParseError_whenMap_thenReturnsAsReason() throws {
        let sut = TunnelConfiguration.ParseError.noInterface
        let mapped = sut.asPartoutError
        XCTAssertTrue(mapped.reason is TunnelConfiguration.ParseError)
        let reason = try XCTUnwrap(mapped.reason as? TunnelConfiguration.ParseError)
        switch reason {
        case .noInterface:
            break
        default:
            XCTFail("Mapped to different error: \(reason)")
        }
    }

    func test_givenLocalizable_whenParseError_thenReturnsLocalizedString() {
        let sut = TunnelConfiguration.ParseError.noInterface
        XCTAssertEqual(sut.localizedDescription, "Configuration must have an ‘Interface’ section.")
    }
}
