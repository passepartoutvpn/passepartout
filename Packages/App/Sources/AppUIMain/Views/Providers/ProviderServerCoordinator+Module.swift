//
//  ProviderServerCoordinatorSupporting+Module.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/16/25.
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
import PassepartoutKit
import SwiftUI
import UILibrary

extension ProviderServerCoordinatorSupporting where Self: Module,
                                                    Self: BuildableType,
                                                    Self: ProviderSelecting,
                                                    B: MutableProviderSelecting,
                                                    CustomProviderSelection == B.CustomProviderSelection {
    public func providerServerCoordinator(
        selectTitle: String,
        onSelect: @escaping (Module) async throws -> Void,
        errorHandler: ErrorHandler
    ) -> AnyView {
        AnyView(providerSelection.map {
            ProviderServerCoordinator(
                moduleId: id,
                providerId: $0.id,
                selectedEntity: $0.entity,
                selectTitle: selectTitle,
                onSelect: {
                    var newBuilder = builder()
                    newBuilder.providerEntity = $0
                    let newModule = try newBuilder.tryBuild()
                    try await onSelect(newModule)
                },
                errorHandler: errorHandler
            )
        })
    }
}
