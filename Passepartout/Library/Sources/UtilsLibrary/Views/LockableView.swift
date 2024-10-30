//
//  LockableView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/20/23.
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

#if !os(tvOS)

import SwiftUI

public struct LockableView<Content: View, LockedContent: View>: View {

    @Environment(\.scenePhase)
    private var scenePhase

    // unobserved here, observed in LockedContentWrapper
    private let lock: Lock

    private let locksInBackground: Bool

    private let content: () -> Content

    private let lockedContent: () -> LockedContent

    private let unlockBlock: () async -> Bool

    @MainActor
    public init(
        locksInBackground: Bool,
        content: @escaping () -> Content,
        lockedContent: @escaping () -> LockedContent,
        unlockBlock: @escaping () async -> Bool
    ) {
        lock = .shared
        self.locksInBackground = locksInBackground
        self.content = content
        self.lockedContent = lockedContent
        self.unlockBlock = unlockBlock
    }

    public var body: some View {
        debugChanges()
        return ZStack {
            content()
            if locksInBackground {
                LockedContentWrapperView(
                    lock: lock,
                    content: lockedContent
                )
            }
        }
        .onChange(of: scenePhase, perform: onScenePhase)
    }
}

// MARK: -

@MainActor
private final class Lock: ObservableObject {
    enum State {
        case none

        case covered

        case locked
    }

    static let shared = Lock()

    @Published
    var state: State = .locked

    private init() {
    }
}

// MARK: -

@MainActor
private extension LockableView {
    func onScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            unlockIfNeeded()

        case .inactive:
            if lock.state == .none {
                lock.state = .covered
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
        lock.state = .locked
    }

    func unlockIfNeeded() {
        guard locksInBackground else {
            lock.state = .none
            return
        }
        switch lock.state {
        case .none:
            break

        case .covered:
            lock.state = .none

        case .locked:
            Task {
                guard await unlockBlock() else {
                    return
                }
                lock.state = .none
            }
        }
    }
}

// MARK: -

private struct LockedContentWrapperView<Content>: View where Content: View {

    @ObservedObject
    var lock: Lock

    @ViewBuilder
    let content: Content

    var body: some View {
        if lock.state != .none {
            content
        }
    }
}

#endif
