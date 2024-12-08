//
//  ProfileContainerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/16/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ProfileContainerView: View, Routable {
    let layout: ProfilesLayout

    let profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    let registry: Registry

    @Binding
    var isImporting: Bool

    @ObservedObject
    var errorHandler: ErrorHandler

    var flow: ProfileFlow?

    var body: some View {
        debugChanges()
        return innerView
            .modifier(ContainerModifier(
                profileManager: profileManager,
                flow: flow
            ))
            .modifier(ProfileImporterModifier(
                profileManager: profileManager,
                registry: registry,
                isPresented: $isImporting,
                errorHandler: errorHandler
            ))
            .navigationTitle(Strings.Unlocalized.appName)
    }
}

private extension ProfileContainerView {

    @ViewBuilder
    var innerView: some View {
        switch layout {
        case .list:
            ProfileListView(
                profileManager: profileManager,
                tunnel: tunnel,
                errorHandler: errorHandler,
                flow: flow
            )

        case .grid:
            ProfileGridView(
                profileManager: profileManager,
                tunnel: tunnel,
                errorHandler: errorHandler,
                flow: flow
            )
        }
    }
}

private struct ContainerModifier: ViewModifier {

    @ObservedObject
    var profileManager: ProfileManager

    let flow: ProfileFlow?

    @State
    private var search = ""

    func body(content: Content) -> some View {
        debugChanges()
        return content
            .themeProgress(
                if: !profileManager.isReady,
                isEmpty: !profileManager.hasProfiles,
                emptyContent: emptyView
            )
            .searchable(text: $search)
            .onChange(of: search) {
                profileManager.search(byName: $0)
            }
    }

    private func emptyView() -> some View {
        VStack(spacing: 16) {
            Text(Strings.Views.App.Folders.noProfiles)
                .themeEmptyMessage(fullScreen: false)

            Button(Strings.Views.App.Folders.NoProfiles.migrate) {
                flow?.onMigrateProfiles()
            }
        }
    }
}

// MARK: - Previews

#Preview("List") {
    PreviewView(layout: .list)
}

#Preview("Grid") {
    PreviewView(layout: .grid)
}

private struct PreviewView: View {
    let layout: ProfilesLayout

    var body: some View {
        NavigationStack {
            ProfileContainerView(
                layout: layout,
                profileManager: .forPreviews,
                tunnel: .forPreviews,
                registry: Registry(),
                isImporting: .constant(false),
                errorHandler: .default()
            )
        }
        .withMockEnvironment()
    }
}
