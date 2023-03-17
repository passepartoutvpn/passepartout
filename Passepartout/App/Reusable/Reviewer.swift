//
//  Reviewer.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/9/19.
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

import UIKit
import StoreKit

public class Reviewer: ObservableObject {
    private struct Keys {
        static let eventCount = "Reviewer.EventCount"

        static let lastVersion = "Reviewer.LastVersion"
    }

    private let defaults: UserDefaults

    public var eventCountBeforeRating: Int = .max

    public init() {
        defaults = .standard
    }

    @discardableResult
    public func reportEvent() -> Bool {
        reportEvents(1)
    }

    @discardableResult
    public func reportEvents(_ eventCount: Int, appStoreId: String? = nil) -> Bool {
        guard let currentVersionString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let currentVersion = Int(currentVersionString) else {
            return false
        }
        let lastVersion = defaults.integer(forKey: Keys.lastVersion)
        if lastVersion > 0 {
            print("Reviewer: App last reviewed for version \(lastVersion)")
        } else {
            print("Reviewer: App was never reviewed")
        }
        guard currentVersion != lastVersion else {
            print("Reviewer: App already reviewed for version \(currentVersion)")
            return false
        }

        var count = defaults.integer(forKey: Keys.eventCount)
        count += eventCount
        defaults.set(count, forKey: Keys.eventCount)
        print("Reviewer: Event reported for version \(currentVersion) (count: \(count), prompt: \(eventCountBeforeRating))")

        guard count >= eventCountBeforeRating else {
            return false
        }
        print("Reviewer: Prompting for review...")

        defaults.removeObject(forKey: Keys.eventCount)
        defaults.set(currentVersion, forKey: Keys.lastVersion)

        requestReview()
        return true
    }

    // may or may not appear
    private func requestReview() {
        guard let scene = UIApplication.shared.windows.first(where: { $0.windowScene != nil })?.windowScene else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }

    public static func urlForReview(withAppId appId: String) -> URL {
        URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review")!
    }
}
