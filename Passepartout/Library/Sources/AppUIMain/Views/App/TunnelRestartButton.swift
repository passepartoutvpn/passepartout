//
//  TunnelRestartButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct TunnelRestartButton<Label>: View where Label: View {

    @ObservedObject
    var tunnel: ExtendedTunnel

    let profile: Profile?

    let errorHandler: ErrorHandler

    let onPurchaseRequired: (Set<AppFeature>) -> Void

    let label: () -> Label

    var body: some View {
        Button {
            guard let profile else {
                return
            }
            guard tunnel.status == .active else {
                return
            }
            Task {
                do {
                    try await tunnel.connect(with: profile)
                } catch AppError.ineligibleProfile(let requiredFeatures) {
                    onPurchaseRequired(requiredFeatures)
                } catch is CancellationError {
                    //
                } catch {
                    errorHandler.handle(
                        error,
                        title: profile.name,
                        message: Strings.Views.App.Errors.tunnel
                    )
                }
            }
        } label: {
            label()
        }
        .disabled(profile == nil || tunnel.status != .active)
    }
}
