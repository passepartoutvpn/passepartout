//
//  ActiveProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

import AppLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ActiveProfileView: View {
    let profile: Profile?

    @ObservedObject
    var tunnel: ExtendedTunnel

    @Binding
    var isSwitching: Bool

    @FocusState.Binding
    var focusedField: ProfileView.Field?

    @ObservedObject
    var interactiveManager: InteractiveManager

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        VStack {
            VStack {
                currentProfileView
                statusView
                Group {
                    toggleConnectionButton
                    switchProfileButton
                }
                .padding(.horizontal, 100)
            }
            .padding(.top, 100)

            Spacer()
        }
    }
}

private extension ActiveProfileView {
    var currentProfileView: some View {
        Text(profile?.name ?? Strings.Views.Profiles.Rows.notInstalled)
            .font(.title)
            .fontWeight(.bold)
    }

    var statusView: some View {
        ConnectionStatusText(tunnel: tunnel)
            .font(.title2)
    }

    var toggleConnectionButton: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profile,
            nextProfileId: .constant(nil),
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            label: {
                Text($0 ? Strings.Global.connect : Strings.Global.disconnect)
                    .frame(maxWidth: .infinity)
            }
        )
        .focused($focusedField, equals: .connect)
    }

    var switchProfileButton: some View {
        Button {
            isSwitching.toggle()
        } label: {
            Text(Strings.Global.select)
                .frame(maxWidth: .infinity)
        }
        .focused($focusedField, equals: .switchProfile)
    }
}
