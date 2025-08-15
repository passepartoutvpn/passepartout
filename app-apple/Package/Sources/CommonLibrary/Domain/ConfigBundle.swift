// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

public struct ConfigBundle: Decodable {
    public struct Config: Codable {
        public let rate: Int

        public let minBuild: Int?

        public let data: JSON?
    }

    // flag -> deployment (0-100)
    public let map: [ConfigFlag: Config]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        map = try container
            .decode([String: Config].self)
            .reduce(into: [:]) {
                guard let flag = ConfigFlag(rawValue: $1.key) else {
                    return
                }
                $0[flag] = $1.value
            }
    }

    public var activeFlags: Set<ConfigFlag> {
        Set(map.filter { $0.value.rate == 100 }.keys)
    }
}
