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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct ProfileSplitView: View, Routable {
    let profileEditor: ProfileEditor

    let moduleViewFactory: any ModuleViewFactory

    var flow: ProfileCoordinator.Flow?

    @State
    private var detailPath = NavigationPath()

    @State
    private var selectedModuleId: UUID? = ModuleListView.generalModuleId

    @State
    private var malformedModuleIds: [UUID] = []

    var body: some View {
        debugChanges()
        return NavigationSplitView {
            ModuleListView(
                profileEditor: profileEditor,
                selectedModuleId: $selectedModuleId,
                malformedModuleIds: $malformedModuleIds,
                flow: flow
            )
        } detail: {
            NavigationStack(path: $detailPath) {
                switch selectedModuleId {
                case ModuleListView.generalModuleId:
                    detailView(for: .general)

                default:
                    detailView(for: .module(id: selectedModuleId))
                }
            }
            .toolbar(content: toolbarContent)
            .environment(\.navigationPath, $detailPath)
        }
    }
}

// MARK: -

extension ProfileSplitView {

    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(Strings.Global.cancel, role: .cancel) {
                flow?.onCancelEditing()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            ProfileSaveButton(
                title: Strings.Global.save,
                errorModuleIds: $malformedModuleIds
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
            ProfileGeneralView(profileEditor: profileEditor)

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
        moduleViewFactory: DefaultModuleViewFactory()
    )
    .withMockEnvironment()
}

#endif
