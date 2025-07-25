//
//  AppError+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

extension AppError: LocalizedError {
    public var errorDescription: String? {
        let V = Strings.Errors.App.self
        switch self {
        case .couldNotLaunch(let reason):
            return reason.localizedDescription

        case .emptyProducts:
            return V.emptyProducts

        case .emptyProfileName:
            return V.emptyProfileName

        case .ineligibleProfile:
            return nil

        case .interactiveLogin:
            return nil

        case .malformedModule(let module, let error):
            return V.malformedModule(module.moduleType.localizedDescription, error.localizedDescription)

        case .moduleRequiresConnection(let module):
            let connectionTypes = ModuleType.allCases.filter(\.isConnection)
            return V.moduleRequiresConnection(
                module.moduleType.localizedDescription,
                connectionTypes
                    .map(\.localizedDescription)
                    .joined(separator: ", ")
            )

        case .notFound:
            return nil

        case .partout(let error):
            return error.localizedDescription

        case .permissionDenied:
            return V.permissionDenied

        // handled manually
        case .rateLimit:
            return nil

        case .systemExtension:
            assertionFailure("AppError.systemExtension should be handled in AppCoordinator")
            return nil

        case .timeout:
            return Strings.Errors.App.Passepartout.timeout

        // handled manually
        case .unexpectedResponse:
            return nil

        case .unknown:
            return nil

        // handled manually
        case .verificationReceiptIsLoading, .verificationRequiredFeatures:
            return nil

        case .webReceiver:
            return Strings.Errors.App.webReceiver

        case .webUploader(let status, let error):
            switch status {
            case 403:
                return Strings.WebUploader.Errors.incorrectPasscode
            case 404:
                return Strings.WebUploader.Errors.urlNotFound
            default:
                return error?.localizedDescription
            }
        }
    }
}

// MARK: - App side

extension PartoutError: @retroactive LocalizedError {
    public var errorDescription: String? {
        let V = Strings.Errors.App.Passepartout.self
        switch code {
        case .Providers.corruptModule:
            return V.corruptProviderModule(reason?.localizedDescription ?? "")

        case .incompatibleModules:
            return V.incompatibleModules

        case .incompleteModule:
            guard let builder = userInfo as? any ModuleBuilder else {
                break
            }
            return V.incompleteModule(builder.moduleType.localizedDescription)

        case .invalidFields:
            let fields = (userInfo as? [String: String?])
                .map {
                    $0.map {
                        "\($0)=\($1?.description ?? "")"
                    }
                    .joined(separator: ",")
                }

            return [V.invalidFields, fields]
                .compactMap { $0 }
                .joined(separator: " ")

        case .Providers.missingEntity:
            return V.missingProviderEntity

        case .noActiveModules:
            return V.noActiveModules

        case .parsing:
            let message = userInfo as? String ?? (reason as? LocalizedError)?.localizedDescription

            return [V.parsing, message]
                .compactMap { $0 }
                .joined(separator: " ")

        case .timeout:
            return V.timeout

        case .unhandled:
            return reason?.localizedDescription

        default:
            break
        }
        return V.default(code.rawValue)
    }
}

// MARK: - Tunnel side

extension PartoutError.Code: StyledLocalizableEntity {
    public enum Style {
        case tunnel
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .tunnel:
            let V = Strings.Errors.Tunnel.self
            switch self {
            case .App.ineligibleProfile:
                return V.ineligible

            case .authentication:
                return V.auth

            case .crypto:
                return V.encryption

            case .dnsFailure:
                return V.dns

            case .timeout:
                return Strings.Global.Nouns.timeout

            case .OpenVPN.compressionMismatch:
                return V.compression

            case .OpenVPN.noRouting:
                return V.routing

            case .OpenVPN.serverShutdown:
                return V.shutdown

            case .OpenVPN.tlsFailure:
                return V.tls

            default:
                return V.generic
            }
        }
    }
}
