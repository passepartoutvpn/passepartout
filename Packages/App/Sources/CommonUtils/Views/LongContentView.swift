// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#if !os(tvOS)

import SwiftUI

public struct LongContentView: View {

    @Binding
    public var content: String

    public var copySystemImage: String?

    public var body: some View {
        contentView
            .toolbar {
                Button {
                    Utils.copyToPasteboard(content)
                } label: {
                    Image(systemName: copySystemImage ?? "doc.on.doc")
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if #available(iOS 17, macOS 14, *) {
            TextEditor(text: $content)
//                .contentMargins(8)
//                .scrollContentBackground(.hidden)
                .scrollClipDisabled()
        } else {
            TextEditor(text: $content)
        }
    }
}

public struct LongContentLink<Preview: View>: View {
    private let title: String

    @Binding
    private var content: String

    private let preview: String?

    private let previewLabel: ((String) -> Preview)?

    public init(
        _ title: String,
        content: Binding<String>,
        preview: String? = nil,
        previewLabel: ((String) -> Preview)? = nil
    ) {
        self.title = title
        _content = content
        self.preview = preview
        self.previewLabel = previewLabel
    }

    public var body: some View {
        NavigationLink {
            LongContentView(content: $content)
                .font(.body)
                .monospaced()
                .navigationTitle(title)
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
        } label: {
            HStack {
                Text(title)
                Spacer()
                previewLabel.map {
                    $0(preview ?? content)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

#endif
