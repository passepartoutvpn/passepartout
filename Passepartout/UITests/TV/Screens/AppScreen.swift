//
//  AppScreen.swift
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
struct AppScreen {
    let app: XCUIApplication

    private let remote: XCUIRemote = .shared

    @discardableResult
    func waitForProfiles() -> Self {
        app.get(.App.installedProfile)
        return self
    }

    @discardableResult
    func presentInitialProfiles() -> Self {
        remote.press(.down)
        return self
    }

    @discardableResult
    func enableProfile(up: Int) -> Self {
        let profileButton = app.get(.App.ProfileList.profile)
        remote.press(.right)
        for _ in 0..<up {
            remote.press(.up)
        }
        remote.press(.select)
        profileButton.waitForNonExistence(timeout: 1.0)
        return self
    }

    @discardableResult
    func presentProfilesWhileConnected() -> Self {
        remote.press(.down)
        _ = app.get(.App.ProfileList.profile)
        return self
    }
}
