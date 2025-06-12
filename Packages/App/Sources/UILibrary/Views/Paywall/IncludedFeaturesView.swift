//
//  IncludedFeaturesView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/25.
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

import CommonIAP
import SwiftUI

struct IncludedFeaturesView: View {
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

private extension IncludedFeaturesView {
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
