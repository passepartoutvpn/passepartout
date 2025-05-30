//
//  AppWindow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

#if os(macOS)

import AppKit

@MainActor
public final class AppWindow {
    public static let shared = AppWindow()

    public var isVisible: Bool {
        get {
            NSApp.activationPolicy() == .regular && window?.isVisible == true
        }
        set {
            // this code is unused, show() is more solid
            NSApp.setActivationPolicy(newValue ? .regular : .accessory)
            if newValue {
                NSApp.activate(ignoringOtherApps: true)
                window?.makeKeyAndOrderFront(self)
            } else {
                window?.close()
            }
        }
    }

    private init() {
    }

    public func show(completion: (() -> Void)? = nil) async throws {
        if isVisible {
            return
        }
        let url = Bundle.main.bundleURL
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = false
        try await NSWorkspace.shared.openApplication(at: url, configuration: config)
    }
}

private extension AppWindow {
    var window: NSWindow? {
        NSApp.windows.first(where: \.isWindow)
    }
}

private extension NSWindow {
    var isWindow: Bool {
        !className.contains("NSStatusBar")
    }
}

#endif
