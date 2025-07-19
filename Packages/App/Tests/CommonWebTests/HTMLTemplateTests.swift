//
//  HTMLTemplateTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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
import AppStrings
@testable import CommonWeb
import XCTest

final class HTMLTemplateTests: XCTestCase {
    func test_givenTemplate_whenInjectKey_thenReturnsLocalizedHTML() throws {
        let html = """
Hey show some #{web_uploader.success}
"""
        let sut = HTMLTemplate(html: html)
        let localized = sut.withLocalizedKeys(in: AppStrings.bundle)
        XCTAssertEqual(localized, "Hey show some Upload complete!")
    }
}
