//
//  Theme+UI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/28/24.
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
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import SwiftUI
import UtilsLibrary

// MARK: - Modifiers

#if !os(tvOS)

struct ThemeWindowModifier: ViewModifier {
    let size: CGSize
}

struct ThemeNavigationDetailModifier: ViewModifier {
}

struct ThemeFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
    }
}

struct ThemeBooleanModalModifier<Modal>: ViewModifier where Modal: View {

    @EnvironmentObject
    private var theme: Theme

    @Binding
    var isPresented: Bool

    let isRoot: Bool

    let isInteractive: Bool

    let modal: () -> Modal

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                modal()
                    .frame(minWidth: modalSize?.width, minHeight: modalSize?.height)
                    .interactiveDismissDisabled(!isInteractive)
                    .themeLockScreen(theme)
            }
    }

    private var modalSize: CGSize? {
        isRoot ? theme.rootModalSize : theme.secondaryModalSize
    }
}

struct ThemeItemModalModifier<Modal, T>: ViewModifier where Modal: View, T: Identifiable {

    @EnvironmentObject
    private var theme: Theme

    @Binding
    var item: T?

    let isRoot: Bool

    let isInteractive: Bool

    let modal: (T) -> Modal

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) {
                modal($0)
                    .frame(minWidth: modalSize?.width, minHeight: modalSize?.height)
                    .interactiveDismissDisabled(!isInteractive)
                    .themeLockScreen(theme)
            }
    }

    private var modalSize: CGSize? {
        isRoot ? theme.rootModalSize : theme.secondaryModalSize
    }
}

struct ThemeBooleanPopoverModifier<Popover>: ViewModifier where Popover: View {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.horizontalSizeClass)
    private var hsClass

    @Environment(\.verticalSizeClass)
    private var vsClass

    @Binding
    var isPresented: Bool

    @ViewBuilder
    let popover: Popover

    func body(content: Content) -> some View {
        if hsClass == .regular && vsClass == .regular {
            content
                .popover(isPresented: $isPresented) {
                    popover
                        .frame(minWidth: theme.popoverSize?.width, minHeight: theme.popoverSize?.height)
                        .themeLockScreen(theme)
                }
        } else {
            content
                .sheet(isPresented: $isPresented) {
                    popover
                        .themeLockScreen(theme)
                }
        }
    }
}

struct ThemeConfirmationModifier: ViewModifier {

    @Binding
    var isPresented: Bool

    let title: String

    let isDestructive: Bool

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                Button(Strings.Theme.Confirmation.ok, role: isDestructive ? .destructive : nil, action: action)
                Text(Strings.Theme.Confirmation.cancel)
            } message: {
                Text(Strings.Theme.Confirmation.message)
            }
    }
}

struct ThemeNavigationStackModifier: ViewModifier {

    @Environment(\.dismiss)
    private var dismiss

    let condition: Bool

    let closable: Bool

    @Binding
    var path: NavigationPath

    func body(content: Content) -> some View {
        if condition {
            NavigationStack(path: $path) {
                content
                    .toolbar {
                        if closable {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    dismiss()
                                } label: {
                                    ThemeImage(.close)
                                }
                            }
                        }
                    }
            }
        } else {
            content
        }
    }
}

struct ThemePlainButtonModifier: ViewModifier {
    let action: () -> Void
}

struct ThemeManualInputModifier: ViewModifier {
}

struct ThemeEmptyMessageModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
                .font(theme.emptyMessageFont)
                .foregroundStyle(theme.emptyMessageColor)
            Spacer()
        }
    }
}

struct ThemeErrorModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    let isError: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(isError ? theme.errorColor : theme.titleColor)
    }
}

struct ThemeAnimationModifier<T>: ViewModifier where T: Equatable {

    @EnvironmentObject
    private var theme: Theme

    let value: T

    let category: ThemeAnimationCategory

