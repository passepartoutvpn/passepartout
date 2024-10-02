//
//  LogoView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/20/23.
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

struct LogoView: View {

    @EnvironmentObject
    private var theme: Theme

    var body: some View {
        ZStack {
            theme.primaryColor
                .ignoresSafeArea()
            Image(theme.logoImage)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LogoView()
        .withMockEnvironment()
}
