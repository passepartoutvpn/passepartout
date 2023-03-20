//
//  LockableView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/20/23.
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
import LocalAuthentication

struct LockableView<Content: View, LockedContent: View>: View {
    let reason: String

    @Binding var locksInBackground: Bool

    let content: () -> Content

    let lockedContent: () -> LockedContent

    @Environment(\.scenePhase) private var scenePhase

    @State private var didAppear = false

    @State private var isLocked = false

    var body: some View {
        Group {
            if !isLocked {
                content()
            } else {
                lockedContent()
            }
        }.onChange(of: scenePhase, perform: onScenePhase)
    }

    private func onScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            if !didAppear {
                didAppear = true
                if locksInBackground {
                    isLocked = true
                }
            }
            unlockIfNeeded()

        case .inactive:
            lockIfNeeded()

        default:
            break
        }
    }

    func lockIfNeeded() {
        guard locksInBackground else {
            return
        }
        isLocked = true
    }

    func unlockIfNeeded() {
        guard isLocked else {
            return
        }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return
        }
        Task {
            do {
                let isAuthorized = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                isLocked = !isAuthorized
            } catch {
            }
        }
    }
}
