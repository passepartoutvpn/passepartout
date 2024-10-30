//
//  AppDelegate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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

import AppUI
import CommonLibrary
import PassepartoutKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject {
    let context: AppContext = .shared
//    let context: AppContext = .mock(withRegistry: .shared)

    func configure() {
        PassepartoutConfiguration.shared.configureLogging(
            to: BundleConfiguration.urlForAppLog,
            parameters: Constants.shared.log,
            logsPrivateData: UserDefaults.appGroup.bool(forKey: AppPreference.logsPrivateData.key)
        )
        AppUI.configure(with: context)

#if os(macOS)
        // keep this for login item because scenePhase is not triggered
        Task {
            try await context.tunnel.prepare(purge: true)
        }
#endif
    }
}
