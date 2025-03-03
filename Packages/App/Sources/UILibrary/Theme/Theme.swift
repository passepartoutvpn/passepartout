//
//  Theme.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/18/24.
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

import CommonUtils
import SwiftUI

@MainActor
public final class Theme: ObservableObject {
    private var animation: Animation = .spring

    public internal(set) var animationCategories: Set<ThemeAnimationCategory> = Set(ThemeAnimationCategory.allCases)

    public internal(set) var relevantWeight: Font.Weight = .semibold

    public internal(set) var secondaryWeight: Font.Weight = .light

    public internal(set) var titleColor: Color = .primary

    public internal(set) var valueColor: Color = .secondary

    public internal(set) var gridHeaderStyle: Font = .headline

    public internal(set) var gridRadius: CGFloat = 12.0

    public internal(set) var gridHeaderBottom: CGFloat = 8.0

    public internal(set) var gridCellColor: HierarchicalShapeStyle = .quinary

    public internal(set) var gridCellActiveColor: HierarchicalShapeStyle = .quaternary

    public internal(set) var emptyMessageFont: Font = .title

    public internal(set) var emptyMessageColor: Color = .secondary

    public internal(set) var lightAccentColor: Color = .accentColor // gold

    public internal(set) var darkAccentColor = Color(hex: 0x515d70) // blue

    public internal(set) var activeColor = Color(hex: 0x00aa00)

    public internal(set) var inactiveColor: Color = .secondary

    public internal(set) var pendingColor: Color = .orange

    public internal(set) var errorColor: Color = .red

    public var enableColor: Color {
        activeColor
    }

    public var disableColor: Color {
        errorColor
    }

    public var upgradeColor: Color {
        pendingColor
    }

    public func backgroundColor(_ scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
#if os(iOS)
            return Color(.systemBackground)
#elseif os(macOS)
            return Color(.windowBackgroundColor)
#else
            return .black
#endif
        default:
            return darkAccentColor
        }
    }

    public internal(set) var logoImage = "Logo"

    public internal(set) var modalSize: (ThemeModalSize) -> CGSize = {
        $0.defaultSize
    }

    public internal(set) var systemImageName: (ImageName) -> String = Theme.ImageName.defaultSystemName

    public internal(set) var menuImageName: (MenuImageName) -> String = Theme.MenuImageName.defaultImageName

    init(dummy: Void) {
    }

    public func animation(for category: ThemeAnimationCategory) -> Animation? {
        animationCategories.contains(category) ? animation : nil
    }
}
