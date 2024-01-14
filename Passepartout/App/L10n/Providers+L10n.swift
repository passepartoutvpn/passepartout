//
//  Providers+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

extension ProviderManager: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case preset(profile: Profile)

        case infrastructureUpdate(profile: Profile)
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .preset(let profile):
            return presetDescription(forProfile: profile)

        case .infrastructureUpdate(let profile):
            return infrastructureUpdateDescription(forProfile: profile)
        }
    }

    private func presetDescription(forProfile profile: Profile) -> String? {
        guard let server = profile.providerServer(self) else {
            return nil
        }
        return profile.providerPreset(server)?.localizedDescription
    }

    private func infrastructureUpdateDescription(forProfile profile: Profile) -> String? {
        guard let providerName = profile.header.providerName else {
            return nil
        }
        return lastUpdate(providerName, vpnProtocol: profile.currentVPNProtocol)?.timestamp
    }
}

extension ProviderMetadata: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case guidance
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .guidance:
            return guidanceString
        }
    }

    private var guidanceString: String? {
        let prefix = "account.sections.guidance.footer.infrastructure"
        let key = "\(prefix).\(name)"
        var format = NSLocalizedString(key, bundle: .main, comment: "")

        // i.e. key not found
        if format == key {
            let purpose = name.credentialsPurpose
            let defaultKey = "\(prefix).default.\(purpose)"
            format = NSLocalizedString(defaultKey, bundle: .main, comment: "")
        }

        return String(format: format, locale: .current, fullName)
    }
}

extension ProviderLocation: StyledLocalizableEntity {
    public enum Style {
        case country
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .country:
            return countryDescription
        }
    }

    private var countryDescription: String {
        countryCode.localizedAsCountryCode
    }
}

extension ProviderServer: StyledLocalizableEntity {
    public enum Style {
        case country

        case countryWithCategory(withCategory: Bool)

        case shortWithDefault

        case longWithCategory(withCategory: Bool)
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .country:
            return countryDescription

        case .countryWithCategory(let withCategory):
            return countryDescription(withCategory: withCategory)

        case .shortWithDefault:
            return shortDescriptionWithDefault

        case .longWithCategory(let withCategory):
            return longDescription(withCategory: withCategory)
        }
    }

    private var countryDescription: String {
        countryCode.localizedAsCountryCode
    }

    private func countryDescription(withCategory: Bool) -> String {
        let desc = countryDescription
        if withCategory, !categoryName.isEmpty {
            return "\(categoryName.uppercased()): \(desc)"
        }
        return desc
    }

    private var shortDescriptionWithDefault: String {
        shortDescription ?? "\(L10n.Global.Strings.default) [\(apiId)]"
    }

    private func longDescription(withCategory: Bool) -> String {
        var comps: [String] = [countryDescription]
        shortDescription.map {
            comps.append($0)
        }
        let desc = comps.joined(separator: ", ")
        if withCategory, !categoryName.isEmpty {
            return "\(categoryName.uppercased()): \(desc)"
        }
        return desc
    }
}

extension ProviderServer: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case short
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .short:
            return shortDescription
        }
    }

    private var shortDescription: String? {
        var comps = localizedName.map { [$0] } ?? []
        if let serverIndex = serverIndex {
            comps.append("#\(serverIndex)")
        }
        guard !comps.isEmpty else {
            return nil
        }
        var str = comps.joined(separator: " ")
        if let tags = tags {
            let suffix = tags.map { $0.uppercased() }.joined(separator: ",")
            str = "\(str) (\(suffix))"
        }
        guard !str.isEmpty else {
            return nil
        }
        return str
    }
}

extension ProviderServer.Preset: LocalizableEntity {
    public var localizedDescription: String {
        name
    }
}
