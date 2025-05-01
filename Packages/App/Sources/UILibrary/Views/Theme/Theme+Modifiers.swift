//
//  Theme+Modifiers.swift
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

import CommonLibrary
import SwiftUI

// FIXME: ###, sort alphabetically

extension View {
    public func themeModal<Content>(
        isPresented: Binding<Bool>,
        options: ThemeModalOptions? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(ThemeBooleanModalModifier(
            isPresented: isPresented,
            options: options ?? ThemeModalOptions(),
            modal: content
        ))
    }

    public func themeModal<Content, T>(
        item: Binding<T?>,
        options: ThemeModalOptions? = nil,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View where Content: View, T: Identifiable {
        modifier(ThemeItemModalModifier(
            item: item,
            options: options ?? ThemeModalOptions(),
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
        onClose: (() -> Void)? = nil,
        path: Binding<NavigationPath> = .constant(NavigationPath())
    ) -> some View {
        modifier(ThemeNavigationStackModifier(closable: closable, onClose: onClose, path: path))
    }

    @ViewBuilder
    public func themeNavigationStack(
        if condition: Bool,
        closable: Bool = false,
        onClose: (() -> Void)? = nil,
        path: Binding<NavigationPath> = .constant(NavigationPath())
    ) -> some View {
        if condition {
            modifier(ThemeNavigationStackModifier(closable: closable, onClose: onClose, path: path))
        } else {
            self
        }
    }

    public func themeList() -> some View {
#if os(tvOS)
        listStyle(.grouped)
            .scrollClipDisabled()
#else
        self
#endif
    }

    public func themeForm() -> some View {
        formStyle(.grouped)
    }

    public func themeManualInput() -> some View {
        modifier(ThemeManualInputModifier())
    }

    public func themeSection(header: String? = nil, footer: String? = nil, forcesFooter: Bool = false) -> some View {
        modifier(ThemeSectionWithHeaderFooterModifier(header: header, footer: footer, forcesFooter: forcesFooter))
    }

    public func themeSectionWithSingleRow(header: String? = nil, footer: String, above: Bool = false) -> some View {
        Group {
            if above {
                EmptyView()
                    .themeRowWithSubtitle(footer) // macOS

                self
            } else {
                themeRowWithSubtitle(footer) // macOS
            }
        }
        .themeSection(header: header, footer: footer) // iOS/tvOS
    }

    // subtitle is hidden on iOS/tvOS
    public func themeRowWithSubtitle(_ subtitle: String?) -> some View {
        themeRowWithSubtitle {
            subtitle.map(Text.init)
        }
    }

    public func themeRowWithSubtitle<Subtitle>(_ subtitle: () -> Subtitle) -> some View where Subtitle: View {
        modifier(ThemeRowWithSubtitleModifier(subtitle: subtitle))
    }

    public func themeSubtitle() -> some View {
        foregroundStyle(.secondary)
            .font(.subheadline)
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

    @ViewBuilder
    public func themeEmpty<EmptyContent>(
        if isEmpty: Bool,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent
    ) -> some View where EmptyContent: View {
        if !isEmpty {
            self
        } else {
            emptyContent()
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

    public func themeGridHeader<Header>(@ViewBuilder header: () -> Header) -> some View where Header: View {
        modifier(ThemeGridSectionModifier(header: header))
    }

    public func themeGridCell() -> some View {
        modifier(ThemeGridCellModifier())
    }

    public func themeHoverListRow() -> some View {
        modifier(ThemeHoverListRowModifier())
    }

    @ViewBuilder
    public func themeTip(_ tip: AppTip) -> some View {
        if #available(iOS 18, macOS 15, *) {
            popoverTip(tip)
        } else {
            self
        }
    }

    public func themeTip<Label>(
        _ text: String,
        edge: Edge,
        width: Double = 150.0,
        alignment: Alignment = .center,
        label: @escaping () -> Label = {
            ThemeImage(.tip)
                .imageScale(.large)
        }
    ) -> some View where Label: View {
        modifier(ThemeTipModifier(
            text: text,
            edge: edge,
            width: width,
            alignment: alignment,
            label: label
        ))
    }
#endif

    public func themeKeyValue<T>(
        _ store: KeyValueManager,
        _ key: String,
        _ value: Binding<T>,
        default defaultValue: T
    ) -> some View where T: Equatable {
        modifier(ThemeKeyValueModifier(
            store: store,
            key: key,
            value: value,
            defaultValue: defaultValue
        ))
    }
}
