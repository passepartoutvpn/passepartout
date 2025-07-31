// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#if !os(tvOS)

import CommonUtils
import SwiftUI

public struct ThemeLongContentLink: View {
    public enum ContentType {
        case ipAddress
        case number
        case text
    }

    private let title: String

    @Binding
    private var text: String

    private let preview: String?

    private let contentType: ContentType

    public init(_ title: String, text: Binding<String>, contentType: ContentType = .text, preview: String? = nil) {
        self.title = title
        _text = text
        self.contentType = contentType
        self.preview = preview ?? text.wrappedValue
    }

    public init(_ title: String, text: Binding<String>, contentType: ContentType = .text, preview: (String) -> String?) {
        self.title = title
        _text = text
        self.contentType = contentType
        self.preview = preview(text.wrappedValue)
    }

    public var body: some View {
        ContentPreviewLink(title, content: $text, preview: preview) {
            contentView(text: $0)
                .font(.body)
                .monospaced()
                .navigationTitle(title)
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
        } previewLabel: {
            Text(preview != nil ? $0 : "")
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func contentView(text: Binding<String>) -> some View {
        switch contentType {
        case .ipAddress:
            LongContentEditor(content: text)
                .themeManualInput()
                .themeIPAddress()
        case .number:
            LongContentEditor(content: text)
                .themeManualInput()
                .themeNumericInput()
        case .text:
            LongContentEditor(content: text)
                .themeManualInput()
        }
    }
}

#endif
