//
//  ReportIssueButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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
import PassepartoutKit
import SwiftUI

struct ReportIssueButton {

    @EnvironmentObject
    private var providerManager: ProviderManager

    @ObservedObject
    var profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    let title: String

    let purchasedProducts: Set<AppProduct>

    @Binding
    var isUnableToEmail: Bool

    @State
    var isPending = false

    @State
    var issueBeingReported: Issue?

    var installedProfile: Profile? {
        guard let id = tunnel.currentProfile?.id else {
            return nil
        }
        return profileManager.profile(withId: id)
    }

    var currentProvider: (ProviderID, Date?)? {
        guard let id = installedProfile?.firstProviderModuleWithMetadata?.1.id else {
            return nil
        }
        let lastUpdate = providerManager.lastUpdate(for: id)
        return (id, lastUpdate)
    }
}
