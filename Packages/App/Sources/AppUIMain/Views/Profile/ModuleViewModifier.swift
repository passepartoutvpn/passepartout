//
//  ModuleViewModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/9/24.
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

import PassepartoutKit
import SwiftUI
import UIAccessibility

struct ModuleViewModifier<T>: ViewModifier where T: ModuleBuilder & Equatable {

    @Environment(\.isUITesting)
    private var isUITesting

    @ObservedObject
    var editor: ProfileEditor

    let draft: T

    let withUUID: Bool

    func body(content: Content) -> some View {
        Form {
            content
#if DEBUG
            if !isUITesting && withUUID {
                Section {
                    UUIDText(uuid: draft.id)
                }
            }
#endif
        }
        .themeForm()
        .themeManualInput()
        .themeAnimation(on: draft, category: .modules)
    }
}

extension View {
    func moduleView<T>(editor: ProfileEditor, draft: T, withUUID: Bool = true) -> some View where T: ModuleBuilder & Equatable {
        modifier(ModuleViewModifier(editor: editor, draft: draft, withUUID: withUUID))
    }
}
