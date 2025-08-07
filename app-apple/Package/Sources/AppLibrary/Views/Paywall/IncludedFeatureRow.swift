// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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
