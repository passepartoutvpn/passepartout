//
//  LaunchOnLoginItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
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

import Combine
import Foundation
import ServiceManagement

extension LaunchOnLoginItem {

    @MainActor
    final class ViewModel: ObservableObject {
        let title: String

        let utils: LightUtils

        var persistentlyLaunchesOnLogin: Bool {
            get {
                launchesOnLogin
            }
            set {
                guard SMLoginItemSetEnabled(Constants.Mac.appLauncherId as CFString, newValue) else {
                    return
                }
                objectWillChange.send()
                launchesOnLogin = newValue
            }
        }

        private var launchesOnLogin: Bool {
            get {
                utils.launchesOnLogin
            }
            set {
                utils.launchesOnLogin = newValue
            }
        }

        private var subscriptions: Set<AnyCancellable> = []

        init(_ title: String, utils: LightUtils) {
            self.title = title
            self.utils = utils
        }

        @objc func toggleLaunchesOnLogin() {
            persistentlyLaunchesOnLogin.toggle()
        }

        func subscribe(_ block: @escaping (Bool) -> Void) {
            objectWillChange
                .sink { [weak self] in
                    guard let self else {
                        return
                    }
                    block(self.persistentlyLaunchesOnLogin)
                }.store(in: &subscriptions)
        }
    }
}
