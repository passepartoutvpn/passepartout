// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

@testable import AppLibrary
import Foundation
import Testing

@MainActor
struct OnboardingManagerTests {
    @Test
    func test_givenStep_whenOrder_thenIsExpected() {
        #expect(OnboardingStep.migrateV3.order == 0)
        #expect(OnboardingStep.community.order == 1)
        #expect(OnboardingStep.doneV3.order == 2)
        #expect(OnboardingStep.migrateV3_2_3.order == 3)
        #expect(OnboardingStep.doneV3_2_3.order == 4)
    }

    @Test
    func givenNil_whenAdvance_thenAdvancesToNext() {
        let sut = OnboardingManager() // .migrateV3
        sut.advance()
        #expect(sut.step == .community)
    }

    @Test
    func givenMid_whenAdvance_thenAdvancesToNext() {
        let sut = OnboardingManager(initialStep: .migrateV3)
        sut.advance()
        #expect(sut.step == .community)
    }

    @Test
    func givenMid_whenAdvanceFromV2_thenSkipsV322Migration() {
        let sut = OnboardingManager(initialStep: .first) // .migrateV3
        #expect(sut.step == .migrateV3)
        sut.advance() // .community
        sut.advance() // .doneV3
        sut.advance() // .migrateV3_2_3 (skipped to .doneV3_2_3)
        #expect(sut.step == .doneV3_2_3)
    }

    @Test
    func givenMid_whenAdvanceFromV3_thenAdvancesToV322Migration() {
        let sut = OnboardingManager(initialStep: .doneV3)
        sut.advance()
        #expect(sut.step == .migrateV3_2_3)
        sut.advance()
        #expect(sut.step == .doneV3_2_3)
    }

    @Test
    func givenLast_whenAdvance_thenDoesNotAdvance() {
        let sut = OnboardingManager(initialStep: .doneV3_2_3)
        #expect(sut.step == .last)
        sut.advance()
        #expect(sut.step == .doneV3_2_3)
    }
}
