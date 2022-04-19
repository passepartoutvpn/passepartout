//
//  Providers+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

import Foundation
import PassepartoutCore

extension ProviderManager {
//    func localizedLocation(forProfile profile: Profile) -> String? {
//        return profile.providerServer(self)?.localizedDescription
//    }

    func localizedPreset(forProfile profile: Profile) -> String? {
        guard let server = profile.providerServer(self) else {
            return nil
        }
        return profile.providerPreset(server)?.localizedDescription
    }
    
    func localizedInfrastructureUpdate(forProfile profile: Profile) -> String? {
        guard let providerName = profile.header.providerName else {
            return nil
        }
        return lastUpdate(providerName, vpnProtocol: profile.currentVPNProtocol)?.timestamp
    }
}

extension ProviderMetadata {
    var localizedGuidanceString: String? {
        let prefix = "account.sections.guidance.footer.infrastructure"
        let key = "\(prefix).\(name)"
        var format = NSLocalizedString(key, bundle: .main, comment: "")

        // i.e. key not found
        if format == key {
            let purpose = name.credentialsPurpose
            let defaultKey = "\(prefix).default.\(purpose)"
            format = NSLocalizedString(defaultKey, bundle: .main, comment: "")
        }

        return String(format: format, locale: .current, description)
    }
}

extension ProviderLocation {
    var localizedCountry: String {
        return countryCode.localizedAsCountryCode
    }
}

extension ProviderServer {
    var localizedCountry: String {
        return countryCode.localizedAsCountryCode
    }

    var localizedDescription: String {
        var comps: [String] = [localizedCountry]
        details.map {
            comps.append($0)
        }
        return comps.joined(separator: " - ")
    }

    var localizedDetails: String {
        return details ?? ""
    }

    var localizedDetailsWithDefault: String {
        return details ?? L10n.Global.Strings.default
    }
}

extension ProviderServer.Preset {
    var localizedDescription: String {
        return name
    }
}
