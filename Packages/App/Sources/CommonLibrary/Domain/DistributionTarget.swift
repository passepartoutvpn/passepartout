//
//  DistributionTarget.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/21/25.
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

public enum DistributionTarget: String, Sendable {
    case appStore

    case developerID

    // TODO: ###, behave like .complete when this is implemented
    case enterprise
}

extension DistributionTarget {
    public var canAlwaysReportIssue: Bool {
        self != .appStore
    }

    public var supportsAppGroups: Bool {
        self != .developerID
    }

    public var supportsCloudKit: Bool {
        self != .developerID
    }

    public var supportsIAP: Bool {
        self == .appStore
    }

    // differs from !supportsIAP because:
    //
    // - .appStore supports paid features and IAP
    // - .enterprise supports paid features but not IAP
    // - .developerID supports neither
    public var supportsPaidFeatures: Bool {
        self != .developerID
    }

    public var supportsV2Migration: Bool {
        self == .appStore
    }

    public var usesExperimentalPOSIXResolver: Bool {
        self == .developerID
    }
}
