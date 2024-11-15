//
//  AppDelegate.swift
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

import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !isAppRunning else {
            NSApp.terminate(self)
            return
        }
        let cfg = NSWorkspace.OpenConfiguration()
        cfg.hides = true
        cfg.activates = false
        cfg.addsToRecentItems = false
        Task {
            defer {
                NSApp.terminate(self)
            }
            do {
                try await NSWorkspace.shared.openApplication(at: appURL, configuration: cfg)
                NSLog("Launched main app: \(appURL)")
            } catch {
                NSLog("Unable to launch main app: \(error)")
            }
        }
    }
}

private extension AppDelegate {
    var loginItemId: String {
        guard let id = Bundle.main.bundleIdentifier else {
            fatalError("No bundle identifier in LoginItem?")
        }
        return id
    }

    var appId: String {
        var idComponents = loginItemId.components(separatedBy: ".")
        idComponents.removeLast()
        return idComponents.joined(separator: ".")
    }

    var appURL: URL {
        let path = Bundle.main.bundlePath as NSString
        var components = path.pathComponents

        // Passepartout.app/Contents/Library/LoginItems/PassepartoutLoginItem.app
        components.removeLast(4)

        let appPath = NSString.path(withComponents: components)
        return URL(fileURLWithPath: appPath)
    }

    var isAppRunning: Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == appId
        }
    }
}

// MARK: - Preconcurrency warnings

extension NSWorkspace: @retroactive @unchecked Sendable {
}

extension NSRunningApplication: @unchecked Sendable {
}

extension NSWorkspace.OpenConfiguration: @retroactive @unchecked Sendable {
}
