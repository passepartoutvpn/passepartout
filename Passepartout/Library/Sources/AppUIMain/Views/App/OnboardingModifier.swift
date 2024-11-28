//
//  OnboardingModifier.swift
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

struct OnboardingModifier: ViewModifier {

    @Environment(\.isUITesting)
    private var isUITesting

    @AppStorage(UIPreference.onboardingStep.key)
    private var step: OnboardingStep?

    @Binding
    var modalRoute: AppCoordinator.ModalRoute?

    @State
    private var isPresentingCommunity = false

    func body(content: Content) -> some View {
        content
            .alert(
                Strings.Unlocalized.reddit,
                isPresented: $isPresentingCommunity,
                actions: {
                    Link(Strings.Alerts.Community.subscribe, destination: Constants.shared.websites.subreddit)
                        .environment(\.openURL, OpenURLAction { _ in
                            advance()
                            return .systemAction
                        })

                    Button(Strings.Alerts.Community.dismiss, role: .cancel, action: advance)
                },
                message: {
                    Text(Strings.Alerts.Community.message)
                }
            )
            .onLoad(perform: advance)
            .onChange(of: modalRoute) {
                if $0 == nil {
                    advance()
                }
            }
    }
}

private extension OnboardingModifier {
    func advance() {
        guard !isUITesting else {
            pp_log(.app, .info, "UI tests: skip onboarding")
            return
        }
        Task {
            try await Task.sleep(for: .milliseconds(300))
            doAdvance()
        }
    }

    func doAdvance() {
        pp_log(.app, .info, "Current step: \(step.debugDescription)")
        step = step.nextStep
        pp_log(.app, .info, "Next step: \(step.debugDescription)")

        switch step {
        case .migrateV3:
            modalRoute = .migrateProfiles
        case .community:
            isPresentingCommunity = true
        default:
            break
        }
    }
}
