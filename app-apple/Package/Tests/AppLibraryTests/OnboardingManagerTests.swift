// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

@testable import AppLibrary
import Foundation
import XCTest

@MainActor
final class OnboardingManagerTests: XCTestCase {
    func test_givenStep_whenOrder_thenIsExpected() {
        XCTAssertEqual(OnboardingStep.doneV2.order, 0)
        XCTAssertEqual(OnboardingStep.migrateV3.order, 1)
        XCTAssertEqual(OnboardingStep.community.order, 2)
        XCTAssertEqual(OnboardingStep.doneV3.order, 3)
        XCTAssertEqual(OnboardingStep.migrateV3_2_3.order, 4)
        XCTAssertEqual(OnboardingStep.doneV3_2_3.order, 5)
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
        sut.advance() // .migrateV3_2_3 (skipped)
        XCTAssertEqual(sut.step, .doneV3_2_3)
    }

    func test_givenMid_whenAdvanceFromV3_thenAdvancesToV322Migration() {
        let sut = OnboardingManager(initialStep: .doneV3)
        sut.advance()
        XCTAssertEqual(sut.step, .migrateV3_2_3)
        sut.advance()
        XCTAssertEqual(sut.step, .doneV3_2_3)
    }

    func test_givenLast_whenAdvance_thenDoesNotAdvance() {
        let sut = OnboardingManager(initialStep: .doneV3_2_3)
        XCTAssertEqual(sut.step, OnboardingStep.allCases.last)
        sut.advance()
        XCTAssertEqual(sut.step, .doneV3_2_3)
    }
}
