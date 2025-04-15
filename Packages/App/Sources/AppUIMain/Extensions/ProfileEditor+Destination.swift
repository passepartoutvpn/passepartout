//
//  ProfileEditor+Destination.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/12/25.
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

extension View {
    public func navigationDestination(for editor: ProfileEditor, path: Binding<NavigationPath>) -> some View {
        navigationDestination(for: ProfileRoute.self) { route in
            editor.destinationHandler(for: route.wrapped)
                .map { handler in
                    AnyView(handler.moduleDestination(
                        for: route.wrapped,
                        path: path,
                        editor: editor
                    ))
                }
        }
    }
}

private extension ProfileEditor {
    func destinationHandler(for route: AnyHashable) -> (any ModuleBuilder & ModuleDestinationProviding)? {
        modules.first {
            guard let handler = $0 as? any ModuleDestinationProviding else {
                return false
            }
            return handler.handlesRoute(route)
        } as? any ModuleBuilder & ModuleDestinationProviding
    }
}
