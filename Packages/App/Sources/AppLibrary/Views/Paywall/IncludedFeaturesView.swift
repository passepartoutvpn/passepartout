// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import SwiftUI

public struct IncludedFeaturesView: View {
    private let product: AppProduct

    private let highlightedFeatures: Set<AppFeature>

    @Binding
    private var isDisclosing: Bool

    public init(
        product: AppProduct,
        highlightedFeatures: Set<AppFeature>,
        isDisclosing: Binding<Bool>
    ) {
        self.product = product
        self.highlightedFeatures = highlightedFeatures
        _isDisclosing = isDisclosing
    }

    public var body: some View {
        Group {
            discloseButton
                .padding(.top, 8)
            featuresList
                .if(isDisclosing)
        }
        .font(.subheadline)
    }
}

private extension IncludedFeaturesView {
    var discloseButton: some View {
        Button {
            isDisclosing.toggle()
        } label: {
            HStack {
                Text(Strings.Views.Paywall.Product.includedFeatures)
                ThemeImage(isDisclosing ? .undisclose : .disclose)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .cursor(.hand)
    }

    var featuresList: some View {
        FeatureListView(style: .list, features: product.features) {
            IncludedFeatureRow(feature: $0, isHighlighted: highlightedFeatures.contains($0))
        }
    }
}
