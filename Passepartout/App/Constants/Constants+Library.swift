//
//  Constants+Library.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation
import PassepartoutLibrary

extension Constants.App {
    static func tunnelBundleId(_ vpnProtocol: VPNProtocolType) -> String {
        guard let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String else {
            fatalError("Missing kCFBundleIdentifierKey from Info.plist")
        }
        switch vpnProtocol {
        case .openVPN:
            return "\(identifier).OpenVPNTunnel"

        case .wireGuard:
            return "\(identifier).WireGuardTunnel"
        }
    }
}

extension Constants.URLs {
    static let openVPNGuidances: [ProviderName: String] = [
        .protonvpn: "https://account.protonvpn.com/settings",
        .surfshark: "https://my.surfshark.com/vpn/manual-setup/main",
        .torguard: "https://torguard.net/clientarea.php?action=changepw",
        .windscribe: "https://windscribe.com/getconfig/openvpn"
    ]

    static let referrals: [ProviderName: String] = [
        .hideme: "https://member.hide.me/en/checkout?plan=new_default_prices&coupon=6CB-BDB-802&duration=24",
        .mullvad: "https://mullvad.net/en/account/create/",
        .nordvpn: "https://go.nordvpn.net/SH21Z",
        .pia: "https://www.privateinternetaccess.com/pages/buy-vpn/",
        .protonvpn: "https://proton.go2cloud.org/SHZ",
        .torguard: "https://torguard.net/",
        .tunnelbear: "https://www.tunnelbear.com/",
        .vyprvpn: "https://www.vyprvpn.com/",
        .windscribe: "https://secure.link/kCsD0prd"
    ]
}
