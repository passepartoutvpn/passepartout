//
//  OnboardingStepTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
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
import UILibrary
import XCTest

final class OnboardingStepTests: XCTestCase {
    func test_givenNil_whenAdvance_thenAdvancesToFirst() {
        let sut: OnboardingStep? = nil
        XCTAssertEqual(sut.nextStep, .migrateV3)
    }

    func test_givenMid_whenAdvance_thenAdvancesToNext() {
        let sut: OnboardingStep? = .migrateV3
        XCTAssertEqual(sut.nextStep, .community)
    }

    func test_givenLast_whenAdvance_thenDoesNotAdvance() {
        let sut: OnboardingStep? = .doneV3
        XCTAssertEqual(sut.nextStep, .doneV3)
    }
}
