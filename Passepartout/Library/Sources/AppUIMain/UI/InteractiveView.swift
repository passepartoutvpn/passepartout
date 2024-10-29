//
//  InteractiveView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/8/24.
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

import PassepartoutKit
import SwiftUI

struct InteractiveView: View {

    @ObservedObject
    var manager: InteractiveManager

    let onError: (Error) -> Void

    var body: some View {
        manager
            .editor
            .interactiveProvider
            .map(stackView)
    }
}

@MainActor
private extension InteractiveView {
    func stackView(with provider: any InteractiveViewProviding) -> some View {
        NavigationStack {
            AnyView(provider.interactiveView(with: manager.editor))
                .toolbar(content: toolbarContent)
        }
    }

    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(Strings.Global.cancel, role: .cancel) {
                manager.isPresented = false
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(Strings.Global.ok) {
                Task {
                    do {
                        try await manager.complete()
                    } catch {
                        onError(error)
                    }
                }
            }
        }
    }
}

private extension ProfileEditor {

    // in the future, multiple modules may be interactive
    // here we only intercept the first interactive module
    var interactiveProvider: (any InteractiveViewProviding)? {
        modules
            .first {
                $0 is any InteractiveViewProviding
            } as? any InteractiveViewProviding
   }
}
