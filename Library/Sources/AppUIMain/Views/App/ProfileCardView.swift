//
//  ProfileCardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/5/24.
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
import SwiftUI

struct ProfileCardView: View {
    enum Style {
        case compact

        case full
    }

    let style: Style

    let preview: ProfilePreview

    var body: some View {
        switch style {
        case .compact:
            Text(preview.name)
                .themeTruncating()
                .frame(maxWidth: .infinity, alignment: .leading)

        case .full:
            VStack(alignment: .leading) {
                Text(preview.name)
                    .font(.headline)
                    .themeTruncating()

                Text(preview.subtitle ?? Strings.Views.App.Profile.noModules)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Previews

#Preview {
    List {
        Section {
            ProfileCardView(
                style: .compact,
                preview: .init(.forPreviews)
            )
        }
        Section {
            ProfileCardView(
                style: .full,
                preview: .init(.forPreviews)
            )
        }
    }
    .withMockEnvironment()
}
