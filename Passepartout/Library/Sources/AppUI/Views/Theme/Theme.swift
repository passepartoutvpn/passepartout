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

//    @Published
//    private var palette: Palette
//
//    public init(palette: Palette) {
//        self.palette = palette
//    }

    var rootModalSize: CGSize?

    var secondaryModalSize: CGSize?

    var popoverSize: CGSize?

    var relevantWeight: Font.Weight = .semibold

    var titleColor: Color = .primary

    var valueColor: Color = .secondary

    var gridHeaderStyle: Font = .headline

    var gridRadius: CGFloat = 12.0

    var gridHeaderBottom: CGFloat = 8.0

    var gridCellColor: HierarchicalShapeStyle = .quinary

    var gridCellActiveColor: HierarchicalShapeStyle = .quaternary

    var emptyMessageFont: Font = .title

    var emptyMessageColor: Color = .secondary

    var primaryColor = Color(red: 0.318, green: 0.365, blue: 0.443)

    var activeColor = Color(red: .zero, green: Double(0xAA) / 255.0, blue: .zero)

    var inactiveColor: Color = .gray

    var pendingColor: Color = .orange

    var errorColor: Color = .red

    private var animation: Animation = .spring

    var animationCategories: Set<ThemeAnimationCategory> = Set(ThemeAnimationCategory.allCases)

    var logoImage = "Logo"

    var systemImageName: (ImageName) -> String = Theme.ImageName.defaultSystemName

    var menuImageName: (MenuImageName) -> String = Theme.MenuImageName.defaultImageName

    init(dummy: Void) {
    }

    func animation(for category: ThemeAnimationCategory) -> Animation? {
        animationCategories.contains(category) ? animation : nil
    }
}

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

    public func themeConfirmation(isPresented: Binding<Bool>, title: String, action: @escaping () -> Void) -> some View {
        modifier(ThemeConfirmationModifier(isPresented: isPresented, title: title, action: action))
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

    public func themeLockScreen() -> some View {
        modifier(ThemeLockScreenModifier())
    }

    public func themeTip(_ text: String, edge: Edge) -> some View {
        modifier(ThemeTipModifier(text: text, edge: edge))
    }
}

struct ThemeCountryFlag: View {
    let code: String?

    var placeholderTip: String?

    var countryTip: ((String) -> String?)?

    var body: some View {
        Group {
            if let code {
                let image = Image("flags/\(code.lowercased())")
                    .resizable()

                if let tip = countryTip?(code) {
                    image
                        .help(tip)
                } else {
                    image
                }
            } else {
                let image = Image(systemName: "globe")
                if let placeholderTip {
                    image
                        .help(placeholderTip)
                } else {
                    image
                }
            }
        }
        .frame(width: 20, height: 15)
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
