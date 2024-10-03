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
import LocalAuthentication
import SwiftUI
import UtilsLibrary

// MARK: - Modifiers

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
                    .themeLockScreen()
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
                    .themeLockScreen()
            }
    }

    private var modalSize: CGSize? {
        isRoot ? theme.rootModalSize : theme.secondaryModalSize
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

    func body(content: Content) -> some View {
        LockableView(
            locksInBackground: $locksInBackground,
            content: {
                content
            },
            lockedContent: LogoView.init,
            unlockBlock: Self.unlockScreenBlock
        )
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
                localizedReason: Strings.Views.Settings.Rows.LockInBackground.message
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
            .buttonStyle(.borderless)
        }
        .popover(isPresented: $isPresenting, arrowEdge: edge) {
            VStack {
                Text(text)
                    .foregroundStyle(.primary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(width: 150.0)
            }
            .padding(12)
        }
    }
}

// MARK: - Views

public enum ThemeAnimationCategory: CaseIterable {
    case profiles

    case profilesLayout

    case modules

    case diagnostics
}

struct ThemeImage: View {

    @EnvironmentObject
    private var theme: Theme

    private let name: Theme.ImageName

    init(_ name: Theme.ImageName) {
        self.name = name
    }

    var body: some View {
        Image(systemName: theme.systemImage(name))
    }
}

struct ThemeImageLabel: View {

    @EnvironmentObject
    private var theme: Theme

    private let title: String

    private let name: Theme.ImageName

    init(_ title: String, _ name: Theme.ImageName) {
        self.title = title
        self.name = name
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            ThemeImage(name)
        }
    }
}

struct ThemeCopiableText: View {

    @EnvironmentObject
    private var theme: Theme

    var title: String?

    let value: String

    var body: some View {
        HStack {
            if let title {
                Text(title)
                Spacer()
            }
            Text(value)
                .foregroundStyle(title == nil ? theme.titleColor : theme.valueColor)
                .themeTruncating()
            if title == nil {
                Spacer()
            }
            Button {
                copyToPasteboard(value)
            } label: {
                ThemeImage(.copy)
            }
            // TODO: #584, necessary to avoid cell selection
            .buttonStyle(.borderless)
        }
    }
}

struct ThemeTappableText: View {
    let title: String

    let action: () -> Void

    var commonView: some View {
        Button(action: action) {
            Text(title)
                .themeTruncating()
        }
    }
}

struct ThemeTextField: View {
    let title: String?

    @Binding
    var text: String

    let placeholder: String

    init(_ title: String, text: Binding<String>, placeholder: String) {
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

struct ThemeSecureField: View {
    let title: String?

    @Binding
    var text: String

    let placeholder: String

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

struct ThemeRemovableItemRow<ItemView>: View where ItemView: View {
    let isEditing: Bool

    @ViewBuilder
    let itemView: () -> ItemView

    let removeAction: () -> Void

    var body: some View {
        RemovableItemRow(
            isEditing: isEditing,
            itemView: itemView,
            removeView: removeView
        )
    }
}

enum ThemeEditableListSection {
    struct RemoveLabel: View {
        let action: () -> Void
    }

    struct EditLabel: View {
    }
}
