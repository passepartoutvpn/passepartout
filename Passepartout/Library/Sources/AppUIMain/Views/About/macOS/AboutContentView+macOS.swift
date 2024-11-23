//
//  AboutContentView+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

struct AboutContentView<LinkContent, AboutDestination, LogDestination>: View where LinkContent: View, AboutDestination: View, LogDestination: View {

    @Environment(\.dismiss)
    private var dismiss

    let profileManager: ProfileManager

    let isRestricted: Bool

    @Binding
    var path: NavigationPath

    @Binding
    var navigationRoute: AboutCoordinatorRoute?

    let linkContent: (AboutCoordinatorRoute) -> LinkContent

    let aboutDestination: (AboutCoordinatorRoute?) -> AboutDestination

    let logDestination: (DebugLogRoute?) -> LogDestination

    var body: some View {
        NavigationSplitView {
            listView
        } detail: {
            aboutDestination(navigationRoute)
                .navigationDestination(for: AboutCoordinatorRoute.self, destination: aboutDestination)
                .navigationDestination(for: DebugLogRoute.self, destination: logDestination)
                .themeNavigationStack(closable: false, path: $path)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(Strings.Global.ok) {
                            dismiss()
                        }
                    }
                }
        }
        .onLoad {
            navigationRoute = .links
        }
    }
}

private extension AboutContentView {
    var listView: some View {
        List(selection: $navigationRoute) {
            Section {
                linkContent(.links)
                linkContent(.credits)
                if !isRestricted {
                    linkContent(.donate)
                }
                linkContent(.diagnostics)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text(BundleConfiguration.mainVersionString)
                .padding(.bottom)
        }
        .navigationTitle(Strings.Views.About.title)
    }
}

#endif
