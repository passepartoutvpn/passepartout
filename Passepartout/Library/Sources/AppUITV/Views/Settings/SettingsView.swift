//
//  SettingsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/8/24.
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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI
import UILibrary

struct SettingsView: View {
    let tunnel: ExtendedTunnel

    var body: some View {
        listView
            .resized(width: 0.5)
    }
}

private extension SettingsView {
    var listView: some View {
        List {
            creditsSection
            diagnosticsSection
            aboutSection
        }
        .themeList()
    }

    var creditsSection: some View {
        Group {
            NavigationLink(Strings.Views.About.Credits.title, value: AppCoordinatorRoute.credits)
            NavigationLink(Strings.Views.Donate.title, value: AppCoordinatorRoute.donate)
        }
        .themeSection(header: Strings.Unlocalized.appName)
    }

    var diagnosticsSection: some View {
        Group {
            NavigationLink(Strings.Views.Diagnostics.Rows.app, value: AppCoordinatorRoute.appLog)
            NavigationLink(Strings.Views.Diagnostics.Rows.tunnel, value: AppCoordinatorRoute.tunnelLog)
            LogsPrivateDataToggle()
        }
        .themeSection(header: Strings.Views.Diagnostics.title)
    }

    var aboutSection: some View {
        Group {
            Text(Strings.Global.Nouns.version)
                .themeTrailingValue(BundleConfiguration.mainVersionString)
        }
        .themeSection(header: Strings.Views.About.title)
    }
}

// MARK: -

#Preview {
    SettingsView(tunnel: .mock)
        .themeNavigationStack()
        .withMockEnvironment()
}
