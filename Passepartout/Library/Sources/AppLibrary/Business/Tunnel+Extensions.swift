//
//  Tunnel+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/11/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

protocol ProfileProcessor {
    func processedProfile(_ profile: Profile) throws -> Profile
}

extension Tunnel {
    func reinstate(_ profile: Profile, processor: ProfileProcessor) async throws {
        try await install(profile, processor: processor)
    }

    func connect(with profile: Profile, processor: ProfileProcessor) async throws {
        try await install(profile, processor: processor)
        guard !Task.isCancelled else {
            return
        }
        try await connect()
    }

    func reconnect(with profile: Profile, processor: ProfileProcessor) async throws {
        try await disconnect()
        guard !Task.isCancelled else {
            return
        }
        try await install(profile, processor: processor)
        guard !Task.isCancelled else {
            return
        }
        try await connect()
    }

    func currentLog(parameters: Constants.Log) async -> [String] {
        let output = try? await sendMessage(.localLog(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.maxLevel
        ))
        switch output {
        case .debugLog(let log):
            return log.lines.map(parameters.formatter.formattedLine)

        default:
            return []
        }
    }
}

private extension Tunnel {
    func install(_ profile: Profile, processor: ProfileProcessor) async throws {
        let newProfile = try processor.processedProfile(profile)
        try await install(profile: newProfile, title: \.name)
    }
}