    func body(content: Content) -> some View {
        content
            .animation(theme.animation(for: category), value: value)
    }
}

struct ThemeTrailingValueModifier: ViewModifier {
    let value: CustomStringConvertible?

    let truncationMode: Text.TruncationMode

    func body(content: Content) -> some View {
        LabeledContent {
            if let value {
                Spacer()
                Text(value.description)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(truncationMode)
            }
        } label: {
            content
        }
    }
}

struct ThemeSectionWithHeaderFooterModifier: ViewModifier {
    let header: String?

    let footer: String?
}

struct ThemeGridSectionModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    let title: String?

    func body(content: Content) -> some View {
        if let title {
            Text(title)
                .font(theme.gridHeaderStyle)
                .fontWeight(theme.relevantWeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.bottom, theme.gridHeaderBottom)
        }
        content
            .padding(.bottom)
            .padding(.bottom)
    }
}

struct ThemeGridCellModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .padding()
            .background(isSelected ? theme.gridCellActiveColor : theme.gridCellColor)
            .clipShape(.rect(cornerRadius: theme.gridRadius))
    }
}

struct ThemeHoverListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxHeight: .infinity)
            .listRowInsets(.init())
    }
}

struct ThemeLockScreenModifier: ViewModifier {

    @AppStorage(AppPreference.locksInBackground.key)
    private var locksInBackground = false

    @ObservedObject
    var theme: Theme

    func body(content: Content) -> some View {
        LockableView(
            locksInBackground: locksInBackground,
            content: {
                content
            },
            lockedContent: LogoView.init,
            unlockBlock: Self.unlockScreenBlock
        )
        .environmentObject(theme)
    }

    private static func unlockScreenBlock() async -> Bool {
        let context = LAContext()
        let policy: LAPolicy = .deviceOwnerAuthentication
        var error: NSError?
        guard context.canEvaluatePolicy(policy, error: &error) else {
            return true
        }
        do {
            let isAuthorized = try await context.evaluatePolicy(
                policy,
                localizedReason: Strings.Theme.LockScreen.reason
            )
            return isAuthorized
        } catch {
            return false
        }
    }
}

struct ThemeTipModifier: ViewModifier {
    let text: String

    let edge: Edge

    @State
    private var isPresenting = false

    func body(content: Content) -> some View {
        HStack {
            content
            Button {
                isPresenting = true
            } label: {
                ThemeImage(.tip)
            }
            .imageScale(.large)
            .buttonStyle(.borderless)
            .popover(isPresented: $isPresenting, arrowEdge: edge) {
                VStack {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(width: 150.0)
                }
                .padding(12)
            }
        }
    }
}

#endif

// MARK: - Views

public enum ThemeAnimationCategory: CaseIterable {
    case diagnostics

    case modules

    case profiles

    case profilesLayout

    case providers
}

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
        textView
            .font(.body)
    }

    @ViewBuilder
    private var textView: some View {
        if let code {
            text(withString: .emoji(forCountryCode: code), tip: countryTip?(code))
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
                copyToPasteboard(value.description)
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

public struct ThemeTextField: View {
    private let title: String?

    @Binding
    private var text: String

    private let placeholder: String

    public init(_ title: String, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    @ViewBuilder
    var commonView: some View {
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

    private var fieldView: some View {
        TextField(title ?? "", text: $text, prompt: Text(placeholder))
    }
}

public struct ThemeSecureField: View {
    private let title: String?

    @Binding
    private var text: String

    private let placeholder: String

    public init(title: String?, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    @ViewBuilder
    var commonView: some View {
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

    private var fieldView: some View {
        RevealingSecureField(title ?? "", text: $text, prompt: Text(placeholder), imageWidth: 30.0) {
           ThemeImage(.hide)
                .foregroundStyle(Color.accentColor)
       } revealImage: {
           ThemeImage(.show)
               .foregroundStyle(Color.accentColor)
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
