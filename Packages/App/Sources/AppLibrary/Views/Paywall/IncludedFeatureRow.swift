//
//  IncludedFeatureRow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/18/25.
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

import CommonLibrary
import SwiftUI

public struct IncludedFeatureRow: View {
    private let feature: AppFeature

    private let isHighlighted: Bool

    public init(feature: AppFeature, isHighlighted: Bool) {
        self.feature = feature
        self.isHighlighted = isHighlighted
    }

    public var body: some View {
        HStack {
            ThemeImage(.marked)
                .opaque(isHighlighted)

            Text(feature.localizedDescription)
                .fontWeight(isHighlighted ? .bold : .regular)
                .scrollableOnTV()
        }
    }
}
