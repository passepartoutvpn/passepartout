//
//  OnboardingManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
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
@testable import UILibrary
import XCTest

@MainActor
final class OnboardingManagerTests: XCTestCase {
    func test_givenStep_whenOrder_thenIsExpected() {
        XCTAssertEqual(OnboardingStep.doneV2.order, 0)
        XCTAssertEqual(OnboardingStep.migrateV3.order, 1)
        XCTAssertEqual(OnboardingStep.community.order, 2)
        XCTAssertEqual(OnboardingStep.doneV3.order, 3)
        XCTAssertEqual(OnboardingStep.migrateV3_2_2.order, 4)
        XCTAssertEqual(OnboardingStep.doneV3_2_2.order, 5)
    }

    func test_givenNil_whenAdvance_thenAdvancesToFirst() {
        let sut = OnboardingManager()
        sut.advance()
        XCTAssertEqual(sut.step, .migrateV3)
    }

    func test_givenMid_whenAdvance_thenAdvancesToNext() {
        let sut = OnboardingManager(initialStep: .migrateV3)
        sut.advance()
        XCTAssertEqual(sut.step, .community)
    }

    func test_givenMid_whenAdvanceFromV2_thenSkipsV322Migration() {
        let sut = OnboardingManager(initialStep: .doneV2)
        sut.advance() // .migrateV3
        sut.advance() // .community
        sut.advance() // .doneV3
        sut.advance() // .migrateV3_2_2 (skipped)
        XCTAssertEqual(sut.step, .doneV3_2_2)
    }

    func test_givenMid_whenAdvanceFromV3_thenAdvancesToV322Migration() {
        let sut = OnboardingManager(initialStep: .doneV3)
        sut.advance()
        XCTAssertEqual(sut.step, .migrateV3_2_2)
        sut.advance()
        XCTAssertEqual(sut.step, .doneV3_2_2)
    }

    func test_givenLast_whenAdvance_thenDoesNotAdvance() {
        let sut = OnboardingManager(initialStep: .doneV3_2_2)
        XCTAssertEqual(sut.step, OnboardingStep.allCases.last)
        sut.advance()
        XCTAssertEqual(sut.step, .doneV3_2_2)
    }
}
