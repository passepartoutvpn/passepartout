// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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
        let sut = KeyValueManager(fallback: [
            "string": "foobar",
            "boolean": true,
            "number": 123
        ])
        XCTAssertEqual(sut.object(forKey: "string"), "foobar")
        XCTAssertEqual(sut.object(forKey: "boolean"), true)
        XCTAssertEqual(sut.object(forKey: "number"), 123)
        XCTAssertEqual(sut.string(forKey: "string"), "foobar")
        XCTAssertEqual(sut.bool(forKey: "boolean"), true)
        XCTAssertEqual(sut.integer(forKey: "number"), 123)
    }
}
