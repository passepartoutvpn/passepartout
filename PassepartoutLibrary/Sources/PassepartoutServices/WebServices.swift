//
//  WebServices.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/14/18.
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
import Combine
import PassepartoutUtils

public enum WebError: GenericWebServicesError, LocalizedError {
    case http(Int)

    case emptyResponse

    case unknown

    public static func httpStatus(_ status: Int) -> WebError {
        .http(status)
    }

    public var errorDescription: String? {
        switch self {
        case .http(let status):
            return "HTTP \(status)"

        case .emptyResponse:
            return "Empty response"

        default:
            return nil
        }
    }
}

public protocol WebServices {
    func providersIndex() -> AnyPublisher<WSProvidersIndex, Error>

    func providerNetwork(
        with name: WSProviderName,
        vpnProtocol: WSVPNProtocol,
        ifModifiedSince lastModified: Date?
    ) -> AnyPublisher<GenericWebResponse<WSProviderInfrastructure>, Error>
}
