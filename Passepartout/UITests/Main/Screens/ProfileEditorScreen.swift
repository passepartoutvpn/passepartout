//
//  ProfileEditorScreen.swift
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
struct ProfileEditorScreen {
    let app: XCUIApplication

    @discardableResult
    func enterModule(at index: Int) -> Self {
        let moduleLink = app.get(.Profile.moduleLink, at: index)
        moduleLink.tap()
        return self
    }

    @discardableResult
    func leaveModule() -> Self {
#if os(iOS)
        let backButton = app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 1.0))
        backButton.tap()
#endif
        return self
    }

    @discardableResult
    func closeProfile() -> AppScreen {
        let cancelButton = app.get(.Profile.cancel)
        cancelButton.tap()
        return AppScreen(app: app)
    }
}
