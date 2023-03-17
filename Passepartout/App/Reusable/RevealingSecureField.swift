//
//  RevealingSecureField.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/22/22.
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

struct RevealingSecureField<ImageContent: View>: View {
    let title: String

    @Binding private var text: String

    private let conceilImage: () -> ImageContent

    private let revealImage: () -> ImageContent

    @State private var isRevealed = false

    init(
        _ title: String,
        text: Binding<String>,
        conceilImage: @escaping () -> ImageContent,
        revealImage: @escaping () -> ImageContent
    ) {
        self.title = title
        _text = text
        self.conceilImage = conceilImage
        self.revealImage = revealImage
    }

    var body: some View {
        HStack {
            if isRevealed {
                TextField(title, text: $text)
                Spacer()
                Button {
                    isRevealed.toggle()
                } label: {
                    conceilImage()
                }.buttonStyle(.plain)
            } else {
                SecureField(title, text: $text)
                Spacer()
                Button {
                    isRevealed.toggle()
                } label: {
                    revealImage()
                }.buttonStyle(.plain)
            }
        }
    }
}
