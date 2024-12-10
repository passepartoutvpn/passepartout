//
//  ScreenshotTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
#endif
    }

    func testTakeScreenshots() async throws {
        let root = AppScreen(app: app)
            .waitForProfiles()
            .enableProfile(at: 0)

        try await Task.sleep(for: .seconds(2))
        try snapshot("1_Connected")

        let profile = root
            .openProfileMenu(at: 2)
            .editProfile()

        try await Task.sleep(for: .seconds(2))
        try snapshot("2_ProfileEditor", target: .sheet)

        profile
            .enterModule(at: 1)

        try await Task.sleep(for: .seconds(2))
        try snapshot("3_OnDemand", target: .sheet)

        profile
            .leaveModule()
            .enterModule(at: 2)

        try await Task.sleep(for: .seconds(2))
        try snapshot("4_DNS", target: .sheet)

        profile
            .leaveModule()
            .closeProfile()
            .openProfileMenu(at: 2)
            .connectToProfile()
#if os(iOS)
            .discloseCountry(at: 2)
#endif

        try await Task.sleep(for: .seconds(2))
        try snapshot("5_ProviderServers", target: .sheet)

        print("Saved to: \(ScreenshotDestination.temporary.url)")
    }
}
