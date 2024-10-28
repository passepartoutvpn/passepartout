//
//  ProfileCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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

import AppLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct ProfileCoordinator: View {
    struct Flow {
        let onNewModule: (ModuleType) -> Void

        let onCommitEditing: () async throws -> Void

        let onCancelEditing: () -> Void
    }

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    let moduleViewFactory: any ModuleViewFactory

    let modally: Bool

    @Binding
    var path: NavigationPath

    let onDismiss: () -> Void

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Destinations

private extension ProfileCoordinator {
    var contentView: some View {
#if os(iOS)
        ProfileEditView(
            profileEditor: profileEditor,
            moduleViewFactory: moduleViewFactory,
            path: $path,
            flow: .init(
                onNewModule: onNewModule,
                onCommitEditing: onCommitEditing,
                onCancelEditing: onCancelEditing
            )
        )
        .themeNavigationDetail()
        .themeNavigationStack(if: modally, path: $path)
#elseif os(macOS)
        ProfileSplitView(
            profileEditor: profileEditor,
            moduleViewFactory: moduleViewFactory,
            flow: .init(
                onNewModule: onNewModule,
                onCommitEditing: onCommitEditing,
                onCancelEditing: onCancelEditing
            )
        )
#endif
    }
}

private extension ProfileCoordinator {
    func onNewModule(_ moduleType: ModuleType) {
        switch moduleType {
        case .dns:
            paywallReason = iapManager.paywallReason(forFeature: .dns)

        case .httpProxy:
            paywallReason = iapManager.paywallReason(forFeature: .httpProxy)

        case .ip:
            paywallReason = iapManager.paywallReason(forFeature: .routing)

        case .openVPN, .wireGuard:
            break

        case .onDemand:
            break
        }
        guard paywallReason == nil else {
            return
        }

        let module = moduleType.newModule()
        withAnimation(theme.animation(for: .modules)) {
            profileEditor.saveModule(module, activating: true)
        }
    }

    func onCommitEditing() async throws {
        do {
            try await profileEditor.save(to: profileManager)
            onDismiss()
        } catch {
            errorHandler.handle(error, title: Strings.Global.save)
            throw error
        }
    }

    func onCancelEditing() {
        onDismiss()
    }
}

// MARK: - Previews

#Preview {
    ProfileCoordinator(
        profileManager: .mock,
        profileEditor: ProfileEditor(profile: .newProfile()),
        moduleViewFactory: DefaultModuleViewFactory(),
        modally: false,
        path: .constant(NavigationPath()),
        onDismiss: {}
    )
    .withMockEnvironment()
}
