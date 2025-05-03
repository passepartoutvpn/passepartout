//
//  KeyValueManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/1/25.
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

@testable import CommonLibrary
import Foundation
import XCTest

final class KeyValueManagerTests: XCTestCase {
}

@MainActor
extension KeyValueManagerTests {
    func test_givenKeyValue_whenSet_thenGets() {
        let sut = KeyValueManager()

        sut.set("foobar", forKey: "string")
        sut.set(true, forKey: "boolean")
        sut.set(123, forKey: "number")
        XCTAssertEqual(sut.object(forKey: "string"), "foobar")
        XCTAssertEqual(sut.object(forKey: "boolean"), true)
        XCTAssertEqual(sut.object(forKey: "number"), 123)
        XCTAssertEqual(sut.string(forKey: "string"), "foobar")
        XCTAssertEqual(sut.bool(forKey: "boolean"), true)
        XCTAssertEqual(sut.integer(forKey: "number"), 123)

        sut.removeObject(forKey: "string")
        sut.removeObject(forKey: "boolean")
        sut.removeObject(forKey: "number")
        XCTAssertFalse(sut.contains("string"))
        XCTAssertFalse(sut.contains("boolean"))
        XCTAssertFalse(sut.contains("number"))
    }

    func test_givenKeyValue_whenSetFallback_thenGetsFallback() {
        let sut = KeyValueManager()
        sut.fallback = [
            "string": "foobar",
            "boolean": true,
            "number": 123
        ]
        XCTAssertEqual(sut.object(forKey: "string"), "foobar")
        XCTAssertEqual(sut.object(forKey: "boolean"), true)
        XCTAssertEqual(sut.object(forKey: "number"), 123)
        XCTAssertEqual(sut.string(forKey: "string"), "foobar")
        XCTAssertEqual(sut.bool(forKey: "boolean"), true)
        XCTAssertEqual(sut.integer(forKey: "number"), 123)
    }
}
