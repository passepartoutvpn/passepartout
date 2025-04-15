//
//  OnboardingManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/24/25.
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

import CommonLibrary
import Foundation

@MainActor
public final class OnboardingManager: ObservableObject {
    private let defaults: UserDefaults?

    private let initialStep: OnboardingStep

    public private(set) var step: OnboardingStep {
        didSet {
            defaults?.set(step.rawValue, forKey: UIPreference.onboardingStep.key)
        }
    }

    public init(defaults: UserDefaults? = nil, initialStep: OnboardingStep? = nil) {
        self.defaults = defaults
        self.initialStep = initialStep ?? .doneV2
        step = self.initialStep
    }

    public convenience init(defaults: UserDefaults) {
        let initialStep: OnboardingStep?
        if let rawStep = defaults.string(forKey: UIPreference.onboardingStep.key) {
            initialStep = OnboardingStep(rawValue: rawStep)
        } else {
            initialStep = nil
        }
        self.init(defaults: defaults, initialStep: initialStep)
    }

    public func advance() {
        pp_log(.app, .info, "Current step: \(step)")
        step = step.nextStep
        pp_log(.app, .info, "Next step: \(step)")

        // skip step about 3.2.3 providers migration for new installs or 2.x.x
        if initialStep < .doneV3 && step == .migrateV3_2_3 {
            step = .doneV3_2_3
        }
    }
}

extension OnboardingStep {
    var nextStep: OnboardingStep {
        let all = OnboardingStep.allCases
        guard let index = all.firstIndex(of: self) else {
            fatalError("How can self not be part of allCases?")
        }
        guard index < all.count - 1 else {
            return self
        }
        return all[index + 1]
    }
}
