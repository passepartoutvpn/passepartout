//
//  ThemeBooleanModalModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/24/25.
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

import SwiftUI

struct ThemeBooleanModalModifier<Modal>: ViewModifier where Modal: View {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.colorScheme)
    private var colorScheme

    @Binding
    var isPresented: Bool

    let options: ThemeModalOptions

    let modal: () -> Modal

    func body(content: Content) -> some View {
        let modalSize = theme.modalSize(options.size)
        _ = modalSize
        return content
            .sheet(isPresented: $isPresented) {
                modal()
#if os(macOS)
                    .frame(
                        minWidth: modalSize.width,
                        maxWidth: options.isFixedWidth ? modalSize.width : nil,
                        minHeight: modalSize.height,
                        maxHeight: options.isFixedHeight ? modalSize.height : nil
                    )
#endif
                    .interactiveDismissDisabled(!options.isInteractive)
                    .themeLockScreen()
            }
    }
}
