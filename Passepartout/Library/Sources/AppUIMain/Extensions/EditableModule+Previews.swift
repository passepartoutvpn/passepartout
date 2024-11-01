//
//  ModuleBuilder+Previews.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/19/24.
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

extension ModuleBuilder where Self: ModuleViewProviding {

    @MainActor
    func preview(title: String = "") -> some View {
        NavigationStack {
            moduleView(with: ProfileEditor(modules: [self]))
                .navigationTitle(title)
        }
        .withMockEnvironment()
    }

    @MainActor
    func preview<C: View>(with content: (ProfileEditor, Self) -> C) -> some View {
        NavigationStack {
            content(ProfileEditor(modules: [self]), self)
        }
        .withMockEnvironment()
    }
}
