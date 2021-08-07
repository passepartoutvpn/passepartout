//
//  WindowManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/12/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

import Cocoa
import PassepartoutCore

class WindowManager: NSObject {
    static let shared = WindowManager()
    
    private var organizer: NSWindowController?
    
    private var preferences: NSWindowController?
    
    private override init() {
    }
    
    @discardableResult func showOrganizer() -> NSWindowController? {
        organizer = presentWindowController(StoryboardScene.Main.organizerWindowController, existing: organizer)
        organizer?.window?.title = "Passepartout"
        return organizer
    }
    
    @discardableResult func showPreferences() -> NSWindowController? {
        preferences = presentWindowController(StoryboardScene.Preferences.preferencesWindowController, existing: preferences)
        preferences?.window?.title = L10n.Core.Preferences.title
        return preferences
    }
    
    func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: Helpers

    private func presentWindowController(_ wcScene: SceneType<NSWindowController>, existing: NSWindowController?) -> NSWindowController? {
        var wc: NSWindowController?
        if existing == nil {
            wc = wcScene.instantiate()
            wc?.window?.delegate = self
            wc?.window?.center()
            wc?.showWindow(nil)
        } else {
            existing?.window?.makeKeyAndOrderFront(self)
        }
        NSApp.activate(ignoringOtherApps: true)
        return existing ?? wc
    }
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        switch notification.object as? NSWindowController {
        case organizer:
            organizer = nil
            
//        case preferences:
//            preferences = nil
            
        default:
            break
        }
    }
}
