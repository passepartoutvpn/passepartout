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

enum Detail {
    case credits

    case donate

    case other

    case purchased

    case version
}

struct SettingsView: View {

    @EnvironmentObject
    private var theme: Theme

    let tunnel: ExtendedTunnel

    @FocusState
    private var focus: Detail?

    @State
    private var detail: Detail?

    var body: some View {
        HStack {
            masterView
                .frame(maxWidth: .infinity)
                .focused($focus, equals: .other)

            DetailView(detail: detail)
                .frame(maxWidth: .infinity)
        }
        .background(theme.primaryColor)
        .onChange(of: focus) {
            guard focus != nil else {
                return
            }
            detail = focus
        }
    }
}

private extension SettingsView {
    var masterView: some View {
        List {
            creditsSection
            diagnosticsSection
            aboutSection
        }
        .themeList()
    }

    var creditsSection: some View {
        Group {
            Button {
            } label: {
                Text(Strings.Global.Nouns.version)
                    .themeTrailingValue(BundleConfiguration.mainVersionString)
            }
            .focused($focus, equals: .version)
            Button(Strings.Views.About.Credits.title) {}
                .focused($focus, equals: .credits)
            Button(Strings.Views.Donate.title) {}
                .focused($focus, equals: .donate)
        }
        .themeSection(header: Strings.Views.About.title)
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
            Button(Strings.Views.Purchased.title) {}
                .focused($focus, equals: .purchased)
        }
        .themeSection()
    }
}

private struct DetailView: View {
    let detail: Detail?

    var body: some View {
        switch detail {
        case .credits:
            CreditsView()
                .themeList()

        case .donate:
            DonateView(modifier: DonateViewModifier())

        case .purchased:
            PurchasedView()
                .themeList()

        case .version:
            VersionView()

        default:
            VStack {}
        }
    }
}

// MARK: -

#Preview {
    SettingsView(tunnel: .forPreviews)
        .themeNavigationStack()
        .withMockEnvironment()
}
