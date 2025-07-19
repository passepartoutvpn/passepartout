//
//  MainScreenshotTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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
import AppAccessibility
import XCTest

@MainActor
final class MainScreenshotTests: XCTestCase, XCUIApplicationProviding {
    let app: XCUIApplication = {
        let app = XCUIApplication()
        app.appArguments = [.uiTesting]
        return app
    }()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launch()
        app.activate()
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .portrait
        }
#endif
    }

    func testTakeScreenshots() async throws {
        let root = AppScreen(app: app)
            .waitForProfiles()
            .enableProfile(at: 1)

        let profile = root
            .editProfile(at: 2)

        await pause()
        try snapshot("03", "ProfileEditor", target: .sheet)

        profile
            .enterModule(at: 1)

        await pause()
        try snapshot("02", "OnDemand", target: .sheet)

        profile
            .leaveModule()
            .enterModule(at: 2)

        await pause()
        try snapshot("04", "DNS", target: .sheet)

        let app = profile
            .leaveModule()
            .closeProfile()

        await pause()
        try snapshot("01", "Connected")

        app
            .editProfile(at: 2)
            .editProviderServer()

        await pause()
        try snapshot("05", "ProviderServers", target: .sheet)

        print("Saved to: \(ScreenshotDestination.temporary.url)")
    }
}
