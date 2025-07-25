//
//  View+Environment.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/2/24.
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

import SwiftUI

@MainActor
extension View {
    public func withEnvironment(from context: AppContext, theme: Theme) -> some View {
        environmentObject(theme)
            .environmentObject(context.apiManager)
            .environmentObject(context.appearanceManager)
            .environmentObject(context.configManager)
            .environment(\.distributionTarget, context.distributionTarget)
            .environmentObject(context.iapManager)
            .environmentObject(context.kvManager)
            .environmentObject(context.migrationManager)
            .environmentObject(context.onboardingManager)
            .environmentObject(context.preferencesManager)
            .environmentObject(context.registryCoder)
            .environmentObject(context.versionChecker)
    }

    public func withMockEnvironment() -> some View {
        task {
            try? await AppContext.forPreviews.profileManager.observeLocal()
        }
        .withEnvironment(from: .forPreviews, theme: Theme())
    }
}
