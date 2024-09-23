//
//  ProfilesLayoutPicker.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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

import SwiftUI
import UtilsLibrary

struct ProfilesLayoutPicker: View {

    @EnvironmentObject
    private var theme: Theme

    @Binding
    var layout: ProfilesLayout

    var body: some View {
        Picker(selection: $layout.animation(theme.animation(for: .profilesLayout))) {
            ForEach(ProfilesLayout.allCases, id: \.self, content: \.image)
        } label: {
            layout.image
        }
        .pickerStyle(.inline)
    }
}

private extension ProfilesLayout {
    var image: ThemeImage {
        switch self {
        case .list:
            return ThemeImage(.profilesList)

        case .grid:
            return ThemeImage(.profilesGrid)
        }
    }
}
