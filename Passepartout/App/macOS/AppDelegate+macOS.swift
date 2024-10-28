//
//  AppDelegate+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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
import AppUI
import CommonLibrary
import PassepartoutKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    @AppStorage(AppPreference.confirmsQuit.key)
    private var confirmsQuit = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows[0].styleMask.remove(.closable)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if confirmsQuit {
            return quitConfirmationAlert()
        }
        return .terminateNow
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        ImporterPipe.shared.send(urls)
    }
}

@MainActor
private extension AppDelegate {
    func quitConfirmationAlert() -> NSApplication.TerminateReply {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = Strings.Alerts.ConfirmQuit.title(BundleConfiguration.mainDisplayName)
        alert.informativeText = Strings.Alerts.ConfirmQuit.message
        alert.addButton(withTitle: Strings.Global.ok)
        alert.addButton(withTitle: Strings.Global.cancel)
        alert.addButton(withTitle: Strings.Global.doNotAskAgain)

        switch alert.runModal() {
        case .alertSecondButtonReturn:
            return .terminateCancel

        case .alertThirdButtonReturn:
            confirmsQuit = false

        default:
            break
        }
        return .terminateNow
    }
}

#endif
