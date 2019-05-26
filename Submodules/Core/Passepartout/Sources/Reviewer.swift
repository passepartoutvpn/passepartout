//
//  Reviewer.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/10/18.
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

import StoreKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class Reviewer {
    private struct Keys {
        static let eventCount = "ReviewerEventCount"
    
        static let lastVersion = "ReviewerLastVersion"
    }
    
    public static let shared = Reviewer()
    
    private let defaults: UserDefaults
    
    public var eventCountBeforeRating = 3
    
    private init() {
        defaults = .standard
    }
    
    public func reportEvent() {
        let currentVersion = GroupConstants.App.buildNumber
        let lastVersion = defaults.integer(forKey: Keys.lastVersion)
        if lastVersion > 0 {
            log.debug("App last reviewed for version \(lastVersion)")
        } else {
            log.debug("App was never reviewed")
        }
        guard currentVersion != lastVersion else {
            log.debug("App already reviewed for version \(currentVersion)")
            return
        }

        var count = defaults.integer(forKey: Keys.eventCount)
        count += 1
        defaults.set(count, forKey: Keys.eventCount)
        log.debug("Event reported for version \(currentVersion) (count: \(count), prompt: \(eventCountBeforeRating))")
        
        guard count >= eventCountBeforeRating else {
            return
        }
        log.debug("Prompting for review...")

        SKStoreReviewController.requestReview()
        defaults.removeObject(forKey: Keys.eventCount)
        defaults.set(currentVersion, forKey: Keys.lastVersion)
    }
}
