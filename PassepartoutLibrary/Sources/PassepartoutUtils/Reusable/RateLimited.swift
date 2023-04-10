//
//  RateLimited.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/22.
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

public protocol RateLimited: AnyObject {
    associatedtype ActionID: Hashable

    var lastActionDate: [ActionID: Date] { get set }

    var rateLimitMilliseconds: Int? { get }
}

extension RateLimited {
    public func saveLastAction(_ id: ActionID) {
        lastActionDate[id] = Date()
    }

    public func isRateLimited(_ id: ActionID) -> Bool {
        guard let lastActionDate = lastActionDate[id] else {
            return false
        }
        pp_log.debug("Last action date: \(lastActionDate)")
        if let rateLimitMilliseconds = rateLimitMilliseconds {
            let elapsedNanoseconds = UInt64(-lastActionDate.timeIntervalSinceNow) * NSEC_PER_SEC
            let rateLimitNanoseconds = UInt64(rateLimitMilliseconds) * NSEC_PER_MSEC
            guard elapsedNanoseconds >= rateLimitNanoseconds else {
                pp_log.warning("Rate limited, only \(elapsedNanoseconds) nsec elapsed (< \(rateLimitNanoseconds))")
                return true
            }
        }
        return false
    }
}
