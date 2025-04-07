//
//  AddModuleMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/25.
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
import Partout
import SwiftUI

// WARNING: Menu sections look good on physical device, whereas
// they erroneously inherit the List section styling on iOS Simulator
// and Previews (bug!)

struct AddModuleMenu<Label>: View where Label: View {
    let moduleTypes: [ModuleType]

    let action: (ModuleType) -> Void

    let label: () -> Label

    var body: some View {
        let providerType: ModuleType = .provider
        let nonProviderTypes = moduleTypes.filter { $0 != providerType }
        let connectionModuleTypes = nonProviderTypes.filter(\.isConnection)
        let otherModuleTypes = nonProviderTypes.filter { !$0.isConnection }
        return Menu {
            entryView(for: providerType)
            if !connectionModuleTypes.isEmpty {
                ForEach(connectionModuleTypes.sorted(), id: \.self, content: entryView)
                    .themeSection(header: Strings.Global.Nouns.connection)
            }
            if !otherModuleTypes.isEmpty {
                ForEach(otherModuleTypes.sorted(), id: \.self, content: entryView)
                    .themeSection(header: Strings.Global.Nouns.settings)
            }
        } label: {
            label()
        }
        .disabled(moduleTypes.isEmpty)
    }
}

private extension AddModuleMenu {
    func entryView(for moduleType: ModuleType) -> some View {
        Button(moduleType.localizedDescription) {
            action(moduleType)
        }
    }
}

#Preview {
    List {
        AddModuleMenu(
            moduleTypes: ModuleType.allCases,
            action: { _ in },
            label: {
                Text("Add module")
            }
        )
    }
}
