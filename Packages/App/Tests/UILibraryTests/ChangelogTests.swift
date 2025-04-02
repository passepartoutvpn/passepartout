//
//  ChangelogTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/25.
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

import Foundation
import UILibrary
import XCTest

final class ChangelogTests: XCTestCase {
    func test_givenLine_whenHasIssue_thenParsesEntry() throws {
        let sut = "* Some text (#123)"
        let entry = try XCTUnwrap(sut.asChangelogEntry(54))
        XCTAssertEqual(entry.id, 54)
        XCTAssertEqual(entry.comment, "Some text")
        XCTAssertEqual(entry.issue, 123)
    }

    func test_givenLine_whenHasNoIssue_thenParsesEntry() throws {
        let sut = "* Some text"
        let entry = try XCTUnwrap(sut.asChangelogEntry(734))
        XCTAssertEqual(entry.id, 734)
        XCTAssertEqual(entry.comment, "Some text")
        XCTAssertNil(entry.issue)
    }

    func test_givenLine_whenHasNoIssue_thenReturnsNil() {
        let sut = " fkjndsjkafg"
        XCTAssertNil(sut.asChangelogEntry(0))
    }
}
