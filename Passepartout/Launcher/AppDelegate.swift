//
//  AppDelegate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private let appURL = Constants.Launcher.appURL

    private var isAppRunning: Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == Constants.Launcher.appId
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !isAppRunning else {
            NSApp.terminate(self)
            return
        }

        let cfg = NSWorkspace.OpenConfiguration()
        cfg.hides = true
        cfg.activates = false
        cfg.addsToRecentItems = false
        NSWorkspace.shared.openApplication(at: appURL, configuration: cfg) { _, error in
            if let error = error {
                NSLog("Unable to launch main app: \(error)")
                return
            }
            NSApp.terminate(self)
        }
    }
}
