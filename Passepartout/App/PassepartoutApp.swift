//
//  PassepartoutApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/22/24.
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

#if os(iOS) || os(macOS)
import AppUIMain
#elseif os(tvOS)
import AppUITV
#endif

import CommonLibrary
import PassepartoutKit
import SwiftUI

@main
struct PassepartoutApp: App {

#if os(iOS) || os(tvOS)

    @UIApplicationDelegateAdaptor
    private var appDelegate: AppDelegate

#elseif os(macOS)

    @NSApplicationDelegateAdaptor
    private var appDelegate: AppDelegate

#endif

    @Environment(\.scenePhase)
    private var scenePhase

    @StateObject
    var theme = Theme()
}

extension PassepartoutApp {
    var appName: String {
        BundleConfiguration.mainDisplayName
    }

    var context: AppContext {
        appDelegate.context
    }

    func contentView() -> some View {
        AppCoordinator(
            profileManager: context.profileManager,
            tunnel: context.tunnel,
            registry: context.registry
        )
        .onChange(of: scenePhase) {
            switch $0 {
            case .active:
                Task {
                    do {
                        pp_log(.app, .notice, "Prepare tunnel and purge stale data")
                        try await context.tunnel.prepare(purge: true)
                    } catch {
                        pp_log(.app, .fault, "Unable to prepare tunnel: \(error)")
                    }
                }

            default:
                break
            }
        }
        .withEnvironment(from: context, theme: theme)
    }
}
