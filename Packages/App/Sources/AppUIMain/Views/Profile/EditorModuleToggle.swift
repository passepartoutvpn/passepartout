//
//  EditorModuleToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/11/24.
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

struct EditorModuleToggle<Label>: View where Label: View {

    @ObservedObject
    var profileEditor: ProfileEditor

    let module: any ModuleBuilder

    let label: () -> Label

    var body: some View {
        Toggle(isOn: isActiveBinding, label: label)
    }
}

private extension EditorModuleToggle {
    var isActiveBinding: Binding<Bool> {
        Binding {
            profileEditor.isActiveModule(withId: module.id)
        } set: { _ in
            profileEditor.toggleModule(withId: module.id)
        }
    }
}
