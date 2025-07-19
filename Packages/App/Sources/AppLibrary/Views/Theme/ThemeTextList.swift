//
//  ThemeTextList.swift
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

public struct ThemeTextList: View {
    private let title: String

    private let withEntries: Bool

    private let values: [String]

    private let copiable: Bool

    public init(_ title: String, withEntries: Bool = false, values: [String], copiable: Bool = false) {
        self.title = title
        self.withEntries = withEntries
        self.values = values
        self.copiable = copiable
    }

    public var body: some View {
        if !values.isEmpty {
            NavigationLink {
                Form {
                    ForEach(Array(values.enumerated()), id: \.offset) { pair in
                        HStack {
                            Text(pair.element)
                            if copiable {
                                Spacer()
                                Button {
                                    Utils.copyToPasteboard(pair.element)
                                } label: {
                                    ThemeImage(.copy)
                                }
                                // XXX: #584, necessary to avoid cell selection
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                .navigationTitle(title)
                .themeForm()
            } label: {
                ThemeRow(title, value: withEntries ? values.count.localizedEntries : nil)
            }
        } else {
            ThemeRow(title, value: Strings.Global.Nouns.empty)
        }
    }
}

#endif
