//
//  RevealingSecureField.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/22/22.
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

public struct RevealingSecureField<ImageView>: View where ImageView: View {
    public let title: String

    @Binding
    private var text: String

    private var prompt: Text?

    private let conceilImage: () -> ImageView

    private let revealImage: () -> ImageView

    @State
    private var isRevealed = false

    public init(
        _ title: String,
        text: Binding<String>,
        prompt: Text? = nil,
        conceilImage: @escaping () -> ImageView,
        revealImage: @escaping () -> ImageView
    ) {
        self.title = title
        _text = text
        self.prompt = prompt
        self.conceilImage = conceilImage
        self.revealImage = revealImage
    }

    public var body: some View {
        HStack {
            if isRevealed {
                TextField(title, text: $text, prompt: prompt)
                Button {
                    isRevealed.toggle()
                } label: {
                    conceilImage()
                }
                .buttonStyle(.borderless)
            } else {
                SecureField(title, text: $text, prompt: prompt)
                Button {
                    isRevealed.toggle()
                } label: {
                    revealImage()
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

#Preview {
    Form {
        TextField("text", text: .constant("plain-text"))
        RevealingSecureField("secure", text: .constant("secure-text")) {
            Image(systemName: "eye.slash")
        } revealImage: {
            Image(systemName: "eye")
        }
    }
    .formStyle(.grouped)
}
