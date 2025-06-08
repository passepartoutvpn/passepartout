//
//  MultipartForm.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/6/25.
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

import Foundation

extension MultipartForm {
    public struct Builder {
        public var fields: [String: Field]

        public init() {
            fields = [:]
        }

        public func build() -> MultipartForm {
            MultipartForm(fields: fields)
        }
    }
}

public struct MultipartForm: Sendable {
    public struct Field: Sendable {
        public let value: String

        public let filename: String?

        public init(_ value: String, filename: String? = nil) {
            self.value = value
            self.filename = filename
        }
    }

    public let fields: [String: Field]
}

// MARK: - Web

extension MultipartForm {
    public init?(body: String) {
        guard let boundaryLine = body.components(separatedBy: "\r\n").first,
              boundaryLine.starts(with: "--") else {
            return nil
        }

        let boundary = boundaryLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = body.components(separatedBy: boundary)
            .dropFirst()
            .dropLast()

        var fields: [String: Field] = [:]
        for part in parts {
            let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let headerRange = trimmedPart.range(of: "\r\n\r\n") else {
                continue
            }
            let headerText = trimmedPart[..<headerRange.lowerBound]
            let bodyText = trimmedPart[headerRange.upperBound...]

            let headers = headerText.components(separatedBy: "\r\n")
            var name: String?
            var filename: String?

            for header in headers where header.lowercased().starts(with: "content-disposition:") {
                let components = header.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                for comp in components {
                    if comp.starts(with: "name=") {
                        name = comp.replacingOccurrences(of: "name=", with: "")
                            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    } else if comp.starts(with: "filename=") {
                        filename = comp.replacingOccurrences(of: "filename=", with: "")
                            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    }
                }
            }
            guard let name else {
                continue
            }
            guard let value = String(bodyText.utf8) else {
                continue
            }
            fields[name] = Field(value, filename: filename)
        }
        self.fields = fields
    }

    public func toURLRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let webData = toWebData()
        request.httpBody = webData.body
        return request
    }

    public func toWebData() -> (boundary: String, body: Data) {
        let boundary = UUID().uuidString
        var body = Data()
        fields.forEach {
            let filenameDisposition = $0.value.filename.map {
                "; filename=\"\($0)\""
            }
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\($0.key)\"\(filenameDisposition ?? "")\r\n")
            if filenameDisposition != nil {
                body.append("Content-Type: application/octet-stream\r\n")
            }
            body.append("\r\n")
            body.append("\($0.value.value)\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return (boundary, body)
    }
}

private extension Data {
    mutating func append(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        append(data)
    }
}
