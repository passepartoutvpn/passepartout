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

    var systemImage: (ImageName) -> String = {
        switch $0 {
        case .add: return "plus"
        case .close: return "xmark"
        case .contextDuplicate: return "plus.square.on.square"
        case .contextRemove: return "trash"
        case .copy: return "doc.on.doc"
        case .disclose: return "chevron.down"
        case .editableSectionEdit: return "arrow.up.arrow.down"
        case .editableSectionRemove: return "trash"
        case .footerAdd: return "plus.circle"
        case .hide: return "eye.slash"
        case .info: return "info.circle"
        case .marked: return "checkmark"
        case .moreDetails: return "ellipsis.circle"
        case .pending: return "clock"
        case .profileEdit: return "square.and.pencil"
        case .profileImport: return "square.and.arrow.down"
        case .profilesGrid: return "square.grid.2x2"
        case .profilesList: return "rectangle.grid.1x2"
        case .remove: return "minus"
        case .settings: return "gearshape"
        case .share: return "square.and.arrow.up"
        case .show: return "eye"
        case .sleeping: return "powersleep"
        case .tunnelDisable: return "arrow.down"
        case .tunnelEnable: return "arrow.up"
        case .tunnelRestart: return "arrow.clockwise"
        case .tunnelToggle: return "power"
        case .tunnelUninstall: return "arrow.uturn.down"
        }
    }

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

    @ViewBuilder
    public func themeNavigationStack(if condition: Bool, path: Binding<NavigationPath>) -> some View {
        if condition {
            NavigationStack(path: path) {
                self
            }
        } else {
            self
        }
    }

    public func themePlainButton(action: @escaping () -> Void) -> some View {
        modifier(ThemePlainButtonModifier(action: action))
    }

    public func themeManualInput() -> some View {
        modifier(ThemeManualInputModifier())
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

    public func themeSectionWithFooter(_ footer: String?) -> some View {
        modifier(ThemeSectionWithFooterModifier(footer: footer))
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
