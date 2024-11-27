//
//  PassepartoutUITests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/27/24.
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

import UITesting
import XCTest

@MainActor
final class PassepartoutUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.appArguments = [.uiTesting]
        app.launch()
    }

    func testMain() {
        let container = app.get(.App.installedProfile)
        XCTAssertTrue(container.waitForExistence(timeout: 1.0))

//        snapshot("Main")
    }

    func testConnected() async throws {
        let container = app.get(.App.installedProfile)
        XCTAssertTrue(container.waitForExistence(timeout: 1.0))

        let profileToggle = app.get(.App.profileToggle).firstMatch
        XCTAssertTrue(profileToggle.waitForExistence(timeout: 1.0))
        profileToggle.tap()

        try await Task.sleep(for: .seconds(3))

//        snapshot("Connected")
    }

    func testProfile() async throws {
        let container = app.get(.App.installedProfile)
        XCTAssertTrue(container.waitForExistence(timeout: 1.0))

        let profileMenu = app.get(.App.profileMenu).firstMatch
        XCTAssertTrue(profileMenu.waitForExistence(timeout: 1.0))
        profileMenu.tap()

        let editButton = app.get(.ProfileMenu.edit)
        XCTAssertTrue(editButton.waitForExistence(timeout: 1.0))
        editButton.tap()

        try await Task.sleep(for: .seconds(2))

//        snapshot("Profile")
    }
}

private extension PassepartoutUITests {
    var window: XCUIElement {
        app.windows.firstMatch
    }

    func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: window.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
