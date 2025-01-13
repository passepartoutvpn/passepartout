//
//  ModuleDraftEditing+UI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/24.
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

import PassepartoutKit
import SwiftUI

@MainActor
extension ModuleDraftEditing {
    public var draft: Binding<Draft> {
        editor[module]
    }
}

@MainActor
extension ModuleDraftEditing where Draft: MutableProviderSelecting {
    public var providerId: Binding<ProviderID?> {
        Binding {
            draft.providerId.wrappedValue
        } set: {
            draft.providerId.wrappedValue = $0
        }
    }

    public var providerEntity: Binding<Draft.CustomProviderSelection.Entity?> {
        Binding {
            draft.providerEntity.wrappedValue
        } set: {
            draft.providerEntity.wrappedValue = $0
        }
    }

    public var providerOptions: Binding<Set<Draft.CustomProviderSelection.Option>?> {
        Binding {
            draft.providerOptions.wrappedValue
        } set: {
            draft.providerOptions.wrappedValue = $0
        }
    }
}
