//
//  UtilsTests.swift
//  PassepartoutTests
//
//  Created by Davide De Rosa on 3/30/19.
//  Copyright (c) 2020 Davide De Rosa. All rights reserved.
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
@testable import PassepartoutCore

class UtilsTests: XCTestCase {
    override func setUp() {
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDataUnitDescription() {
        XCTAssertEqual(0.dataUnitDescription, "0B")
        XCTAssertEqual(1.dataUnitDescription, "1B")
        XCTAssertEqual(1024.dataUnitDescription, "1kB")
        XCTAssertEqual(1025.dataUnitDescription, "1kB")
        XCTAssertEqual(548575.dataUnitDescription, "0.52MB")
        XCTAssertEqual(1048575.dataUnitDescription, "1.00MB")
        XCTAssertEqual(1048576.dataUnitDescription, "1.00MB")
        XCTAssertEqual(1048577.dataUnitDescription, "1.00MB")
        XCTAssertEqual(600000000.dataUnitDescription, "0.56GB")
        XCTAssertEqual(1073741823.dataUnitDescription, "1.00GB")
        XCTAssertEqual(1073741824.dataUnitDescription, "1.00GB")
        XCTAssertEqual(1073741825.dataUnitDescription, "1.00GB")
    }
    
    func testLanguageLocalization() {
        let languages = ["en", "it", "de", "pt-BR", "ru"]
        let english = Locale(identifier: "en")
        let italian = Locale(identifier: "it")

        let languagesEN = privateSortedLanguages(languages, with: english)
        let languagesIT = privateSortedLanguages(languages, with: italian)

        XCTAssertEqual(languagesEN, ["en", "de", "it", "pt-BR", "ru"])
        XCTAssertEqual(languagesIT, ["en", "it", "pt-BR", "ru", "de"])
    }
    
    private func privateSortedLanguages(_ languages: [String], with locale: Locale) -> [String] {
        return languages.sorted {
            return locale.localizedString(forLanguageCode: $0)! < locale.localizedString(forLanguageCode: $1)!
        }
    }
}
