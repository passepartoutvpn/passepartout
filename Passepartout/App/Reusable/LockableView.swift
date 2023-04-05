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

struct LockableView<Content: View, LockedContent: View>: View {
    @Binding var locksInBackground: Bool

    let content: () -> Content

    let lockedContent: () -> LockedContent

    let unlockBlock: () async -> Bool

    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject private var lock: Lock = .shared

    @Binding private var state: Lock.State

    init(
        locksInBackground: Binding<Bool>,
        content: @escaping () -> Content,
        lockedContent: @escaping () -> LockedContent,
        unlockBlock: @escaping () async -> Bool
    ) {
        _locksInBackground = locksInBackground
        self.content = content
        self.lockedContent = lockedContent
        self.unlockBlock = unlockBlock

        _state = .init {
            Lock.shared.state
        } set: {
            Lock.shared.state = $0
        }
    }

    var body: some View {
        ZStack {
            content()
            if locksInBackground && state != .none {
                lockedContent()
            }
        }.onChange(of: scenePhase, perform: onScenePhase)
    }

    private func onScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            unlockIfNeeded()

        case .inactive:
            if state == .none {
                state = .covered
            }

        case .background:
            lockIfNeeded()

        default:
            break
        }
    }

    func lockIfNeeded() {
        guard locksInBackground else {
            return
        }
        state = .locked
    }

    func unlockIfNeeded() {
        guard locksInBackground else {
            state = .none
            return
        }
        switch state {
        case .none:
            break

        case .covered:
            state = .none

        case .locked:
            Task { @MainActor in
                guard await unlockBlock() else {
                    return
                }
                state = .none
            }
        }
    }
}

private class Lock: ObservableObject {
    enum State {
        case none

        case covered

        case locked
    }

    static let shared = Lock()

    @Published var state: State = .locked

    private init() {
    }
}
