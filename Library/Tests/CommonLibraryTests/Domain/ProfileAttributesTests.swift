//
//  ProfileAttributesTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/10/24.
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

@testable import CommonLibrary
import Foundation
import PassepartoutKit
import XCTest

final class ProfileAttributesTests: XCTestCase {
    func test_givenUserInfo_whenInit_thenReturnsAttributes() {
        let fingerprint = UUID()
        let lastUpdate = Date()
        let isAvailableForTV = true
        let userInfo: [String: AnyHashable] = [
            "fingerprint": fingerprint.uuidString,
            "lastUpdate": lastUpdate.timeIntervalSinceReferenceDate,
            "isAvailableForTV": isAvailableForTV
        ]

        let sut = ProfileAttributes(userInfo: userInfo)
        XCTAssertEqual(sut.userInfo, userInfo)
        XCTAssertEqual(sut.fingerprint, fingerprint)
        XCTAssertEqual(sut.lastUpdate, lastUpdate)
        XCTAssertEqual(sut.isAvailableForTV, isAvailableForTV)
    }

    func test_givenUserInfo_whenSet_thenReturnsAttributes() {
        let fingerprint = UUID()
        let lastUpdate = Date()
        let isAvailableForTV = true
        let userInfo: [String: AnyHashable] = [
            "fingerprint": fingerprint.uuidString,
            "lastUpdate": lastUpdate.timeIntervalSinceReferenceDate,
            "isAvailableForTV": isAvailableForTV
        ]

        var sut = ProfileAttributes(userInfo: nil)
        sut.fingerprint = fingerprint
        sut.lastUpdate = lastUpdate
        sut.isAvailableForTV = isAvailableForTV
        XCTAssertEqual(sut.userInfo, userInfo)
        XCTAssertEqual(sut.fingerprint, fingerprint)
        XCTAssertEqual(sut.lastUpdate, lastUpdate)
        XCTAssertEqual(sut.isAvailableForTV, isAvailableForTV)
    }

    func test_givenUserInfo_whenInit_thenReturnsModulePreferences() {
        let moduleId1 = UUID()
        let moduleId2 = UUID()
        let excludedEndpoints: [String] = [
            "1.1.1.1:UDP6:1000",
            "2.2.2.2:TCP4:2000",
            "3.3.3.3:TCP:3000",
        ]
        let moduleUserInfo: [String: AnyHashable] = [
            "excludedEndpoints": excludedEndpoints
        ]
        let userInfo: [String: AnyHashable] = [
            "preferences": [
                moduleId1.uuidString: moduleUserInfo,
                moduleId2.uuidString: moduleUserInfo
            ]
        ]

        let sut = ProfileAttributes(userInfo: userInfo)
        XCTAssertEqual(sut.userInfo, userInfo)
        for moduleId in [moduleId1, moduleId2] {
            let module = sut.preferences(inModule: moduleId)
            XCTAssertEqual(module.userInfo, moduleUserInfo)
            XCTAssertEqual(module.excludedEndpoints, excludedEndpoints)
        }
    }

    func test_givenUserInfo_whenSet_thenReturnsModulePreferences() {
        let moduleId1 = UUID()
        let moduleId2 = UUID()
        let excludedEndpoints: [String] = [
            "1.1.1.1:UDP6:1000",
            "2.2.2.2:TCP4:2000",
            "3.3.3.3:TCP:3000",
        ]
        let moduleUserInfo: [String: AnyHashable] = [
            "excludedEndpoints": excludedEndpoints
        ]
        let userInfo: [String: AnyHashable] = [
            "preferences": [
                moduleId1.uuidString: moduleUserInfo,
                moduleId2.uuidString: moduleUserInfo
            ]
        ]

        var sut = ProfileAttributes(userInfo: nil)
        for moduleId in [moduleId1, moduleId2] {
            var module = sut.preferences(inModule: moduleId1)
            module.excludedEndpoints = excludedEndpoints
            XCTAssertEqual(module.userInfo, moduleUserInfo)
            sut.setPreferences(module, inModule: moduleId)
        }
        XCTAssertEqual(sut.userInfo, userInfo)
    }
}
