//
//  ProfileSplitView+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/19/24.
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

#if os(macOS)

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ProfileSplitView: View, Routable {
    let profileEditor: ProfileEditor

    let initialModuleId: UUID?

    let moduleViewFactory: any ModuleViewFactory

    @Binding
    var paywallReason: PaywallReason?

    var flow: ProfileCoordinator.Flow?

    @State
    private var detailPath = NavigationPath()

    @State
    private var selectedModuleId: UUID? = ModuleListView.generalModuleId

    @State
    private var errorModuleIds: Set<UUID> = []

    var body: some View {
        debugChanges()
        return NavigationSplitView {
            ModuleListView(
                profileEditor: profileEditor,
                selectedModuleId: $selectedModuleId,
                errorModuleIds: $errorModuleIds,
                paywallReason: $paywallReason,
                flow: flow
            )
            .navigationSplitViewColumnWidth(200)
        } detail: {
            Group {
                switch selectedModuleId {
                case ModuleListView.generalModuleId:
                    detailView(for: .general)

                default:
                    detailView(for: .module(id: selectedModuleId))
                }
            }
            .themeNavigationStack(path: $detailPath)
            .toolbar(content: toolbarContent)
            .environment(\.navigationPath, $detailPath)
        }
        .onLoad {
            if let initialModuleId {
                selectedModuleId = initialModuleId
            }
        }
    }
}

// MARK: -

extension ProfileSplitView {

    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(Strings.Global.Actions.cancel, role: .cancel) {
                flow?.onCancelEditing()
            }
            .uiAccessibility(.Profile.cancel)
        }
        ToolbarItem(placement: .confirmationAction) {
            ProfileSaveButton(
                title: Strings.Global.Actions.save,
                errorModuleIds: $errorModuleIds
            ) {
                try await flow?.onCommitEditing()
            }
        }
    }
}

// MARK: - Destinations

extension ProfileSplitView {
    enum Detail: Hashable {
        case general

        case module(id: UUID?)
    }
}

private extension ProfileSplitView {

    @ViewBuilder
    func detailView(for detail: Detail) -> some View {
        switch detail {
        case .general:
            ProfileGeneralView(
                profileEditor: profileEditor,
                paywallReason: $paywallReason
            )

        case .module(let id):
            ModuleDetailView(
                profileEditor: profileEditor,
                moduleId: id,
                moduleViewFactory: moduleViewFactory
            )
        }
    }
}

#Preview {
    ProfileSplitView(
        profileEditor: ProfileEditor(profile: .newMockProfile()),
        initialModuleId: nil,
        moduleViewFactory: DefaultModuleViewFactory(registry: Registry()),
        paywallReason: .constant(nil)
    )
    .withMockEnvironment()
}

#endif
