//
//  OnboardingModifier.swift
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

struct OnboardingModifier: ViewModifier {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var migrationManager: MigrationManager

    @EnvironmentObject
    private var onboardingManager: OnboardingManager

    @Environment(\.isUITesting)
    private var isUITesting

    @Binding
    var modalRoute: AppCoordinator.ModalRoute?

    @State
    private var isAlertPresented = false

    func body(content: Content) -> some View {
        content
            .alert(
                alertTitle(for: onboardingManager.step),
                isPresented: $isAlertPresented,
                presenting: onboardingManager.step,
                actions: alertActions,
                message: alertMessage
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
    func alertTitle(for item: OnboardingStep?) -> String {
        switch item {
        case .community:
            return Strings.Unlocalized.reddit
        default:
            return ""
        }
    }

    @ViewBuilder
    func alertActions(for item: OnboardingStep) -> some View {
        switch item {
        case .community:
            Link(Strings.Onboarding.Community.subscribe, destination: Constants.shared.websites.subreddit)
                .environment(\.openURL, OpenURLAction { _ in
                    advance()
                    return .systemAction
                })

            Button(Strings.Onboarding.Community.dismiss, role: .cancel, action: advance)

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func alertMessage(for item: OnboardingStep) -> some View {
        switch item {
        case .community:
            Text(Strings.Onboarding.Community.message(Strings.Unlocalized.appName))
        default:
            EmptyView()
        }
    }
}

private extension OnboardingModifier {
    func advance() {
        if isUITesting {
            pp_log(.app, .info, "UI tests: skip onboarding")
            return
        }
        Task {
            try await Task.sleep(for: .milliseconds(300))
            doAdvance()
        }
    }

    func doAdvance() {
        onboardingManager.advance()

        switch onboardingManager.step {
        case .migrateV3:
            guard migrationManager.hasMigratableProfiles else {
                advance()
                return
            }
            modalRoute = .migrateProfiles
        case .community:
            isAlertPresented = true
        case .migrateV3_2_2:
            isAlertPresented = true
            Task {
                await apiManager.resetLastUpdateForAllProviders()
            }
        default:
            if onboardingManager.step != OnboardingStep.allCases.last {
                advance()
            }
        }
    }
}
