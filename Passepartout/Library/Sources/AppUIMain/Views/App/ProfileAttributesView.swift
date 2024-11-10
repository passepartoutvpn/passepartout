//
//  ProfileAttributesView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/10/24.
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

struct ProfileAttributesView: View {
    let isShared: Bool

    let isTV: Bool

    let isRemoteImportingEnabled: Bool

    var body: some View {
        Group {
            if isTV {
                tvImage
            } else if isShared {
                sharedImage
            }
        }
        .foregroundStyle(.secondary)
    }

    var sharedImage: some View {
        ThemeImage(isRemoteImportingEnabled ? .cloudOn : .cloudOff)
            .help(Strings.Modules.General.Rows.shared)
    }

    var tvImage: some View {
        ThemeImage(isRemoteImportingEnabled ? .tvOn : .tvOff)
            .help(Strings.Modules.General.Rows.appleTv(Strings.Unlocalized.appleTV))
    }
}

#Preview {
    struct ContentView: View {

        @State
        private var isRemoteImportingEnabled = false

        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()

        var body: some View {
            ProfileAttributesView(
                isShared: true,
                isTV: true,
                isRemoteImportingEnabled: isRemoteImportingEnabled
            )
            .onReceive(timer) { _ in
                isRemoteImportingEnabled.toggle()
            }
            .border(.black)
            .padding()
            .withMockEnvironment()
        }
    }

    return ContentView()
}

#Preview("Row Alignment") {
    IconsPreview()
        .withMockEnvironment()
}

struct IconsPreview: View {
    var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                ThemeImage(.cloudOn)
                ThemeImage(.cloudOff)
                ThemeImage(.tvOn)
                ThemeImage(.tvOff)
                ThemeImage(.info)
            }
        }
        .themeForm()
    }
}
