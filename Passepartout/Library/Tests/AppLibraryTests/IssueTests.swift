//
//  IssueTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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

@testable import AppLibrary
import Foundation
import XCTest

final class IssueTests: XCTestCase {
    func test_givenNothing_whenCreateIssue_thenCollectsOSAndDevice() {
        let issue = Issue(appLine: nil, purchasedProducts: [])
        XCTAssertNil(issue.appLine)
#if os(iOS)
        XCTAssertTrue(issue.osLine.hasPrefix("iOS"))
#else
        XCTAssertTrue(issue.osLine.hasPrefix("macOS"))
#endif
    }

    func test_givenAppLine_whenCreateIssue_thenCollectsAppOSAndDevice() {
        let issue = Issue(appLine: "Passepartout 1.2.3", purchasedProducts: [])
        XCTAssertEqual(issue.appLine, "Passepartout 1.2.3")
    }

    func test_givenAppLineAndProducts_whenCreateIssue_thenMatchesTemplate() {
        let issue = Issue(appLine: "Passepartout 1.2.3", purchasedProducts: [.Features.appleTV])
        let expected = """
Hi,

// enter a description of the issue

--

App: Passepartout 1.2.3
OS: \(issue.osLine)
Device: \(issue.deviceLine ?? "unknown")
Provider: none (last updated: unknown)
Purchased: ["\(AppProduct.Features.appleTV.rawValue)"]

--

Regards

"""
        XCTAssertEqual(issue.body, expected)
    }
}
