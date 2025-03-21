//
//  Theme+Modules.swift
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

extension View {

    @ViewBuilder
    public func themeModuleSection<Content>(if rows: [Any?]? = nil, header: String?, @ViewBuilder content: () -> Content) -> some View where Content: View {
        if let rows, rows.allSatisfy({ $0 == nil }) {
            EmptyView()
        } else {
            content()
                .themeSection(header: header)
        }
    }
}

public struct ThemeModuleText: View {
    private let caption: String

    private let value: String?

    public init(caption: String, value: String? = nil) {
        self.caption = caption
        self.value = value
    }

    public var body: some View {
        Text(caption)
            .themeTrailingValue(value)
    }
}

public struct ThemeModuleTextField: View {
    private let caption: String

    @Binding
    private var value: String

    private let placeholder: String

    public init(caption: String, value: Binding<String>, placeholder: String) {
        self.caption = caption
        _value = value
        self.placeholder = placeholder
    }

    public var body: some View {
        ThemeTextField(caption, text: $value, placeholder: placeholder)
    }
}

public struct ThemeModuleTextList: View {
    private let caption: String

    private let withEntries: Bool

    private let values: [String]

    private let copiable: Bool

    public init(caption: String, withEntries: Bool = false, values: [String], copiable: Bool = false) {
        self.caption = caption
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
                .navigationTitle(caption)
                .themeForm()
            } label: {
                Text(caption)
                    .themeTrailingValue(withEntries ? values.count.localizedEntries : nil)
            }
        } else {
            Text(caption)
                .themeTrailingValue(Strings.Global.Nouns.empty)
        }
    }
}

public struct ThemeModuleCopiableText: View {
    private let caption: String

    private let value: String

    private let multiline: Bool

    public init(caption: String, value: String, multiline: Bool = true) {
        self.caption = caption
        self.value = value
        self.multiline = multiline
    }

    public var body: some View {
        ThemeCopiableText(title: caption, value: value, isMultiLine: multiline) {
            Text($0)
                .themeTruncating(.middle)
        }
    }
}

public struct ThemeModuleLongContent: View {
    private let caption: String

    @Binding
    private var value: String

    private let preview: String?

    public init(caption: String, value: Binding<String>, preview: String? = nil) {
        self.caption = caption
        _value = value
        self.preview = preview ?? value.wrappedValue
    }

    public init(caption: String, value: Binding<String>, preview: (String) -> String?) {
        self.caption = caption
        _value = value
        self.preview = preview(value.wrappedValue)
    }

    public var body: some View {
        LongContentLink(caption, content: $value, preview: preview) {
            Text(preview != nil ? $0 : "")
                .foregroundColor(.secondary)
        }
    }
}

public struct ThemeModulePush: View {
    private let caption: String

    private let route: any Hashable

    public init(caption: String, route: any Hashable) {
        self.caption = caption
        self.route = route
    }

    public var body: some View {
        NavigationLink(caption, value: route)
    }
}

public struct ThemeTrailingContent<Content>: View where Content: View {

    @ViewBuilder
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
#if os(iOS)
        content()
            .frame(maxWidth: .infinity)
#else
        HStack {
            Spacer()
            content()
        }
#endif
    }
}

#endif
