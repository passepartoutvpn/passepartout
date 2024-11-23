//
//  Theme+Views.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

import CommonUtils
import SwiftUI

// MARK: Shortcuts

#if !os(tvOS)
extension Theme {
    public func listSection<ItemView: View, T: EditableValue>(
        _ title: String,
        addTitle: String,
        originalItems: Binding<[T]>,
        emptyValue: (() async -> T)? = nil,
        @ViewBuilder itemLabel: @escaping (Bool, Binding<T>) -> ItemView
    ) -> some View {
        EditableListSection(
            title,
            addTitle: addTitle,
            originalItems: originalItems,
            emptyValue: emptyValue,
            itemLabel: itemLabel,
            removeLabel: ThemeEditableListSection.RemoveLabel.init(action:),
            editLabel: ThemeEditableListSection.EditLabel.init
        )
    }
}
#endif

// MARK: - Views

public struct ThemeImage: View {

    @EnvironmentObject
    private var theme: Theme

    private let name: Theme.ImageName

    public init(_ name: Theme.ImageName) {
        self.name = name
    }

    public var body: some View {
        Image(systemName: theme.systemImageName(name))
    }
}

public struct ThemeImageLabel: View {

    @EnvironmentObject
    private var theme: Theme

    private let title: String

    private let name: Theme.ImageName

    public init(_ title: String, _ name: Theme.ImageName) {
        self.title = title
        self.name = name
    }

    public var body: some View {
        Label {
            Text(title)
        } icon: {
            ThemeImage(name)
        }
    }
}

public struct ThemeCloseLabel: View {
    public init() {
    }

    public var body: some View {
#if os(iOS) || os(tvOS)
        ThemeImage(.close)
#else
        Text(Strings.Global.Actions.cancel)
#endif
    }
}

public struct ThemeCountryText: View {
    private let code: String

    private let title: String?

    public init(_ code: String, title: String? = nil) {
        self.code = code
        self.title = title ?? code.localizedAsRegionCode
    }

    public var body: some View {
        Text(
            [code.asCountryCodeEmoji, title]
                .compactMap { $0 }
                .joined(separator: " ")
        )
    }
}

public struct ThemeCountryFlag: View {
    private let code: String?

    private let placeholderTip: String?

    private let countryTip: ((String) -> String?)?

    public init(_ code: String?, placeholderTip: String? = nil, countryTip: ((String) -> String?)? = nil) {
        self.code = code
        self.placeholderTip = placeholderTip
        self.countryTip = countryTip
    }

    public var body: some View {
        if let code {
            text(withString: code.asCountryCodeEmoji, tip: countryTip?(code))
        } else {
            text(withString: "🌐", tip: placeholderTip)
        }
    }

    @ViewBuilder
    private func text(withString string: String, tip: String?) -> some View {
        if let tip {
            Text(verbatim: string)
                .help(tip)
        } else {
            Text(verbatim: string)
        }
    }
}

public struct ThemeTextField: View {
    let title: String?

    @Binding
    var text: String

    let placeholder: String

    public init(_ title: String, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    @ViewBuilder
    var labeledView: some View {
        if let title {
            LabeledContent {
                fieldView
            } label: {
                Text(title)
            }
        } else {
            fieldView
        }
    }

    var fieldView: some View {
        TextField(title ?? "", text: $text, prompt: Text(placeholder))
    }
}

public struct ThemeSecureField: View {
    let title: String?

    @Binding
    var text: String

    let placeholder: String

    public init(title: String?, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    @ViewBuilder
    var labeledView: some View {
        if let title {
            LabeledContent {
                fieldView
            } label: {
                Text(title)
            }
        } else {
            fieldView
        }
    }

    var fieldView: some View {
        RevealingSecureField(title ?? "", text: $text, prompt: Text(placeholder), imageWidth: 30.0) {
           ThemeImage(.hide)
                .foregroundStyle(Color.accentColor)
       } revealImage: {
           ThemeImage(.show)
               .foregroundStyle(Color.accentColor)
       }
    }
}

public struct ThemeProgressView: View {
    public init() {
    }

    public var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(UUID())
    }
}

#if !os(tvOS)

public struct ThemeMenuImage: View {

    @EnvironmentObject
    private var theme: Theme

    private let name: Theme.MenuImageName

    public init(_ name: Theme.MenuImageName) {
        self.name = name
    }

    public var body: some View {
        Image(theme.menuImageName(name))
    }
}

public struct ThemeDisclosableMenu<Content, Label>: View where Content: View, Label: View {

    @ViewBuilder
    private let content: () -> Content

    @ViewBuilder
    private let label: () -> Label

    public init(content: @escaping () -> Content, label: @escaping () -> Label) {
        self.content = content
        self.label = label
    }

    public var body: some View {
        Menu(content: content) {
            HStack(alignment: .firstTextBaseline) {
                label()
                ThemeImage(.disclose)
            }
            .contentShape(.rect)
        }
        .foregroundStyle(.primary)
#if os(macOS)
        .buttonStyle(.plain)
#endif
    }
}

public struct ThemeCopiableText<Value, ValueView>: View where Value: CustomStringConvertible, ValueView: View {

    @EnvironmentObject
    private var theme: Theme

    private let title: String?

    private let value: Value

    private let isMultiLine: Bool

    private let valueView: (Value) -> ValueView

    public init(
        title: String? = nil,
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
            // TODO: #584, necessary to avoid cell selection
            .buttonStyle(.borderless)
        }
    }
}

public struct ThemeTappableText: View {
    private let title: String

    private let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var commonView: some View {
        Button(action: action) {
            Text(title)
                .themeTruncating()
        }
    }
}

public struct ThemeRemovableItemRow<ItemView>: View where ItemView: View {
    private let isEditing: Bool

    @ViewBuilder
    private let itemView: () -> ItemView

    let removeAction: () -> Void

    public init(
        isEditing: Bool,
        @ViewBuilder itemView: @escaping () -> ItemView,
        removeAction: @escaping () -> Void
    ) {
        self.isEditing = isEditing
        self.itemView = itemView
        self.removeAction = removeAction
    }

    public var body: some View {
        RemovableItemRow(
            isEditing: isEditing,
            itemView: itemView,
            removeView: removeView
        )
    }
}

public enum ThemeEditableListSection {
    public struct RemoveLabel: View {
        let action: () -> Void

        public init(action: @escaping () -> Void) {
            self.action = action
        }
    }

    public struct EditLabel: View {
    }
}

#endif
