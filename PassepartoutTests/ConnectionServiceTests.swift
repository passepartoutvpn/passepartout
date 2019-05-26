//
//  ConnectionServiceTests.swift
//  PassepartoutTests
//
//  Created by Davide De Rosa on 10/25/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import TunnelKit
@testable import PassepartoutCore

class ConnectionServiceTests: XCTestCase {
    let url = Bundle(for: ConnectionServiceTests.self).url(forResource: "ConnectionService", withExtension: "json")!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParse() {
        let jsonData = try! Data(contentsOf: url)
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: jsonData, options: []))
    }

    func testPathExtension() {
        XCTAssertTrue(privateTestPathExtension("file:///foo/bar/johndoe.json"))
        XCTAssertFalse(privateTestPathExtension("file:///foo/bar/break.json.johndoe.json"))
    }
    
    private func privateTestPathExtension(_ string: String) -> Bool {
        let url = URL(string: string)!
        let filename = url.lastPathComponent
        guard let extRange = filename.range(of: ".json") else {
            return false
        }
        guard url.pathExtension == "json" else {
            return false
        }
        let name1 = String(filename[filename.startIndex..<extRange.lowerBound])
        let name2 = url.deletingPathExtension().lastPathComponent
        return name1 == name2
    }
}
