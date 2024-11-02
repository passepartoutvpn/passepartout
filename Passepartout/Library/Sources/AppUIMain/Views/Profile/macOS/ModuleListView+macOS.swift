//
//  ModuleListView+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/24.
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
import CommonUtils

struct ModuleListView: View, Routable {
    static let generalModuleId = UUID()

    @ObservedObject
    var profileEditor: ProfileEditor

    @Binding
    var selectedModuleId: UUID?

    @Binding
    var malformedModuleIds: [UUID]

    var flow: ProfileCoordinator.Flow?

    var body: some View {
        List(selection: $selectedModuleId) {
            Section {
                NavigationLink(Strings.Global.general, value: ProfileSplitView.Detail.general)
                    .tag(Self.generalModuleId)
            }
            Section {
                ForEach(profileEditor.modules, id: \.id) { module in
                    NavigationLink(value: ProfileSplitView.Detail.module(id: module.id)) {
                        moduleRow(for: module)
                    }
                }
                .onMove(perform: moveModules)
            } header: {
                if !profileEditor.modules.isEmpty {
                    Text(Strings.Global.modules)
                }
            }
        }
        .onDeleteCommand(perform: removeSelectedModule)
        .toolbar(content: toolbarContent)
        .navigationTitle(profileEditor.profile.name)
    }
}

private extension ModuleListView {
    func moduleRow(for module: any ModuleBuilder) -> some View {
        HStack {
            Text(module.description(inEditor: profileEditor))
                .themeError(malformedModuleIds.contains(module.id))
            Spacer()
            EditorModuleToggle(profileEditor: profileEditor, module: module) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    func toolbarContent() -> some View {
        addModuleMenu
        Button(action: removeSelectedModule) {
            ThemeImage(.remove)
        }
        .disabled(!canRemoveSelectedModule)
        EmptyView()
            .themeTip(Strings.Views.Profile.ModuleList.Section.footer, edge: .bottom)
    }

    var addModuleMenu: some View {
        let moduleTypes = profileEditor.availableModuleTypes
        return Menu {
            ForEach(moduleTypes, id: \.self) { moduleType in
                Button(moduleType.localizedDescription) {
                    flow?.onNewModule(moduleType)
                }
            }
        } label: {
            ThemeImage(.add)
        }
        .disabled(moduleTypes.isEmpty)
    }
}

private extension ModuleListView {
    func moveModules(from offsets: IndexSet, to newOffset: Int) {
        profileEditor.moveModules(from: offsets, to: newOffset)
        // XXX: selection is lost after move, reset as a workaround
        selectedModuleId = nil
    }

    func removeModules(at offsets: IndexSet) {
        profileEditor.removeModules(at: offsets)
    }

    var effectiveSelectedModuleId: UUID? {
        guard selectedModuleId != Self.generalModuleId else {
            return nil
        }
        return selectedModuleId
    }

    var canRemoveSelectedModule: Bool {
        effectiveSelectedModuleId != nil
    }

    func removeSelectedModule() {
        guard let effectiveSelectedModuleId else {
            return
        }
        self.selectedModuleId = nil
        profileEditor.removeModule(withId: effectiveSelectedModuleId)
    }
}

#Preview {
    ModuleListView(
        profileEditor: ProfileEditor(profile: .mock),
        selectedModuleId: .constant(nil),
        malformedModuleIds: .constant([])
    )
    .withMockEnvironment()
}

#endif
