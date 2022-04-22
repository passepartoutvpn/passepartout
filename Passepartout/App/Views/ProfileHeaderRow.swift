//
//  ProfileHeaderRow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

struct ProfileHeaderRow: View {
    let header: Profile.Header
    
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Group {
                if let name = header.providerName {
                    providerView(name)
                } else {
                    hostView
                }
            }.themeLongText()
            .font(.headline)

            if isActive {
                VPNStatusText()
                    .foregroundColor(themeSecondaryColor)
                    .font(.subheadline)
            }
        }.frame(height: 60)
    }
    
    private func providerView(_ name: ProviderName) -> some View {
//        Label(header.name, systemImage: themeProviderImage)
//        Label(header.name, image: themeAssetsProviderImage(name))
        Text(header.name)
    }
    
    private var hostView: some View {
//        Label(header.name, systemImage: themeHostImage)
        Text(header.name)
    }
}
