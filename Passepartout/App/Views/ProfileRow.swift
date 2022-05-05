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
        debugChanges()
        return VStack(alignment: .leading, spacing: 5) {
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
        
//        @State private var connectedOpacity = 1.0

        init(isActive: Bool) {
            currentVPNState = .shared
            self.isActive = isActive
        }

        var body: some View {
            HStack {
                profileImage
                if isActive {
                    Text(statusDescription)
                    Spacer()
                    currentVPNState.dataCount.map {
                        Text($0.localizedDescription)
                    }
                } else {
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
        
        @ViewBuilder
        private var profileImage: some View {
            if isConnected {
                Image(systemName: themeProfileConnectedImage)
//                    .opacity(connectedOpacity)
//                    .onAppear {
//                        connectedOpacity = 1.0
//                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
//                            connectedOpacity = 0.05
//                        }
//                    }
            } else if isActive {
                Image(systemName: themeProfileActiveImage)
            } else {
                Image(systemName: themeProfileInactiveImage)
            }
        }
        
        private var isConnected: Bool {
            isActive && currentVPNState.vpnStatus == .connected
        }
    }
}
