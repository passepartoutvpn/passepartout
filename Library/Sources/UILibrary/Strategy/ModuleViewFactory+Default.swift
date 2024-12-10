//
//  ModuleViewFactory+Default.swift
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

import CommonLibrary
import Foundation
import PassepartoutKit
import SwiftUI

public final class DefaultModuleViewFactory: ModuleViewFactory {
    private let registry: Registry

    public init(registry: Registry) {
        self.registry = registry
    }

    @ViewBuilder
    public func view(with editor: ProfileEditor, preferences: ModulePreferences, moduleId: UUID) -> some View {
        let result = editor.moduleViewProvider(withId: moduleId, registry: registry)
        if let result {
            AnyView(result.provider.moduleView(with: .init(
                editor: editor,
                preferences: preferences,
                impl: result.impl
            )))
            .navigationTitle(result.title)
        }
    }
}

private extension ProfileEditor {
    func moduleViewProvider(withId moduleId: UUID, registry: Registry) -> ModuleViewProviderResult? {
        guard let module = module(withId: moduleId) else {
//            assertionFailure("No module with ID \(moduleId)")
            return nil
        }
        guard let provider = module as? any ModuleViewProviding else {
            assertionFailure("\(type(of: module)) does not provide a default view")
            return nil
        }
        return ModuleViewProviderResult(
            title: module.moduleType.localizedDescription,
            provider: provider,
            impl: registry.implementation(for: module)
        )
    }
}

private struct ModuleViewProviderResult {
    let title: String

    let provider: any ModuleViewProviding

    let impl: ModuleImplementation?
}
