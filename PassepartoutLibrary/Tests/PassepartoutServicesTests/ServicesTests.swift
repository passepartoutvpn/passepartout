//
//  ServicesTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
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
import Combine
@testable import PassepartoutServices
import PassepartoutUtils
import SwiftyBeaver

class ServicesTests: XCTestCase {
    let wsLocal = DefaultWebServices.bundledServices(withVersion: "v5")

    let wsRemote = DefaultWebServices("v5", URL(string: "https://passepartoutvpn.app/api/")!, timeout: nil)

    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        SwiftyBeaver.addDestination(ConsoleDestination())
    }

    override func tearDown() {
    }

    func testLastModified() {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(abbreviation: "GMT")
        fmt.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"

        let lmString = "Wed, 23 Oct 2019 17:06:54 GMT"

        fmt.locale = Locale(identifier: "en")
        XCTAssertNotNil(fmt.date(from: lmString))
        fmt.locale = Locale(identifier: "fr-FR")
        XCTAssertNil(fmt.date(from: lmString))
    }

    func testLocalIndex() {
        let exp = expectation(description: "")
        wsLocal.providersIndex()
            .sink {
                switch $0 {
                case .finished:
                    break

                case .failure(let error):
                    pp_log.debug(error)
                    exp.fulfill()
                }
            } receiveValue: {
                pp_log.debug($0)
                exp.fulfill()
            }.store(in: &cancellables)

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testRemoteIndex() {
        let exp = expectation(description: "")
        wsRemote.providersIndex()
            .sink {
                switch $0 {
                case .finished:
                    break

                case .failure(let error):
                    pp_log.debug(error)
                    exp.fulfill()
                }
            } receiveValue: {
                pp_log.debug($0)
                exp.fulfill()
            }.store(in: &cancellables)

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
