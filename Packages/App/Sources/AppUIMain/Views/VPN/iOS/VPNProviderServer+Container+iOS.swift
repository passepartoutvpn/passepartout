//
//  VPNProviderServer+Container+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
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

#if os(iOS)

import SwiftUI

extension VPNProviderServerView {
    struct ContainerView<Content, Filters>: View where Content: View, Filters: View {

        @ViewBuilder
        let content: Content

        @ViewBuilder
        let filters: Filters

        var body: some View {
            content
                .modifier(FiltersItemModifier {
                    filters
                })
        }
    }
}

private struct FiltersItemModifier<FiltersContent>: ViewModifier where FiltersContent: View {

    @ViewBuilder
    let filtersContent: FiltersContent

    @State
    private var isPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                Button {
                    isPresented = true
                } label: {
                    ThemeImage(.filters)
                }
                .themePopover(
                    isPresented: $isPresented,
                    size: .custom(width: 400, height: 400),
                    content: filtersPopover
                )
            }
    }

    func filtersPopover() -> some View {
        filtersContent
            .navigationTitle(Strings.Global.Nouns.filters)
            .themeNavigationDetail()
            .themeNavigationStack(closable: true) {
                isPresented = false
            }
            .presentationDetents([.medium])
    }
}

#endif
