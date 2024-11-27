//
//  VersionView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/27/24.
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

public struct VersionView<Icon>: View where Icon: View {

    @EnvironmentObject
    private var theme: Theme

    private let icon: () -> Icon

    public init(icon: @escaping () -> Icon) {
        self.icon = icon
    }

    public var body: some View {
        ScrollView {
            icon()
                .padding(.top)
            Spacer()
            Text(title)
                .font(.largeTitle)
            Spacer()
            Text(subtitle)
            VStack {
                Text(message)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .background(theme.primaryColor)
        .foregroundStyle(.white)
    }
}

extension VersionView where Icon == LogoImage {
    public init() {
        icon = {
            LogoImage()
        }
    }
}

private extension VersionView {
    var title: String {
        Strings.Unlocalized.appName
    }

    var subtitle: String {
        BundleConfiguration.mainVersionString
    }

    var message: String {
        Strings.Views.Version.extra(Strings.Unlocalized.appName, Strings.Unlocalized.authorName)
    }
}

#Preview {
    VersionView {
        ThemeImage(.cloudOn)
            .font(.largeTitle)
    }
    .withMockEnvironment()
}
