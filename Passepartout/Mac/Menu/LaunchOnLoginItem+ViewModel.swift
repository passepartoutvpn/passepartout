//
//  LaunchOnLoginItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import Foundation
import Combine
import ServiceManagement

extension LaunchOnLoginItem {
    class ViewModel: ObservableObject {

        // XXX: hardcoded from AppPreference
        private let launchesOnLoginKey = "Passepartout.App.launchesOnLogin"
        
        let title: String

        var launchesOnLogin: Bool {
            get {
                persistentlyLaunchesOnLogin
            }
            set {
                guard SMLoginItemSetEnabled(Constants.Mac.appLauncherId as CFString, newValue) else {
                    return
                }
                persistentlyLaunchesOnLogin = newValue
                objectWillChange.send()
            }
        }
        
        private var persistentlyLaunchesOnLogin: Bool {
            get {
                UserDefaults.standard.bool(forKey: launchesOnLoginKey)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: launchesOnLoginKey)
            }
        }
        
        private var subscriptions: Set<AnyCancellable> = []

        init(title: String) {
            self.title = title
        }
        
        @objc func toggleLaunchesOnLogin() {
            launchesOnLogin.toggle()
        }
        
        func subscribe(_ block: @escaping (Bool) -> Void) {
            objectWillChange
                .sink {
                    block(self.launchesOnLogin)
                }.store(in: &subscriptions)
        }
    }
}
