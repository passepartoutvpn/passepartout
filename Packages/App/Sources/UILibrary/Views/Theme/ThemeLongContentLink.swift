//
//  ThemeLongContentLink.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/30/25.
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

#if !os(tvOS)

import CommonUtils
import SwiftUI

public struct ThemeLongContentLink: View {
    private let title: String

    @Binding
    private var text: String

    private let preview: String?

    public init(_ title: String, text: Binding<String>, preview: String? = nil) {
        self.title = title
        _text = text
        self.preview = preview ?? text.wrappedValue
    }

    public init(_ title: String, text: Binding<String>, preview: (String) -> String?) {
        self.title = title
        _text = text
        self.preview = preview(text.wrappedValue)
    }

    public var body: some View {
        LongContentLink(title, content: $text, preview: preview) {
            Text(preview != nil ? $0 : "")
                .foregroundColor(.secondary)
        }
    }
}

#endif
