//
//  Constants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/26/24.
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
import PassepartoutKit

public struct Constants: Decodable, Sendable {
    public struct Containers: Decodable, Sendable {
        public let local: String

        public let remote: String

        public let backup: String

        public let legacyV2: String

        public let legacyV2TV: String
    }

    public struct Websites: Decodable, Sendable {
        public let home: URL

        public var api: URL {
            home.appendingPathComponent("api/")
        }

        public var faq: URL {
            home.appendingPathComponent("faq/")
        }

        public var disclaimer: URL {
            home.appendingPathComponent("disclaimer/")
        }

        public var privacyPolicy: URL {
            home.appendingPathComponent("privacy/")
        }

        public var donate: URL {
            home.appendingPathComponent("donate/")
        }

        public let subreddit: URL

        public let githubSponsors: URL
    }

    public struct Emails: Decodable, Sendable {
        private struct Recipients: Decodable, Sendable {
            let issues: String

            let beta: String
        }

        public let domain: String

        private let recipients: Recipients

        public var issues: String {
            email(to: recipients.issues)
        }

        public var beta: String {
            email(to: recipients.beta)
        }

        private func email(to: String) -> String {
            [to, domain].joined(separator: "@")
        }
    }

    public struct Formats: Decodable, Sendable {
        public let timestamp: String
    }

    public struct Tunnel: Decodable, Sendable {
        public let profileTitleFormat: String

        public let refreshInterval: TimeInterval

        public let betaReceiptPath: String

        public let eligibilityCheckInterval: TimeInterval
    }

    public struct API: Decodable, Sendable {
        public let timeoutInterval: TimeInterval
    }

    public struct Log: Decodable, Sendable {
        public struct Formatter: Decodable, Sendable {
            enum CodingKeys: CodingKey {
                case timestamp

                case message
            }

            private let timestampFormatter: DateFormatter

            private let message: String

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let timestampFormat = try container.decode(String.self, forKey: .timestamp)
                timestampFormatter = DateFormatter()
                timestampFormatter.dateFormat = timestampFormat
                message = try container.decode(String.self, forKey: .message)
            }

            public func formattedLine(_ line: DebugLog.Line) -> String {
                let formattedTimestamp = timestampFormatter.string(from: line.timestamp)
                return String(format: message, formattedTimestamp, line.message)
            }
        }

        public let formatter: Formatter

        public let appPath: String

        public let tunnelPath: String

        public let sinceLast: TimeInterval

        public let maxLevel: DebugLog.Level

        public let maxNumberOfLines: Int

        public let maxAge: TimeInterval?
    }

    public let bundleKey: String

    public let containers: Containers

    public let websites: Websites

    public let emails: Emails

    public let formats: Formats

    public let tunnel: Tunnel

    public let api: API

    public let log: Log
}
