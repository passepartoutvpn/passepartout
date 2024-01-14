//
//  APIWebServices.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/14/18.
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

import Combine
import Foundation
import PassepartoutCore
import PassepartoutServices

public final class APIWebServices: WebServices {
    private enum Group: String {
        case providers
    }

    private enum Endpoint: GenericWebEndpoint {
        case providersIndex

        case providerNetwork(WSProviderName, WSVPNProtocol)

        private var pathName: String {
            switch self {
            case .providersIndex:
                return [Group.providers.rawValue, "index"].joined(separator: "/")

            case .providerNetwork(let providerName, let vpnProtocol):
                return [Group.providers.rawValue, providerName, vpnProtocol.filename].joined(separator: "/")
            }
        }

        private var fileType: String {
            "json"
        }

        // MARK: GenericWebEndpoint

        var path: String {
            [pathName, fileType].joined(separator: ".")
        }
    }

    private let ws: GenericWebServices<APIError>

    public init(_ version: String, _ root: URL, timeout: TimeInterval?, queue: DispatchQueue = .main) {
        ws = GenericWebServices(version, root, timeout: timeout)
    }

    public func providersIndex() -> AnyPublisher<WSProvidersIndex, Error> {
        let request = ws.get(Endpoint.providersIndex)
        return ws.parse(WSProvidersIndex.self, request: request)
            .tryMap {
                guard let value = $0.value else {
                    throw APIError.emptyResponse
                }
                return value
            }.eraseToAnyPublisher()
    }

    public func providerNetwork(with name: WSProviderName, vpnProtocol: WSVPNProtocol, ifModifiedSince lastModified: Date?) -> AnyPublisher<GenericWebResponse<WSProviderInfrastructure>, Error> {
        var request = ws.get(Endpoint.providerNetwork(name, vpnProtocol))
        if let lastModified = lastModified {
            request.addValue(GenericWebParser.lastModifiedString(date: lastModified), forHTTPHeaderField: "If-Modified-Since")
        }
        return ws.parse(WSProviderInfrastructure.self, request: request)
    }
}

enum APIError: GenericWebServicesError, LocalizedError {
    case http(Int)

    case emptyResponse

    case unknown

    static func httpStatus(_ status: Int) -> APIError {
        .http(status)
    }

    var errorDescription: String? {
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

extension APIWebServices {
    public static func bundledServices(withVersion version: String) -> WebServices {
        guard let apiURL = Bundle.module.url(forResource: "API", withExtension: nil) else {
            fatalError("Could not find API in bundle")
        }
        return APIWebServices(version, apiURL, timeout: nil)
    }
}

private extension WSVPNProtocol {
    var filename: String {
        switch self {
        case .openVPN:
            return "ovpn"

        case .wireGuard:
            return "wg"
        }
    }
}
