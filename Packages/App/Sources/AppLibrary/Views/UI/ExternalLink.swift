//
//  ExternalLink.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/30/25.
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

import CommonLibrary
import SwiftUI

public struct ExternalLink: View {
    private let title: String

    private let url: URL

    private let withIcon: Bool

    public init(_ title: String, url: URL, withIcon: Bool? = nil) {
        self.title = title
        self.url = url
#if os(macOS)
        self.withIcon = withIcon ?? true
#else
        self.withIcon = withIcon ?? false
#endif
    }

    public var body: some View {
        Link(destination: url) {
            HStack {
                Text(title)
                    .themeMultiLine(true)
                Spacer()
                if withIcon {
                    ThemeImage(.externalLink)
                }
            }
        }
#if os(macOS)
        .foregroundStyle(.primary)
#endif
    }
}

#Preview {
    ExternalLink(
        "A very long line and more more and more",
        url: URL(string: "https://")!,
        withIcon: true
    )
    .withMockEnvironment()
}
