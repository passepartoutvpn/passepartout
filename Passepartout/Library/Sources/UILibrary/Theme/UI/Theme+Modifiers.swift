//
//  Theme+Modifiers.swift
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

import CommonLibrary
import CommonUtils
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import SwiftUI

// MARK: Shortcuts

public enum ThemeModalSize {
    case small

    case medium

    case large

    case custom(width: CGFloat, height: CGFloat)
}

extension View {
    public func themeModal<Content>(
        isPresented: Binding<Bool>,
        size: ThemeModalSize = .medium,
        isFixedWidth: Bool = false,
        isFixedHeight: Bool = false,
        isInteractive: Bool = true,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(ThemeBooleanModalModifier(
            isPresented: isPresented,
            size: size,
            isFixedWidth: isFixedWidth,
            isFixedHeight: isFixedHeight,
            isInteractive: isInteractive,
            modal: content
        ))
    }

    public func themeModal<Content, T>(
        item: Binding<T?>,
        size: ThemeModalSize = .medium,
        isFixedWidth: Bool = false,
        isFixedHeight: Bool = false,
        isInteractive: Bool = true,
        content: @escaping (T) -> Content
    ) -> some View where Content: View, T: Identifiable {
        modifier(ThemeItemModalModifier(
            item: item,
            size: size,
            isFixedWidth: isFixedWidth,
            isFixedHeight: isFixedHeight,
            isInteractive: isInteractive,
            modal: content
        ))
    }

    public func themeConfirmation(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(ThemeConfirmationModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            isDestructive: isDestructive,
            action: action
        ))
    }

    public func themeNavigationStack(
        closable: Bool = false,
        path: Binding<NavigationPath> = .constant(NavigationPath())
    ) -> some View {
        modifier(ThemeNavigationStackModifier(closable: closable, path: path))
    }

    @ViewBuilder
    public func themeNavigationStack(
        if condition: Bool,
        closable: Bool = false,
        path: Binding<NavigationPath> = .constant(NavigationPath())
    ) -> some View {
        if condition {
            modifier(ThemeNavigationStackModifier(closable: closable, path: path))
        } else {
            self
        }
    }

    public func themeForm() -> some View {
        formStyle(.grouped)
    }

    public func themeManualInput() -> some View {
        modifier(ThemeManualInputModifier())
    }

    public func themeSection(header: String? = nil, footer: String? = nil) -> some View {
        modifier(ThemeSectionWithHeaderFooterModifier(header: header, footer: footer))
    }

    public func themeRow(footer: String? = nil) -> some View {
        modifier(ThemeRowWithFooterModifier(footer: footer))
    }

    public func themeSectionWithSingleRow(header: String? = nil, footer: String, above: Bool = false) -> some View {
        Group {
            if above {
                EmptyView()
                    .themeRow(footer: footer)

                self
            } else {
                themeRow(footer: footer)
            }
        }
        .themeSection(header: header, footer: footer)
    }

    public func themeNavigationDetail() -> some View {
#if os(iOS)
        navigationBarTitleDisplayMode(.inline)
#else
        self
#endif
    }

    @ViewBuilder
    public func themeMultiLine(_ isMultiLine: Bool) -> some View {
        if isMultiLine {
            multilineTextAlignment(.leading)
        } else {
            themeTruncating()
        }
    }

    public func themeTruncating(_ mode: Text.TruncationMode = .middle) -> some View {
        lineLimit(1)
            .truncationMode(mode)
    }

    public func themeEmptyMessage(fullScreen: Bool = true) -> some View {
        modifier(ThemeEmptyMessageModifier(fullScreen: fullScreen))
    }

    public func themeError(_ isError: Bool) -> some View {
        modifier(ThemeErrorModifier(isError: isError))
    }

    public func themeAnimation<T>(on value: T, category: ThemeAnimationCategory) -> some View where T: Equatable {
        modifier(ThemeAnimationModifier(value: value, category: category))
    }

    @ViewBuilder
    public func themeEmpty(if isEmpty: Bool, message: String) -> some View {
        if !isEmpty {
            self
        } else {
            Text(message)
                .themeEmptyMessage()
        }
    }

    public func themeProgress(if isProgressing: Bool) -> some View {
        modifier(ThemeProgressViewModifier(isProgressing: isProgressing) {
            EmptyView()
        })
    }

    public func themeProgress(
        if isProgressing: Bool,
        isEmpty: Bool,
        emptyMessage: String
    ) -> some View {
        modifier(ThemeProgressViewModifier(isProgressing: isProgressing, isEmpty: isEmpty) {
            Text(emptyMessage)
                .themeEmptyMessage()
        })
    }

    public func themeProgress<EmptyContent>(
        if isProgressing: Bool,
        isEmpty: Bool,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent
    ) -> some View where EmptyContent: View {
        modifier(ThemeProgressViewModifier(isProgressing: isProgressing, isEmpty: isEmpty, emptyContent: emptyContent))
    }

    public func themeTrailingValue(_ value: CustomStringConvertible?, truncationMode: Text.TruncationMode = .tail) -> some View {
        modifier(ThemeTrailingValueModifier(value: value, truncationMode: truncationMode))
    }

