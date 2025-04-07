//
//  UILibrary.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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

import CommonAPI
import CommonLibrary
import Foundation
import Partout

@MainActor
public protocol UILibraryConfiguring {
    func configure(with context: AppContext)
}

public final class UILibrary: UILibraryConfiguring {
    private let uiConfiguring: UILibraryConfiguring?

    public init(_ uiConfiguring: UILibraryConfiguring?) {
        self.uiConfiguring = uiConfiguring
    }

    public func configure(with context: AppContext) {
        CommonLibrary().configure(.app)

        assertMissingImplementations(with: context.registry)
        context.appearanceManager.apply()
        uiConfiguring?.configure(with: context)
    }
}

private extension UILibrary {
    func assertMissingImplementations(with registry: Registry) {
        ModuleType.allCases.forEach { moduleType in
            let builder = moduleType.newModule(with: registry)
            do {
                // ModuleBuilder -> Module
                let module = try builder.tryBuild()

                // Module -> ModuleBuilder
                guard let moduleBuilder = module.moduleBuilder() else {
                    fatalError("\(moduleType): does not produce a ModuleBuilder")
                }

                // AppFeatureRequiring
                guard builder is any AppFeatureRequiring else {
                    fatalError("\(moduleType): #1 is not AppFeatureRequiring")
                }
                guard moduleBuilder is any AppFeatureRequiring else {
                    fatalError("\(moduleType): #2 is not AppFeatureRequiring")
                }
            } catch {
                if (error as? PassepartoutError)?.code == .incompleteModule {
                    return
                }
                fatalError("\(moduleType): empty module is not buildable: \(error)")
            }
        }
    }
}
