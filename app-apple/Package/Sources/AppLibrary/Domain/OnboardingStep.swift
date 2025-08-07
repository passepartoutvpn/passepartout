// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

// order matters
public enum OnboardingStep: String, RawRepresentable, CaseIterable {
    case doneV2

    case migrateV3

    case community

    case doneV3

    case migrateV3_2_3

    case doneV3_2_3
}

extension OnboardingStep {
    public static var last: Self {
        allCases.last!
    }
}

extension OnboardingStep: Comparable {
    var order: Int {
        OnboardingStep.allCases.firstIndex(of: self) ?? .max
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }
}
