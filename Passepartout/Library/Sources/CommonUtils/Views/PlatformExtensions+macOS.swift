//
//  PlatformExtensions+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/30/24.
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

#if os(macOS)

public enum EditMode {
    case inactive

    case active

    case transient
}

private struct EditModeEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Binding<EditMode>?
}

extension EnvironmentValues {
    public var editMode: Binding<EditMode>? {
        get {
            self[EditModeEnvironmentKey.self]
        }
        set {
            self[EditModeEnvironmentKey.self] = newValue
        }
    }
}

extension View {
    public func cursor(_ cursor: CursorType) -> some View {
        onHover {
            if $0 {
                cursor.nsCursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

private extension CursorType {
    var nsCursor: NSCursor {
        switch self {
        case .hand:
            return .pointingHand
        }
    }
}

#endif
