//
//  AppUIMain.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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
@_exported import UILibrary

public final class AppUIMain: UILibraryConfiguring {
    public init() {
    }

    public func configure(with context: AppContext) {
        assertMissingImplementations(with: context.registry)
    }
}

private extension AppUIMain {
    func assertMissingImplementations(with registry: Registry) {
        let providerModuleTypes: Set<ModuleType> = [
            .openVPN
        ]
        ModuleType.allCases.forEach { moduleType in
            let builder = moduleType.newModule(with: registry)

            // ModuleViewProviding
            guard builder is any ModuleViewProviding else {
                fatalError("\(moduleType): is not ModuleViewProviding")
            }

            do {
                // ModuleBuilder -> Module
                let module = try builder.tryBuild()

                // Module -> ModuleBuilder
                guard module.moduleBuilder() != nil else {
                    fatalError("\(moduleType): does not produce a ModuleBuilder")
                }

                // AppFeatureRequiring
                guard builder is any AppFeatureRequiring else {
                    fatalError("\(moduleType): is not AppFeatureRequiring")
                }

                // ProviderEntityViewProviding
                if providerModuleTypes.contains(moduleType) {
                    guard module is any ProviderEntityViewProviding else {
                        fatalError("\(moduleType): is not ProviderEntityViewProviding")
                    }
                }
            } catch {
                fatalError("\(moduleType): empty module is not buildable")
            }
        }
    }
}
