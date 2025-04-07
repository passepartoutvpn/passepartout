//
//  PassepartoutKit+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/24.
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
import Foundation
import Partout

extension Profile {
    public var localizedPreview: ProfilePreview {
        ProfilePreview(
            id: id,
            name: name,
            subtitle: localizedDescription(optionalStyle: .moduleTypes)
        )
    }
}

extension Profile: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case moduleTypes

        case primaryType

        case secondaryTypes
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .moduleTypes:
            return activeModules
                .nilIfEmpty?
                .map(\.moduleType.localizedDescription)
                .sorted()
                .joined(separator: ", ")

        case .primaryType:
            return activeModules
                .first {
                    primaryCondition(for: $0)
                }?
                .moduleType
                .localizedDescription

        case .secondaryTypes:
            return activeModules
                .filter {
                    !primaryCondition(for: $0)
                }
                .nilIfEmpty?
                .map(\.moduleType.localizedDescription)
                .sorted()
                .joined(separator: ", ")
        }
    }

    private func primaryCondition(for module: Module) -> Bool {
        module is ProviderModule || module.buildsConnection
    }
}

extension TunnelStatus: LocalizableEntity {
    public var localizedDescription: String {
        let V = Strings.Entities.TunnelStatus.self
        switch self {
        case .inactive:
            return V.inactive

        case .activating:
            return V.activating

        case .active:
            return V.active

        case .deactivating:
            return V.deactivating
        }
    }
}

extension DataCount: LocalizableEntity {
    public var localizedDescription: String {
        let down = received.descriptionAsDataUnit
        let up = sent.descriptionAsDataUnit
        return "↓\(down) ↑\(up)"
    }
}

extension Address.Family: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .v4:
            return Strings.Unlocalized.ipv4

        case .v6:
            return Strings.Unlocalized.ipv6
        }
    }
}

extension IPSettings: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case address

        case defaultGateway
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .address:
            return addressDescription

        case .defaultGateway:
            return defaultGatewayDescription
        }
    }

    private var addressDescription: String? {
        subnet?.address.rawValue
    }

    private var defaultGatewayDescription: String? {
        includedRoutes
            .first(where: \.isDefault)?
            .gateway?
            .rawValue
    }
}

extension Route: LocalizableEntity {
    public var localizedDescription: String {
        if let dest = destination?.rawValue {
            if let gw = gateway?.rawValue {
                return "\(dest) → \(gw)"
            } else {
                return dest
            }
        } else if let gw = gateway?.rawValue {
            return "default → \(gw)"
        }
        return "default → *"
    }
}

extension OnDemandModule.Policy: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .any:
            return Strings.Entities.OnDemand.Policy.any

        case .excluding:
            return Strings.Entities.OnDemand.Policy.excluding

        case .including:
            return Strings.Entities.OnDemand.Policy.including

        @unknown default:
            return Strings.Entities.OnDemand.Policy.any
        }
    }
}

extension ProviderID: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        rawValue
    }
}

extension ProviderEntity: LocalizableEntity {
    public var localizedDescription: String {
        heuristic?.localizedDescription ?? server.localizedDescription
    }
}

extension ProviderHeuristic: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .exact(let server):
            return server.localizedDescription
        case .sameCountry(let countryCode):
            return countryCode.localizedAsRegionCode ?? countryCode
        case .sameRegion(let region):
            return region.localizedDescription
        }
    }
}

extension ProviderRegion: LocalizableEntity {
    public var localizedDescription: String {
        [countryCode.localizedAsRegionCode, area]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

extension ProviderServer: LocalizableEntity {
    public var localizedDescription: String {
        [metadata.countryCode.localizedAsRegionCode, metadata.area]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

extension ProviderServer {
    public var localizedCountry: String? {
        metadata.countryCode.localizedAsRegionCode
    }

    public var address: String {
        if let hostname {
            return hostname
        }
        if let ipAddresses {
            return ipAddresses
                .compactMap {
                    guard let address = Address(data: $0) else {
                        return nil
                    }
                    return address.description
                }
                .joined(separator: ", ")
        }
        return ""
    }
}

extension OpenVPN.Credentials.OTPMethod: StyledLocalizableEntity {
    public enum Style {
        case entity

        case approachDescription
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .entity:
            let V = Strings.Entities.Openvpn.OtpMethod.self
            switch self {
            case .none:
                return V.none

            case .append:
                return V.append

            case .encode:
                return V.encode

            @unknown default:
                return V.none
            }

        case .approachDescription:
            let V = Strings.Modules.Openvpn.Credentials.OtpMethod.Approach.self
            switch self {
            case .none:
                return ""

            case .append:
                return V.append

            case .encode:
                return V.encode

            @unknown default:
                return ""
            }
        }
    }
}
