//
//  ProfileRow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/28/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

struct ProfileRow: View {
    let header: Profile.Header
    
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            nameView
                .font(.headline)
                .themeLongTextStyle()

            VPNStateView(isActive: isActive)
                .font(.subheadline)
                .themeSecondaryTextStyle()
        }.padding([.top, .bottom], 10)
    }

    private var nameView: some View {
        Text(header.name)
    }
    
    struct VPNStateView: View {
        @ObservedObject private var currentVPNState: VPNManager.ObservableState
        
        private let isActive: Bool

        init(isActive: Bool) {
            currentVPNState = .shared
            self.isActive = isActive
        }

        var body: some View {
            HStack {
//                Image(systemName: isActive ? "dot.radiowaves.up.forward" : "circle")
                if isActive {
                    Image(systemName: "circle.fill")
                    Text(statusDescription)
                    currentVPNState.dataCount.map {
                        Text($0.localizedDescription)
                    }
                } else {
                    Image(systemName: "circle")
                    Text(L10n.Tunnelkit.Vpn.unused)
                }
            }
        }

        private var statusDescription: String {
            if currentVPNState.vpnStatus != .disconnected {
                return currentVPNState.localizedStatusDescription(
                    withErrors: false,
                    dataCountIfAvailable: false
                )
            } else {
                return L10n.Organizer.Sections.active
            }
        }
    }
}
