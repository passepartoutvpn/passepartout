//
//  DonateViewModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/23/24.
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

struct DonateViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Text(Strings.Views.Donate.Sections.Main.footer)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)

            ScrollView {
                LazyVGrid(columns: columns) {
                    content
                }
            }
        }
        .padding(.top, 150)
    }
}

private extension DonateViewModifier {
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 500))]
    }
}