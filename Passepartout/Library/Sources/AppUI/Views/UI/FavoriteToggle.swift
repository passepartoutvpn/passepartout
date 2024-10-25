//
//  ThemeFavoriteToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/24.
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

struct FavoriteToggle<ID>: View where ID: Hashable {

    let value: ID

    @Binding
    var selection: Set<ID>

    var body: some View {
        Button {
            if selection.contains(value) {
                selection.remove(value)
            } else {
                selection.insert(value)
            }
        } label: {
            ThemeImage(selection.contains(value) ? .favoriteOn : .favoriteOff)
        }
    }
}
