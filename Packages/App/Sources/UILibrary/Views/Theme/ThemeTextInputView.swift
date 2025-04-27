//
//  ThemeTextInputView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/25/25.
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

#if !os(tvOS)

import SwiftUI

public struct ThemeTextInputView: View {
    private let title: String

    @Binding
    private var isPresented: Bool

    private let onValidate: ((String) -> Bool)?

    private let onSubmit: (String) -> Void

    @State
    private var text = ""

    public init(
        _ title: String,
        isPresented: Binding<Bool>,
        onValidate: ((String) -> Bool)? = nil,
        onSubmit: @escaping (String) -> Void
    ) {
        self.title = title
        _isPresented = isPresented
        self.onValidate = onValidate
        self.onSubmit = onSubmit
    }

    public var body: some View {
        TextEditor(text: $text)
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.Global.Nouns.ok) {
                        isPresented = false
                        onSubmit(text)
                    }
                    .disabled(onValidate?(text) == false)
                }
            }
            .themeForm()
            .navigationTitle(title)
            .themeNavigationDetail()
            .themeNavigationStack(closable: true)
    }
}

#Preview {
    struct Preview: View {
        @State
        private var isPresented = false

        var body: some View {
            Button("Present") {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                ThemeTextInputView(
                    "Comment",
                    isPresented: $isPresented,
                    onValidate: { $0.count >= 10 },
                    onSubmit: { _ in }
                )
            }
        }
    }

    return Preview()
        .withMockEnvironment()
}

#endif
