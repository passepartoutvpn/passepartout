//
//  SettingsContentView+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

#if os(iOS)

import CommonLibrary
import PassepartoutKit
import SwiftUI
import UILibrary

struct SettingsContentView<LinkContent, SettingsDestination, LogDestination>: View where LinkContent: View, SettingsDestination: View, LogDestination: View {

    @Environment(\.dismiss)
    private var dismiss

    let profileManager: ProfileManager

    let isBeta: Bool

    @Binding
    var path: NavigationPath

    @Binding
    var navigationRoute: SettingsCoordinatorRoute?

    let linkContent: (SettingsCoordinatorRoute) -> LinkContent

    let settingsDestination: (SettingsCoordinatorRoute?) -> SettingsDestination

    let diagnosticsDestination: (DiagnosticsRoute?) -> LogDestination

    var body: some View {
        listView
            .navigationDestination(for: SettingsCoordinatorRoute.self, destination: settingsDestination)
            .navigationDestination(for: DiagnosticsRoute.self, destination: diagnosticsDestination)
            .themeNavigationDetail()
            .themeNavigationStack(closable: true, path: $path)
    }
}

private extension SettingsContentView {
    var listView: some View {
        List {
            Section {
                linkContent(.preferences)
                linkContent(.version)
            }

            Group {
                linkContent(.links)
                linkContent(.credits)
                if !isBeta {
                    linkContent(.donate)
                }
            }
            .themeSection(header: Strings.Global.Nouns.about)

            Section {
                linkContent(.diagnostics)
                linkContent(.purchases)
            }
            .themeSection(header: Strings.Global.Nouns.troubleshooting)
        }
        .navigationTitle(Strings.Global.Nouns.settings)
    }
}

#endif
