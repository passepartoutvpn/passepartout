//
//  GenericWebServices.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/19.
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

public protocol GenericWebServicesError: Error {
    static func httpStatus(_ status: Int) -> Self

    static var unknown: Self { get }
}

public class GenericWebServices<ErrorType: GenericWebServicesError> {
    private let version: String?

    private let root: URL

    private let timeout: TimeInterval?

    public init(_ version: String?, _ root: URL, timeout: TimeInterval?) {
        self.version = version
        self.root = root
        self.timeout = timeout
    }

    public func get(_ endpoint: GenericWebEndpoint) -> URLRequest {
        var request = URLRequest(url: url(forEndpoint: endpoint), cachePolicy: .reloadIgnoringCacheData)
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        return request
    }

    public func parse<T: Decodable>(_ type: T.Type, request: URLRequest) -> AnyPublisher<GenericWebResponse<T>, Error> {
        pp_log.debug("GET \(request.url!)")
        pp_log.debug("Request headers: \(request.allHTTPHeaderFields?.description ?? "none")")

        let session = URLSession(configuration: .ephemeral)
        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    pp_log.error("Error (response): \(error.localizedDescription)")

                default:
                    break
                }
            }).tryMap { (output: (Data, URLResponse)) in
                let data = output.0
                let response = output.1

                let value: T
                var lastModifiedString: String?

                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    pp_log.debug("Response status: \(statusCode)")
                    if let responseHeaders = httpResponse.allHeaderFields as? [String: String] {
                        pp_log.debug("Response headers: \(responseHeaders)")
                    }

                    // 304: cache hit
                    if statusCode == 304 {
                        pp_log.debug("Response is cached")
                        return GenericWebResponse(value: nil, lastModifiedString: nil, isCached: true)
                    }

                    // 200: cache miss
                    guard statusCode == 200 else {
                        pp_log.error("Error (HTTP): \(statusCode)")
                        throw ErrorType.httpStatus(statusCode)
                    }

                    lastModifiedString = httpResponse.allHeaderFields["Last-Modified"] as? String
                } else {
                    lastModifiedString = GenericWebParser.lastModifiedString(ofFileURL: request.url!)
                }

                if let lastModifiedString = lastModifiedString {
                    pp_log.debug("Last modified: \(lastModifiedString)")
                }

                do {
                    value = try JSONDecoder().decode(type, from: data)
                } catch {
                    pp_log.error("Error (parsing): \(error)")
                    throw error
                }

                return GenericWebResponse(value: value, lastModifiedString: lastModifiedString, isCached: false)
            }.eraseToAnyPublisher()
    }

    private func url(forEndpoint endpoint: GenericWebEndpoint) -> URL {
        guard let version = version else {
            return root.appendingPathComponent(endpoint.path)
        }
        return root.appendingPathComponent("\(version)/\(endpoint.path)")
    }
}
