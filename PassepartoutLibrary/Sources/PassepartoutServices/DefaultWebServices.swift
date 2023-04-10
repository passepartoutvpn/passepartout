//
//  DefaultWebServices.swift
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

public class DefaultWebServices: WebServices {
    private enum Group: String {
        case providers
    }

    private enum Endpoint: GenericWebEndpoint {
        case providersIndex

        case providerNetwork(WSProviderName, WSVPNProtocol)

        private var pathName: String {
            switch self {
            case .providersIndex:
                return "\(Group.providers.rawValue)/index"

            case .providerNetwork(let providerName, let vpnProtocol):
                return "\(Group.providers.rawValue)/\(providerName)/\(vpnProtocol.filename)"
            }
        }

        private var fileType: String {
            "json"
        }

        // MARK: GenericWebEndpoint

        var path: String {
            "\(pathName).\(fileType)"
        }
    }

    private let ws: GenericWebServices<WebError>

    public init(_ version: String, _ root: URL, timeout: TimeInterval?, queue: DispatchQueue = .main) {
        ws = GenericWebServices(version, root, timeout: timeout)
    }

    public func providersIndex() -> AnyPublisher<WSProvidersIndex, Error> {
        let request = ws.get(Endpoint.providersIndex)
        return ws.parse(WSProvidersIndex.self, request: request)
            .tryMap {
                guard let value = $0.value else {
                    throw WebError.emptyResponse
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

extension DefaultWebServices {
    public static func bundledServices(withVersion version: String) -> DefaultWebServices {
        guard let apiURL = Bundle.module.url(forResource: "API", withExtension: nil) else {
            fatalError("Could not find API in bundle")
        }
        return DefaultWebServices(version, apiURL, timeout: nil)
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
