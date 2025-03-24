//
//  ThemeCopiableText.swift
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

#if !os(tvOS)

import CommonUtils
import SwiftUI

public struct ThemeCopiableText<Value, ValueView>: View where Value: CustomStringConvertible, ValueView: View {

    @EnvironmentObject
    private var theme: Theme

    private let title: String?

    private let value: Value

    private let isMultiLine: Bool

    private let valueView: (Value) -> ValueView

    public init(
        _ title: String? = nil,
        value: Value,
        isMultiLine: Bool = true,
        valueView: @escaping (Value) -> ValueView
    ) {
        self.title = title
        self.value = value
        self.isMultiLine = isMultiLine
        self.valueView = valueView
    }

    public var body: some View {
        HStack {
            if let title {
                Text(title)
                Spacer()
            }
            valueView(value)
                .foregroundStyle(title == nil ? theme.titleColor : theme.valueColor)
                .themeMultiLine(isMultiLine)
            if title == nil {
                Spacer()
            }
            Button {
                Utils.copyToPasteboard(value.description)
            } label: {
                ThemeImage(.copy)
            }
            // XXX: #584, necessary to avoid cell selection
            .buttonStyle(.borderless)
        }
    }
}

public struct ThemeTruncatedText: View {
    let title: String

    public var body: some View {
        Text(title)
            .themeTruncating(.middle)
    }
}

extension ThemeCopiableText where Value == String, ValueView == ThemeTruncatedText {
    public init(
        _ title: String? = nil,
        value: Value,
        isMultiLine: Bool = true
    ) {
        self.init(title, value: value, isMultiLine: isMultiLine) {
            ThemeTruncatedText(title: $0)
        }
    }
}

#endif
