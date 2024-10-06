//
//  DefaultModuleViewFactory.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
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

import Foundation
import PassepartoutKit
import SwiftUI

final class DefaultModuleViewFactory: ModuleViewFactory {

    @ViewBuilder
    func view(with editor: ProfileEditor, moduleId: UUID) -> some View {
        let result = editor.moduleViewProvider(withId: moduleId)
        if let result {
            AnyView(result.provider.moduleView(with: editor))
                .navigationTitle(result.title)
        }
    }
}

private extension ProfileEditor {
    func moduleViewProvider(withId moduleId: UUID) -> (provider: any ModuleViewProviding, title: String)? {
        guard let module = module(withId: moduleId) else {
//            assertionFailure("No module with ID \(moduleId)")
            return nil
        }
        guard let provider = module as? any ModuleViewProviding else {
            assertionFailure("\(type(of: module)) does not provide a default view")
            return nil
        }
        return (provider, module.typeDescription)
    }
}

extension View {

    @MainActor
    func asModuleView<T>(with editor: ProfileEditor, draft: T, withName: Bool = true) -> some View where T: ModuleBuilder, T: Equatable {
        Form {
            if withName {
                NameSection(
                    name: editor.binding(forNameOf: draft.id),
                    placeholder: draft.typeDescription
                )
            }
            self
        }
        .themeForm()
        .themeManualInput()
        .themeAnimation(on: draft, category: .modules)
    }
}
