//
//  LongContentView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/4/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

struct LongContentView: View {
    @Binding var content: String

    var body: some View {
        TextEditor(text: $content)
            .font(.system(.body, design: .monospaced))
//            .padding()

        // TODO: layout, add padding an inset, let content extend beyond safe areas
    }
}

struct LongContentLink<Preview: View>: View {
    private let title: String

    @Binding private var content: String

    private let preview: String?

    private let previewLabel: ((String) -> Preview)?

    init(
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

    var body: some View {
        NavigationLink {
            LongContentView(content: $content)
                .navigationTitle(title)
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
