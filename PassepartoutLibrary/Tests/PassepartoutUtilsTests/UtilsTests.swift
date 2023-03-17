//
//  UtilsTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/30/19.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
@testable import PassepartoutUtils
import SwiftyBeaver

class UtilsTests: XCTestCase {
    override func setUp() {
        pp_log.addDestination(ConsoleDestination())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLanguageLocalization() {
        let languages = ["en", "it", "de", "pt-BR", "ru"]
        let english = Locale(identifier: "en")
        let italian = Locale(identifier: "it")

        let languagesEN = privateSortedLanguages(languages, with: english)
        let languagesIT = privateSortedLanguages(languages, with: italian)

        // English, German, Italian, Portuguese, Russian
        XCTAssertEqual(languagesEN, ["en", "de", "it", "pt-BR", "ru"])

        // Inglese, Italiano, Portoghese, Russo, Tedesco
        XCTAssertEqual(languagesIT, ["en", "it", "pt-BR", "ru", "de"])
    }

    func testTrailing() {
        let file = Bundle.module.url(forResource: "Debug", withExtension: "log")!

        for len in [10, 100, 1000] {
            let last = file.trailingContent(bytes: UInt64(len))
            XCTAssertEqual(last.count, len)
            pp_log.debug(last)
        }
        XCTAssertNotEqual(file.trailingContent(bytes: 100000).count, 100000)

        pp_log.debug(file.trailingLines(bytes: 1000))
    }

    private func privateSortedLanguages(_ languages: [String], with locale: Locale) -> [String] {
        languages.sorted {
            locale.localizedString(forLanguageCode: $0)! < locale.localizedString(forLanguageCode: $1)!
        }
    }
}
