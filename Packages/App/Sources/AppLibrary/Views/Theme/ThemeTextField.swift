// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import SwiftUI

public struct ThemeTextField: View {
    let title: String?

    @Binding
    var text: String

    let placeholder: String

    public init(_ title: String?, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    @ViewBuilder
    var labeledView: some View {
        if let title {
            LabeledContent {
                fieldView
            } label: {
                Text(title)
            }
        } else {
            fieldView
        }
    }

    var fieldView: some View {
        TextField(title ?? "", text: $text, prompt: Text(placeholder))
            .themeManualInput()
    }
}
