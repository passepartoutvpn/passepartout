//
//  Theme.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/18/24.
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

import SwiftUI
import UtilsLibrary

@MainActor
public final class Theme: ObservableObject {
    public internal(set) var rootModalSize: CGSize?

    public internal(set) var secondaryModalSize: CGSize?

    public internal(set) var popoverSize: CGSize?

    public internal(set) var relevantWeight: Font.Weight = .semibold

    public internal(set) var titleColor: Color = .primary

    public internal(set) var valueColor: Color = .secondary

    public internal(set) var gridHeaderStyle: Font = .headline

    public internal(set) var gridRadius: CGFloat = 12.0

    public internal(set) var gridHeaderBottom: CGFloat = 8.0

    public internal(set) var gridCellColor: HierarchicalShapeStyle = .quinary

    public internal(set) var gridCellActiveColor: HierarchicalShapeStyle = .quaternary

    public internal(set) var emptyMessageFont: Font = .title

    public internal(set) var emptyMessageColor: Color = .secondary

    public internal(set) var primaryColor = Color(red: 0.318, green: 0.365, blue: 0.443)

    public internal(set) var activeColor = Color(red: .zero, green: Double(0xAA) / 255.0, blue: .zero)

    public internal(set) var inactiveColor: Color = .gray

    public internal(set) var pendingColor: Color = .orange

    public internal(set) var errorColor: Color = .red

    private var animation: Animation = .spring

    public internal(set) var animationCategories: Set<ThemeAnimationCategory> = Set(ThemeAnimationCategory.allCases)

    public internal(set) var logoImage = "Logo"

    public internal(set) var systemImageName: (ImageName) -> String = Theme.ImageName.defaultSystemName

    public internal(set) var menuImageName: (MenuImageName) -> String = Theme.MenuImageName.defaultImageName

    init(dummy: Void) {
    }

    public func animation(for category: ThemeAnimationCategory) -> Animation? {
        animationCategories.contains(category) ? animation : nil
    }
}

#if !os(tvOS)

// MARK: - Modifiers

extension View {
    public func themeWindow(width: CGFloat, height: CGFloat) -> some View {
        modifier(ThemeWindowModifier(size: .init(width: width, height: height)))
    }

    public func themeNavigationDetail() -> some View {
        modifier(ThemeNavigationDetailModifier())
    }

    public func themeForm() -> some View {
        modifier(ThemeFormModifier())
    }

    public func themeModal<Content>(
        isPresented: Binding<Bool>,
        isRoot: Bool = false,
        isInteractive: Bool = true,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(ThemeBooleanModalModifier(
            isPresented: isPresented,
            isRoot: isRoot,
            isInteractive: isInteractive,
            modal: content
        ))
    }

    public func themeModal<Content, T>(
        item: Binding<T?>,
        isRoot: Bool = false,
        isInteractive: Bool = true,
        content: @escaping (T) -> Content
    ) -> some View where Content: View, T: Identifiable {
        modifier(ThemeItemModalModifier(
            item: item,
            isRoot: isRoot,
            isInteractive: isInteractive,
            modal: content
        ))
    }

    public func themePopover<Content>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(ThemeBooleanPopoverModifier(
            isPresented: isPresented,
            popover: content
        ))
    }

    public func themeConfirmation(
        isPresented: Binding<Bool>,
        title: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(ThemeConfirmationModifier(
            isPresented: isPresented,
            title: title,
            isDestructive: isDestructive,
            action: action
        ))
    }

    public func themeNavigationStack(if condition: Bool, closable: Bool = false, path: Binding<NavigationPath>) -> some View {
        modifier(ThemeNavigationStackModifier(condition: condition, closable: closable, path: path))
    }

    public func themePlainButton(action: @escaping () -> Void) -> some View {
        modifier(ThemePlainButtonModifier(action: action))
    }

    public func themeManualInput() -> some View {
        modifier(ThemeManualInputModifier())
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

    public func themeEmptyMessage() -> some View {
        modifier(ThemeEmptyMessageModifier())
    }

    public func themeError(_ isError: Bool) -> some View {
        modifier(ThemeErrorModifier(isError: isError))
    }

    public func themeAnimation<T>(on value: T, category: ThemeAnimationCategory) -> some View where T: Equatable {
        modifier(ThemeAnimationModifier(value: value, category: category))
    }

    public func themeTrailingValue(_ value: CustomStringConvertible?, truncationMode: Text.TruncationMode = .tail) -> some View {
        modifier(ThemeTrailingValueModifier(value: value, truncationMode: truncationMode))
    }

    public func themeSection(header: String? = nil, footer: String? = nil) -> some View {
        modifier(ThemeSectionWithHeaderFooterModifier(header: header, footer: footer))
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

    public func themeLockScreen(_ theme: Theme) -> some View {
        modifier(ThemeLockScreenModifier(theme: theme))
    }

    public func themeTip(_ text: String, edge: Edge) -> some View {
        modifier(ThemeTipModifier(text: text, edge: edge))
    }
}

// MARK: - Views

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
