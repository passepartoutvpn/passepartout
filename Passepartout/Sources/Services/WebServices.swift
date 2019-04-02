//
//  WebServices.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/14/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class WebServices {
    public enum Group: String {
        case network = "net"
    }
    
    public enum Endpoint {
        case network(Infrastructure.Name)
        
        var path: String {
            switch self {
            case .network(let name):
                return "\(Group.network.rawValue)/\(name.webName)"
            }
        }
    }
    
    public struct Response<T> {
        public let value: T?
        
        public let lastModifiedString: String?
        
        public var lastModified: Date? {
            guard let string = lastModifiedString else {
                return nil
            }
            return lmFormatter.date(from: string)
        }
        
        public let isCached: Bool
    }
    
    public static let shared = WebServices()
    
    private static let lmFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(abbreviation: "GMT")
        fmt.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
        return fmt
    }()
    
    public func network(with name: Infrastructure.Name, ifModifiedSince lastModified: Date?, completionHandler: @escaping (Response<Infrastructure>?, Error?) -> Void) {
        var request = get(.network(name))
        if let lastModified = lastModified {
            request.addValue(WebServices.lmFormatter.string(from: lastModified), forHTTPHeaderField: "If-Modified-Since")
        }
        parse(Infrastructure.self, request: request, completionHandler: completionHandler)
    }

    private func get(_ endpoint: Endpoint) -> URLRequest {
        let url = AppConstants.Web.url(path: "\(endpoint.path).json")
        return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: AppConstants.Web.timeout)
    }
    
    private func parse<T: Decodable>(_ type: T.Type, request: URLRequest, completionHandler: @escaping (Response<T>?, Error?) -> Void) {
        log.debug("GET \(request.url!)")
        log.debug("Request headers: \(request.allHTTPHeaderFields?.description ?? "")")

        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                log.error("Error (response): \(error?.localizedDescription ?? "nil")")
                completionHandler(nil, error)
                return
            }

            let statusCode = httpResponse.statusCode
            log.debug("Response status: \(statusCode)")
            if let responseHeaders = httpResponse.allHeaderFields as? [String: String] {
                log.debug("Response headers: \(responseHeaders)")
            }

            // 304: cache hit
            if statusCode == 304 {
                log.debug("Response is cached")
                completionHandler(Response(value: nil, lastModifiedString: nil, isCached: true), nil)
                return
            }

            // 200: cache miss
            let value: T
            let lastModifiedString: String?
            guard statusCode == 200, let data = data else {
                log.error("Error (network): \(error?.localizedDescription ?? "nil")")
                completionHandler(nil, error)
                return
            }
            do {
                value = try JSONDecoder().decode(type, from: data)
            } catch let e {
                log.error("Error (parsing): \(e)")
                completionHandler(nil, error)
                return
            }
            lastModifiedString = httpResponse.allHeaderFields["Last-Modified"] as? String

            let response = Response(value: value, lastModifiedString: lastModifiedString, isCached: false)
            completionHandler(response, nil)
        }.resume()
    }
}
