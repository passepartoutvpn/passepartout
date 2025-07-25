//
//  AppearanceManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/18/25.
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

import CommonLibrary
import Foundation
import SwiftUI

@MainActor
public final class AppearanceManager: ObservableObject {
    private let kvManager: KeyValueManager

    @Published
    public var systemAppearance: SystemAppearance? {
        didSet {
            kvManager.set(systemAppearance?.rawValue, forKey: UIPreference.systemAppearance.key)
            apply()
        }
    }

    public init(kvManager: KeyValueManager) {
        self.kvManager = kvManager
        systemAppearance = kvManager.string(forKey: UIPreference.systemAppearance.key)
            .flatMap {
                SystemAppearance(rawValue: $0)
            }
    }
}

extension AppearanceManager {
    public func apply() {
#if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let window = scene.keyWindow else {
            return
        }
        switch systemAppearance {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .none:
            window.overrideUserInterfaceStyle = .unspecified
        }
#elseif os(macOS)
        guard let app = NSApp else {
//            assertionFailure("NSApp is being used too early")
            return
        }
        switch systemAppearance {
        case .light:
            app.appearance = NSAppearance(named: .vibrantLight)
        case .dark:
            app.appearance = NSAppearance(named: .vibrantDark)
        case .none:
            app.appearance = nil
        }
#endif
    }
}
