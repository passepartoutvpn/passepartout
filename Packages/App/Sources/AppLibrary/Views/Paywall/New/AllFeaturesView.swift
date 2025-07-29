// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

struct AllFeaturesView: View {
    let features: Set<AppFeature>

    let requiredFeatures: Set<AppFeature>

    var font: Font?

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(AppFeature.allCases.sorted()) {
                FeatureRow(
                    feature: $0,
                    flags: flags(for: $0)
                )
                .font(font ?? .subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private extension AllFeaturesView {
    func flags(for feature: AppFeature) -> Set<FeatureRow.Flag> {
        var flags: Set<FeatureRow.Flag> = []
        if features.contains(feature) {
            flags.insert(.marked)
        }
        if requiredFeatures.contains(feature) {
            flags.insert(.highlighted)
        }
        return flags
    }
}
