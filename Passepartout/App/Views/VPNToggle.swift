//
//  VPNToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/26/22.
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

import SwiftUI
import PassepartoutCore

struct VPNToggle: View {
    @ObservedObject private var vpnManager: VPNManager

    @ObservedObject private var currentVPNState: VPNManager.ObservableState
    
    private let rateLimit: Int
    
    private let onToggle: (() -> Void)?

    private var isEnabled: Binding<Bool> {
        .init {
            currentVPNState.isEnabled
        } set: { _ in
            _ = toggleVPN()
        }
    }

    @State private var canToggle = true
    
    init(rateLimit: Int, onToggle: (() -> Void)? = nil) {
        vpnManager = .shared
        currentVPNState = .shared
        self.rateLimit = rateLimit
        self.onToggle = onToggle
    }

    var body: some View {
        Toggle(L10n.Global.Strings.enabled, isOn: isEnabled)
            .disabled(!canToggle)
            .themeAnimation(on: currentVPNState.isEnabled)
    }

    private func toggleVPN() -> Bool {
        guard vpnManager.toggle() else {
            return false
        }
        
        // rate limit toggle actions
        canToggle = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(rateLimit)) {
            canToggle = true
        }
        
        onToggle?()
        return true
    }
}