#if !os(tvOS)
    public func themeWindow(width: CGFloat, height: CGFloat) -> some View {
        modifier(ThemeWindowModifier(size: .init(width: width, height: height)))
    }

    public func themePlainButton(action: @escaping () -> Void) -> some View {
        modifier(ThemePlainButtonModifier(action: action))
    }

    public func themeGridHeader(title: String?) -> some View {
        modifier(ThemeGridSectionModifier(title: title))
    }

    public func themeGridCell(isSelected: Bool) -> some View {
        modifier(ThemeGridCellModifier(isSelected: isSelected))
    }

    public func themeHoverListRow() -> some View {
        modifier(ThemeHoverListRowModifier())
    }

    public func themeTip(_ text: String, edge: Edge) -> some View {
        modifier(ThemeTipModifier(text: text, edge: edge))
    }
#endif
}

// MARK: - Presentation modifiers

extension ThemeModalSize {
    var defaultSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 300, height: 300)

        case .medium:
            return CGSize(width: 550, height: 350)

        case .large:
            return CGSize(width: 800, height: 500)

        case .custom(let width, let height):
            return CGSize(width: width, height: height)
        }
    }
}

struct ThemeBooleanModalModifier<Modal>: ViewModifier where Modal: View {

    @EnvironmentObject
    private var theme: Theme

    @Binding
    var isPresented: Bool

    let size: ThemeModalSize

    let isFixedWidth: Bool

    let isFixedHeight: Bool

    let isInteractive: Bool

    let modal: () -> Modal

    func body(content: Content) -> some View {
        let modalSize = theme.modalSize(size)
        _ = modalSize
        return content
            .sheet(isPresented: $isPresented) {
                modal()
#if os(macOS)
                    .frame(
                        minWidth: modalSize.width,
                        maxWidth: isFixedWidth ? modalSize.width : nil,
                        minHeight: modalSize.height,
                        maxHeight: isFixedHeight ? modalSize.height : nil
                    )
#endif
                    .interactiveDismissDisabled(!isInteractive)
                    .themeLockScreen()
            }
    }
}

struct ThemeItemModalModifier<Modal, T>: ViewModifier where Modal: View, T: Identifiable {

    @EnvironmentObject
    private var theme: Theme

    @Binding
    var item: T?

    let size: ThemeModalSize

    let isFixedWidth: Bool

    let isFixedHeight: Bool

    let isInteractive: Bool

    let modal: (T) -> Modal

    func body(content: Content) -> some View {
        let modalSize = theme.modalSize(size)
        _ = modalSize
        return content
            .sheet(item: $item) {
                modal($0)
#if os(macOS)
                    .frame(
                        minWidth: modalSize.width,
                        maxWidth: isFixedWidth ? modalSize.width : nil,
                        minHeight: modalSize.height,
                        maxHeight: isFixedHeight ? modalSize.height : nil
                    )
#endif
                    .interactiveDismissDisabled(!isInteractive)
                    .themeLockScreen()
            }
    }
}

struct ThemeConfirmationModifier: ViewModifier {

    @Binding
    var isPresented: Bool

    let title: String

    let message: String?

    let isDestructive: Bool

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                Button(Strings.Theme.Confirmation.ok, role: isDestructive ? .destructive : nil, action: action)
                Text(Strings.Theme.Confirmation.cancel)
            } message: {
                Text(message ?? Strings.Theme.Confirmation.message)
            }
    }
}

struct ThemeNavigationStackModifier: ViewModifier {

    @Environment(\.dismiss)
    private var dismiss

    let closable: Bool

    @Binding
    var path: NavigationPath

    func body(content: Content) -> some View {
        NavigationStack(path: $path) {
            content
                .toolbar {
                    if closable {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
                            } label: {
                                ThemeCloseLabel()
                            }
                        }
                    }
                }
        }
    }
}

// MARK: - Content modifiers

struct ThemeManualInputModifier: ViewModifier {
}

struct ThemeSectionWithHeaderFooterModifier: ViewModifier {
    let header: String?

    let footer: String?
}

struct ThemeRowWithFooterModifier: ViewModifier {
    let footer: String?
}

struct ThemeEmptyMessageModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    let fullScreen: Bool

    func body(content: Content) -> some View {
        VStack {
            if fullScreen {
                Spacer()
            }
            content
                .font(theme.emptyMessageFont)
                .foregroundStyle(theme.emptyMessageColor)
            if fullScreen {
                Spacer()
            }
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

struct ThemeProgressViewModifier<EmptyContent>: ViewModifier where EmptyContent: View {
    let isProgressing: Bool

    var isEmpty: Bool?

    var emptyContent: (() -> EmptyContent)?

    func body(content: Content) -> some View {
        ZStack {
            content
                .opaque(!isProgressing && isEmpty != true)

            if isProgressing {
                ThemeProgressView()
            } else if let isEmpty, let emptyContent, isEmpty {
                emptyContent()
            }
        }
    }
}

struct ThemeTrailingValueModifier: ViewModifier {
    let value: CustomStringConvertible?

    let truncationMode: Text.TruncationMode

    func body(content: Content) -> some View {
        LabeledContent {
            if let value {
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

#if !os(tvOS)

struct ThemeWindowModifier: ViewModifier {
    let size: CGSize
}

struct ThemePlainButtonModifier: ViewModifier {
    let action: () -> Void
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

struct ThemeLockScreenModifier<LockedContent>: ViewModifier where LockedContent: View {

    @AppStorage(AppPreference.locksInBackground.key)
    private var locksInBackground = false

    @EnvironmentObject
    private var theme: Theme

    @ViewBuilder
    let lockedContent: () -> LockedContent

    func body(content: Content) -> some View {
        LockableView(
            locksInBackground: locksInBackground,
            content: {
                content
            },
            lockedContent: lockedContent,
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
                localizedReason: Strings.Theme.LockScreen.reason(Strings.Unlocalized.appName)
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
