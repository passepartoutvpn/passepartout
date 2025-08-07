// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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
