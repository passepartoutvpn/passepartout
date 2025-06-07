//
//  ActiveTunnelButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/7/25.
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
import CommonUtils
import SwiftUI
import UILibrary

struct ActiveTunnelButton: View {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    var tunnel: ExtendedTunnel

    let profile: Profile?

    @FocusState.Binding
    var focusedField: ConnectionView.Field?

    let errorHandler: ErrorHandler

    let flow: ConnectionFlow?

    var body: some View {
        TunnelToggle(
            tunnel: tunnel,
            profile: profile,
            errorHandler: errorHandler,
            flow: flow
        ) { isOn, canInteract in
            Button(!isOn.wrappedValue ? Strings.Global.Actions.connect : Strings.Global.Actions.disconnect) {
                isOn.wrappedValue.toggle()
            }
            .frame(maxWidth: .infinity)
            .fontWeight(theme.relevantWeight)
            .forMainButton(
                withColor: toggleConnectionColor,
                focused: focusedField == .connect,
                disabled: !canInteract
            )
        }
    }
}

private extension ActiveTunnelButton {
    var toggleConnectionColor: Color {
        guard let activeProfile = tunnel.activeProfile else {
            return theme.enableColor
        }
        switch activeProfile.status {
        case .inactive:
            return activeProfile.onDemand ? theme.disableColor : theme.enableColor
        default:
            return theme.disableColor
        }
    }
}
