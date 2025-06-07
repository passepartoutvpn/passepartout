//
//  QRCodeView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/4/25.
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

public struct QRCodeView: View {
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        if let cgImage = text.qrImage() {
            Image(decorative: cgImage, scale: 1.0)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }
}
