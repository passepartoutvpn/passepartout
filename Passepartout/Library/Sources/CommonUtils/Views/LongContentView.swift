//
//  LongContentView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/4/22.
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
