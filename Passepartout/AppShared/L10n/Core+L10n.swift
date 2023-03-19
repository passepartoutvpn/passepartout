//
//  Core+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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

extension Error {
    var localizedAppDescription: String {
        if let errorDescription = (self as? PassepartoutError)?.localizedAppDescription, !errorDescription.isEmpty {
            return "\(errorDescription)."
        }
        return localizedDescription
    }
}

extension PassepartoutError {
    var localizedAppDescription: String? {
        let V = L10n.Global.Errors.self
        switch self {
        case .missingProfile:
            return V.missingProfile

        case .missingAccount:
            return V.missingAccount

        case .missingProviderServer:
            return V.missingProviderServer

        case .missingProviderPreset:
            return V.missingProviderPreset

        default:
            return nil
        }
    }
}

extension ObservableVPNState {
    func localizedStatusDescription(isActiveProfile: Bool, withErrors: Bool, dataCountIfAvailable: Bool) -> String {
        guard isActiveProfile && isEnabled else {
            return L10n.Tunnelkit.Vpn.disabled
        }
        if withErrors {
            if let errorDescription = lastError?.localizedVPNDescription, !errorDescription.isEmpty {
                return errorDescription
            }
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

extension Profile.OpenVPNSettings {
    var endpointDescription: String? {
        customEndpoint?.address ?? configuration.remotes?.first?.address
    }
}

extension Profile.WireGuardSettings {
    var endpointDescription: String? {
        configuration.tunnelConfiguration.peers.first?.endpoint?.stringRepresentation
    }
}

extension Network.Choice {
    var localizedDescription: String {
        switch self {
        case .automatic:
            return L10n.Global.Strings.automatic

        case .manual:
            return L10n.Global.Strings.manual
        }
    }
}

extension Network.DNSSettings.ConfigurationType {
    var localizedDescription: String {
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

extension Network.ProxySettings.ConfigurationType {
    var localizedDescription: String {
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
