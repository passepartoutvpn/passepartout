// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import SwiftUI

public struct PaywallProductView: View {

    @ObservedObject
    private var iapManager: IAPManager

    private let style: PaywallProductViewStyle

    private let product: InAppProduct

    private let withIncludedFeatures: Bool

    private let highlightedFeatures: Set<AppFeature>

    @Binding
    private var purchasingIdentifier: String?

    private let onComplete: (String, InAppPurchaseResult) -> Void

    private let onError: (Error) -> Void

    @State
    private var isPresentingFeatures = false

    public init(
        iapManager: IAPManager,
        style: PaywallProductViewStyle,
        product: InAppProduct,
        withIncludedFeatures: Bool = true,
        highlightedFeatures: Set<AppFeature> = [],
        purchasingIdentifier: Binding<String?>,
        onComplete: @escaping (String, InAppPurchaseResult) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.iapManager = iapManager
        self.style = style
        self.product = product
        self.withIncludedFeatures = withIncludedFeatures
        self.highlightedFeatures = highlightedFeatures
        _purchasingIdentifier = purchasingIdentifier
        self.onComplete = onComplete
        self.onError = onError
    }

    public var body: some View {
        VStack(alignment: .leading) {
            productView
            if withIncludedFeatures {
                AppProduct(rawValue: product.productIdentifier)
                    .map {
                        IncludedFeaturesView(
                            product: $0,
                            highlightedFeatures: highlightedFeatures,
                            isDisclosing: $isPresentingFeatures
                        )
                    }
            }
        }
    }
}

private extension PaywallProductView {

    @ViewBuilder
    var productView: some View {
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            StoreKitProductView(
                style: style,
                product: product,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
        } else {
            CustomProductView(
                style: style,
                iapManager: iapManager,
                product: product,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
        }
    }
}

#Preview {
    List {
        PaywallProductView(
            iapManager: .forPreviews,
            style: .paywall(),
            product: InAppProduct(
                productIdentifier: AppProduct.Features.appleTV.rawValue,
                localizedTitle: "Foo",
                localizedDescription: "Bar",
                localizedPrice: "$10",
                native: nil
            ),
            highlightedFeatures: [.appleTV],
            purchasingIdentifier: .constant(nil),
            onComplete: { _, _ in },
            onError: { _ in }
        )
    }
    .withMockEnvironment()
}
