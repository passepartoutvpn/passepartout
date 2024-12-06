//
//  ModuleDetailView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/15/24.
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

struct ModuleDetailView: View {

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    let profileEditor: ProfileEditor

    let moduleId: UUID?

    let moduleViewFactory: any ModuleViewFactory

    @StateObject
    private var modulePreferences = ModulePreferences(proxy: nil)

    var body: some View {
        debugChanges()
        return Group {
            if let moduleId {
                editorView(forModuleWithId: moduleId)
            } else {
                emptyView
            }
        }
        .onLoad {
            guard let moduleId else {
                return
            }
            do {
                modulePreferences.proxy = try preferencesManager.modulePreferencesProxy(in: moduleId)
            } catch {
                pp_log(.app, .error, "Unable to load module preferences: \(error)")
            }
        }
    }
}

private extension ModuleDetailView {

    @MainActor
    func editorView(forModuleWithId moduleId: UUID) -> some View {
        AnyView(moduleViewFactory.view(
            with: profileEditor,
            preferences: modulePreferences,
            moduleId: moduleId
        ))
    }

    var emptyView: some View {
        Text(Strings.Global.Nouns.noSelection)
            .themeEmptyMessage()
    }
}

#Preview {
    ModuleDetailView(
        profileEditor: ProfileEditor(profile: .forPreviews),
        moduleId: Profile.forPreviews.modules.first?.id,
        moduleViewFactory: DefaultModuleViewFactory(registry: Registry())
    )
    .withMockEnvironment()
}
