// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

@MainActor
public final class OnboardingManager: ObservableObject {
    private let kvManager: KeyValueManager?

    private let initialStep: OnboardingStep

    public private(set) var step: OnboardingStep {
        didSet {
            kvManager?.set(step.rawValue, forUIPreference: .onboardingStep)
        }
    }

    public init(kvManager: KeyValueManager? = nil, initialStep: OnboardingStep? = nil) {
        self.kvManager = kvManager
        self.initialStep = initialStep ?? .doneV2
        step = self.initialStep
    }

    public convenience init(kvManager: KeyValueManager) {
        let initialStep: OnboardingStep?
        if let rawStep = kvManager.string(forUIPreference: .onboardingStep) {
            initialStep = OnboardingStep(rawValue: rawStep)
        } else {
            initialStep = nil
        }
        self.init(kvManager: kvManager, initialStep: initialStep)
    }

    public func advance() {
        pp_log_g(.app, .info, "Current step: \(step)")
        step = step.nextStep
        pp_log_g(.app, .info, "Next step: \(step)")

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
