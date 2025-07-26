// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

struct ProfileFlow {
    let onEditProfile: (ProfilePreview) -> Void

    let onMigrateProfiles: () -> Void

    let connectionFlow: ConnectionFlow?
}
