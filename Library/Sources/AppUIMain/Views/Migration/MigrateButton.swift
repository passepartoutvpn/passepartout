//
//  MigrateButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/16/24.
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

import SwiftUI

struct MigrateButton: View {
    let step: MigrateViewStep

    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .disabled(!isEnabled)
    }
}

private extension MigrateButton {
    var title: String {
        switch step {
        case .initial, .fetching, .fetched:
            return Strings.Views.Migration.Items.migrate

        case .migrating, .migrated:
            return Strings.Global.Nouns.done
        }
    }

    var isEnabled: Bool {
        switch step {
        case .initial, .fetching, .migrating:
            return false

        case .fetched(let profiles):
            return !profiles.isEmpty

        case .migrated:
            return true
        }
    }
}
