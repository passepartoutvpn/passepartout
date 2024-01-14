//
//  ActiveProfileView+TV.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/18/23.
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

#if os(tvOS)
import PassepartoutLibrary
import SwiftUI

struct ActiveProfileView: View {
    @ObservedObject private var profileManager: ProfileManager

    @ObservedObject private var vpnState: ObservableVPNState

    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
        vpnState = .shared
    }

    var body: some View {
        Section {
            let activeProfile = profileManager.activeProfile
            nameView(for: activeProfile)
            if let activeProfile {
                toggleView(for: activeProfile)
                vpnProtocolView(for: activeProfile)
                statusView(for: activeProfile)
                if let expirationDate = activeProfile.connectionExpirationDate {
                    expirationView(at: expirationDate)
                }
            }
        }
        if let activeProfile = profileManager.activeProfile,
           let server = activeProfile.providerServer(.shared) {
            providerSection(with: server)
        }
    }
}

private extension ActiveProfileView {
    func nameView(for profile: Profile?) -> some View {
        NavigationLink {
            ProfilesListView(profileManager: profileManager)
        } label: {
            Text(L10n.Global.Placeholders.profileName)
                .withTrailingText(profile?.header.name)
        }
    }

    func vpnProtocolView(for profile: Profile) -> some View {
        Text(L10n.Global.Strings.protocol)
            .withTrailingText(profile.currentVPNProtocol.description)
    }

    func toggleView(for profile: Profile) -> some View {
        VPNToggle(
            profile: profile,
            interactiveProfile: .constant(nil),
            title: L10n.Profile.Items.ConnectionStatus.caption,
            rateLimit: Constants.RateLimit.vpnToggle
        )
    }

    func statusView(for activeProfile: Profile) -> some View {
        HStack {
            Text(Unlocalized.VPN.vpn)
            Spacer()
            if vpnState.isEnabled && activeProfile.isExpired {
                Text(L10n.Global.Errors.tunnelExpired)
                    .themeSecondaryTextStyle()
            } else {
                VPNStatusText(isActiveProfile: true)
                    .themeSecondaryTextStyle()
            }
        }
    }

    func expirationView(at expirationDate: Date) -> some View {
        Text(L10n.Profile.Items.ExpiresAt.caption)
            .withTrailingText(expirationDate.timestamp)
    }

    func providerSection(with server: ProviderServer) -> some View {
        Section {
            Text(L10n.Global.Strings.name)
                .withTrailingText(server.providerMetadata.fullName)
            HStack {
                Text(L10n.Provider.Location.title)
                Spacer()
                Label(server.localizedDescription(style: .country), image: themeAssetsCountryImage(server.countryCode))
                    .themeSecondaryTextStyle()
            }
        } header: {
            Text(L10n.Global.Strings.provider)
        }
    }
}
#endif
