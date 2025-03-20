//
//  ModuleBuilder+Previews.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/19/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

extension ModuleBuilder where Self: ModuleViewProviding {

    @MainActor
    public func preview(title: String = "") -> some View {
        PreviewView(title: title, builder: self)
    }

    @MainActor
    public func preview<C: View>(with content: (Self, ProfileEditor) -> C) -> some View {
        NavigationStack {
            content(self, ProfileEditor(modules: [self]))
        }
        .withMockEnvironment()
    }
}

private struct PreviewView<Builder>: View where Builder: ModuleBuilder & ModuleViewProviding {
    let title: String

    let builder: Builder

    @StateObject
    private var editor = ProfileEditor()

    var body: some View {
        NavigationStack {
            builder.moduleView(with: .init(
                registry: Registry(),
                editor: editor,
                impl: nil
            ))
            .navigationTitle(title)
        }
        .onLoad {
            editor.saveModule(builder, activating: true)
        }
        .withMockEnvironment()
    }
}
