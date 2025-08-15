// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import AppLibrary
import Foundation
import PartoutWireGuard
import XCTest

final class LocalizationTests: XCTestCase {
    func test_givenModules_whenTranslateApp_thenWorks() {
        XCTAssertEqual(Strings.Global.Actions.connect, "Connect")
        XCTAssertEqual(Strings.Global.Nouns.address, "Address")
    }

    func test_givenModules_whenTranslateWireGuard_thenWorks() {
        let sut = WireGuardParseError.noInterface
        XCTAssertEqual(sut.localizedDescription, "Configuration must have an ‘Interface’ section.")
    }
}
