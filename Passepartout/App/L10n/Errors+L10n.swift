//
//  Errors+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/30/23.
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

extension AppError: LocalizedError {
    var errorDescription: String? {
        guard let errorDescriptionImpl, !errorDescriptionImpl.isEmpty else {
            return localizedDescription
        }
        return errorDescriptionImpl
    }

    private var errorDescriptionImpl: String? {
        let V = L10n.Global.Errors.self
        switch self {
        case .profile(let domainError):
            switch domainError {
            case .importFailure(let error):
                return error.localizedDescription

            case .decryptionFailure(let error):
                return error.localizedDescription

            case .notFound:
                return V.missingProfile

            case .failedToFetchProvider(_, let error):
                return error.localizedDescription
            }

        case .provider(let domainError):
            switch domainError {
            case .fetchFailure(let error):
                return error.localizedDescription
            }

        case .vpn(let domainError):
            switch domainError {
            case .notProvider:
                assertionFailure()
                return nil

            case .providerServerNotFound:
                return V.missingProviderServer

            case .providerPresetNotFound:
                return V.missingProviderPreset

            case .missingAccount:
                return V.missingAccount

            case .emptyEndpoints:
                assertionFailure()
                return nil
            }

        case .tunnel(let tunnelError):
            switch tunnelError {
            case .expired:
                return V.tunnelExpired
            }

        case .generic(let error):
            return error.localizedDescription
        }
    }
}

extension String {
    var withTrailingDot: String {
        guard !hasSuffix(".") else {
            return self
        }
        return "\(self)."
    }
}
