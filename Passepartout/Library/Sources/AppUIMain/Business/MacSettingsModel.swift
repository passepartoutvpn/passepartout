//
//  MacSettingsModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

#if os(macOS)

import AppKit
import PassepartoutKit
import ServiceManagement

@MainActor
final class MacSettingsModel: ObservableObject {
    private let appService: SMAppService

    var isVisible: Bool {
        get {
            AppWindow.shared.isVisible
        }
        set {
            AppWindow.shared.isVisible = newValue
            objectWillChange.send()
        }
    }

    var launchesOnLogin: Bool {
        get {
            appService.status == .enabled
        }
        set {
            do {
                if newValue {
                    try appService.register()
                } else {
                    try appService.unregister()
                }
            } catch {
                pp_log(.app, .error, "Unable to (un)register login item: \(error)")
            }
            objectWillChange.send()
        }
    }

    init() {
        let loginItemId = BundleConfiguration.mainString(for: .loginItemId)
        appService = SMAppService.loginItem(identifier: loginItemId)
    }
}

#endif
