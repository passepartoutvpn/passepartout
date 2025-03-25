//
//  ThemeImageLabel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

public struct ThemeImageLabel<Title>: View where Title: View {

    @EnvironmentObject
    private var theme: Theme

    private let name: Theme.ImageName

    private let inForm: Bool

    @ViewBuilder
    private let title: () -> Title

    public init(_ name: Theme.ImageName, inForm: Bool = false, @ViewBuilder title: @escaping () -> Title) {
        self.name = name
        self.inForm = inForm
        self.title = title
    }

    public var body: some View {
        Label(title: title) {
            ThemeImage(name)
#if os(iOS)
                .scaleEffect(inForm ? 0.9 : 1.0, anchor: .center)
#endif
        }
    }
}

extension ThemeImageLabel where Title == Text {
    public init(_ title: String, inForm: Bool = false, _ name: Theme.ImageName) {
        self.init(name, inForm: inForm) {
            Text(title)
        }
    }
}
