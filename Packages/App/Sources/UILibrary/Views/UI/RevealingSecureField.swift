//
//  RevealingSecureField.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/22/22.
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

import SwiftUI

public struct RevealingSecureField<ImageView>: View where ImageView: View {
    public let title: String

    @Binding
    private var text: String

    private var prompt: Text?

    private let imageWidth: CGFloat

    private let conceilImage: () -> ImageView

    private let revealImage: () -> ImageView

    @State
    private var isRevealed = false

    public init(
        _ title: String,
        text: Binding<String>,
        prompt: Text? = nil,
        imageWidth: CGFloat,
        conceilImage: @escaping () -> ImageView,
        revealImage: @escaping () -> ImageView
    ) {
        self.title = title
        _text = text
        self.prompt = prompt
        self.conceilImage = conceilImage
        self.revealImage = revealImage
        self.imageWidth = imageWidth
    }

    public var body: some View {
        if isRevealed {
            TextField(title, text: $text, prompt: prompt)
                .overlay(alignment: .trailing) {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        conceilImage()
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, -imageWidth)
                }
                .padding(.trailing, imageWidth)
        } else {
            SecureField(title, text: $text, prompt: prompt)
                .overlay(alignment: .trailing) {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        revealImage()
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, -imageWidth)
                }
                .padding(.trailing, imageWidth)
        }
    }
}
