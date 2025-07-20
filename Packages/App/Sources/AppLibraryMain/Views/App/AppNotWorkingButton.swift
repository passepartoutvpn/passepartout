//
//  AppNotWorkingButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/20/25.
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

struct AppNotWorkingButton: View {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var iapManager: IAPManager

    @EnvironmentObject
    private var configManager: ConfigManager

    @ObservedObject
    var tunnel: ExtendedTunnel

    @State
    private var isUnableToEmail = false

    var body: some View {
        if configManager.flags.contains(.appNotWorking) {
            ReportIssueButton(
                title: Strings.AppNotWorking.title,
                message: Strings.AppNotWorking.message,
                tunnel: tunnel,
                apiManager: apiManager,
                purchasedProducts: iapManager.purchasedProducts,
                isUnableToEmail: $isUnableToEmail
            )
        }
    }
}

#Preview {
    AppNotWorkingButton(tunnel: .forPreviews)
        .withMockEnvironment()
}
