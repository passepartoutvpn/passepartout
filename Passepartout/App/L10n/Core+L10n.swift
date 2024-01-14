//
//  Core+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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

import Foundation
import PassepartoutLibrary

extension ObservableVPNState: StyledLocalizableEntity {
    public enum Style {
        case status(isActiveProfile: Bool, withErrors: Bool, dataCountIfAvailable: Bool)
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .status(let isActiveProfile, let withErrors, let dataCountIfAvailable):
            return statusDescription(isActiveProfile: isActiveProfile, withErrors: withErrors, dataCountIfAvailable: dataCountIfAvailable)
        }
    }

    private func statusDescription(isActiveProfile: Bool, withErrors: Bool, dataCountIfAvailable: Bool) -> String {
        guard isActiveProfile && isEnabled else {
            return L10n.Tunnelkit.Vpn.disabled
        }
        if withErrors, let lastError {
            return AppError(lastError).localizedDescription
        }
        if dataCountIfAvailable, vpnStatus == .connected, let dataCount = dataCount {
            return dataCount.localizedDescription
        }
        return vpnStatus.localizedDescription
    }
}

extension Profile: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.header < rhs.header
    }
}

extension Profile.Header: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name.lowercased() < rhs.name.lowercased()
    }
}

extension Profile.OpenVPNSettings: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case endpoint
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .endpoint:
            return endpointDescription
        }
    }

    private var endpointDescription: String? {
        customEndpoint?.address ?? configuration.remotes?.first?.address
    }
}

extension Profile.WireGuardSettings: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case endpoint
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .endpoint:
            return endpointDescription
        }
    }

    private var endpointDescription: String? {
        configuration.tunnelConfiguration.peers.first?.endpoint?.stringRepresentation
    }
}

extension Profile.OnDemand.Policy: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .any:
            return L10n.OnDemand.Policy.any

        case .including:
            return L10n.OnDemand.Policy.including

        case .excluding:
            return L10n.OnDemand.Policy.excluding
        }
    }
}

extension Network.Choice: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .automatic:
            return L10n.Global.Strings.automatic

        case .manual:
            return L10n.Global.Strings.manual
        }
    }
}

extension Network.DNSSettings.ConfigurationType: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .plain:
            return Unlocalized.DNS.plain

        case .https:
            return Unlocalized.Network.https

        case .tls:
            return Unlocalized.Network.tls

        case .disabled:
            return L10n.Global.Strings.disabled
        }
    }
}

extension Network.ProxySettings.ConfigurationType: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .manual:
            return L10n.Global.Strings.manual

        case .pac:
            return Unlocalized.Network.proxyAutoConfiguration

        case .disabled:
            return L10n.Global.Strings.disabled
        }
    }
}

extension Profile.Account.AuthenticationMethod: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .persistent:
            return L10n.Account.Items.AuthenticationMethod.persistent

        case .interactive:
            return L10n.Account.Items.AuthenticationMethod.interactive

        case .totp:
            return Unlocalized.Other.totp
        }
    }
}

extension Int: StyledLocalizableEntity {
    public enum Style {
        case mtu
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .mtu:
            return mtuDescription
        }
    }

    private var mtuDescription: String {
        guard self != 0 else {
            return L10n.Global.Strings.default
        }
        return description
    }
}
