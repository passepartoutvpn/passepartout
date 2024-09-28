//
//  AdvancedView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/23/24.
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
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct AdvancedView: View {
    let identifiers: Constants.Identifiers

    @Binding
    var navigationRoute: AdvancedRouterView.NavigationRoute?

    var body: some View {
        listView
            .navigationTitle(Strings.Views.Advanced.title)
    }
}

extension AdvancedView {
    var donateLink: some View {
        navLink(Strings.Views.Donate.title, to: .donate)
    }

    var diagnosticsLink: some View {
        navLink(Strings.Views.Diagnostics.title, to: .diagnostics)
    }

    var linksLink: some View {
        navLink(Strings.Views.Advanced.Links.title, to: .links)
    }

    var creditsLink: some View {
        navLink(Strings.Views.Advanced.Credits.title, to: .credits)
    }
}

private extension AdvancedView {
    func navLink(_ title: String, to route: AdvancedRouterView.NavigationRoute) -> some View {
        NavigationLink(title, value: route)
    }
}

#Preview {
    AdvancedView(
        identifiers: Constants.shared.identifiers,
        navigationRoute: .constant(nil)
    )
}
