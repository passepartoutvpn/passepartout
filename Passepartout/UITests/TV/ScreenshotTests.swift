//
//  ScreenshotTests.swift
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

import Foundation
import UIAccessibility
import XCTest

@MainActor
final class ScreenshotTests: XCTestCase, XCUIApplicationProviding {
    let app: XCUIApplication = {
        let app = XCUIApplication()
        app.appArguments = [.uiTesting]
        return app
    }()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTakeScreenshots() async throws {
        let root = AppScreen(app: app)
            .waitForProfiles()
            .presentInitialProfiles()
            .enableProfile(up: 1)

        await pause()
        try snapshot("01_Connected")

        root
            .presentProfilesWhileConnected()

        await pause()
        try snapshot("02_ConnectedWithProfileList")

        root
            .enableProfile(up: 0)

        await pause()
        try snapshot("03_OnDemand")

        print("Saved to: \(ScreenshotDestination.temporary.url)")
    }
}
