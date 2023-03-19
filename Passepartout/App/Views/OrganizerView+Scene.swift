//
//  OrganizerView+Scene.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import PassepartoutLibrary

extension OrganizerView {
    struct SceneView: View {
        @Environment(\.scenePhase) private var scenePhase

        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var vpnManager: VPNManager

        @Binding private var alertType: AlertType?

        @Binding private var didHandleSubreddit: Bool

        @State private var isFirstLaunch = true

        init(alertType: Binding<AlertType?>, didHandleSubreddit: Binding<Bool>) {
            profileManager = .shared
            vpnManager = .shared
            _alertType = alertType
            _didHandleSubreddit = didHandleSubreddit
        }

        var body: some View {

            // dummy text, EmptyView() does not trigger on*() handlers
            Text("Scene")
                .hidden()
                .onAppear(perform: onAppear)
        }

        private func onAppear() {
            guard didHandleSubreddit else {
                alertType = .subscribeReddit
                return
            }

            //
            // FIXME: iPad portrait/compact, loading current profile adds ProfileView() twice
            //
            // - from MainView
            // - from NavigationLink destination in OrganizerView
            //
            // can notice becase "Back" needs to be tapped twice to show sidebar
            // workaround: set active profile but do not load as current (prevents NavigationLink activation)
            //
            guard isFirstLaunch else {
                return
            }
            isFirstLaunch = false
            if themeIdiom != .phone && !themeIsiPadPortrait, let activeProfileId = profileManager.activeProfileId {
                profileManager.currentProfileId = activeProfileId
            }
        }
    }
}
