//
//  PaywallView+Fixed.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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
import CommonLibrary
import CommonUtils
import SwiftUI

// FIXME: ###, clean up fixed-size paywall
struct PaywallFixedView: View {

    @Binding
    var isPresented: Bool

    @ObservedObject
    var iapManager: IAPManager

    let requiredFeatures: Set<AppFeature>

    @ObservedObject
    var model: PaywallCoordinator.Model

    @ObservedObject
    var errorHandler: ErrorHandler

    let onComplete: (String, InAppPurchaseResult) -> Void

    let onError: (Error) -> Void

    @FocusState
    private var selectedProduct: AppProduct?

    var body: some View {
        GeometryReader { geo in
            HStack {
                VStack {
                    completeProductsView
                    individualProductsView
                }
                .frame(maxHeight: .infinity)

                featuresView
                    .padding(.leading, 100)
                    .frame(maxWidth: 0.4 * geo.size.width, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            .themeAnimation(on: iapManager.purchasedProducts, category: .paywall)
#if os(tvOS)
            .themeGradient()
#else
            .padding()
#endif
        }
    }
}

private extension PaywallFixedView {
    var blurOpacity: CGFloat {
        0.2
    }

    var showsComplete: Bool {
        !model.completePurchasable.isEmpty
    }

    var completeProductsView: some View {
        VStack {
            Text(Strings.Views.Paywall.Sections.FullProducts.header)
                .font(.title2)
                .padding(.bottom, 1)
            ForEach(model.completePurchasable, id: \.productIdentifier) { iap in
                PaywallProductView(
                    iapManager: iapManager,
                    style: .paywall(primary: true),
                    product: iap,
                    withIncludedFeatures: false,
                    requiredFeatures: requiredFeatures,
                    purchasingIdentifier: $model.purchasingIdentifier,
                    onComplete: onComplete,
                    onError: onError
                )
                .focused($selectedProduct, equals: AppProduct(rawValue: iap.productIdentifier))
                .frame(maxWidth: .infinity)
                .disabled(iapManager.didPurchase(iap))
            }
            Text(Strings.Views.Paywall.Sections.FullProducts.footer)
                .foregroundStyle(.tertiary)
                .padding(.bottom)
        }
        .disabled(!iapManager.isEligibleForComplete)
        .opacity(iapManager.isEligibleForComplete ? 1.0 : blurOpacity)
        .if(showsComplete)
    }

    var individualProductsView: some View {
        VStack {
            if showsComplete {
                Text(Strings.Views.Paywall.Sections.Products.header)
                    .font(.headline)
                    .padding(.bottom, 1)
            } else {
                Text(Strings.Global.Actions.purchase)
                    .font(.title2)
                    .padding(.bottom, 1)
            }
            ForEach(model.individualPurchasable, id: \.productIdentifier) { iap in
                PaywallProductView(
                    iapManager: iapManager,
                    style: .paywall(primary: !showsComplete),
                    product: iap,
                    withIncludedFeatures: false,
                    requiredFeatures: requiredFeatures,
                    purchasingIdentifier: $model.purchasingIdentifier,
                    onComplete: onComplete,
                    onError: onError
                )
                .focused($selectedProduct, equals: AppProduct(rawValue: iap.productIdentifier))
                .frame(maxWidth: .infinity)
                .opacity(!iapManager.didPurchase(iap) ? 1.0 : blurOpacity)
                .disabled(iapManager.didPurchase(iap))
            }
        }
    }

    var featuresView: some View {
        VStack {
            AllFeaturesView(
                features: Set(selectedProduct?.features ?? []),
                requiredFeatures: requiredFeatures,
                font: .headline
            )
            .frame(maxHeight: .infinity)

            Text(Strings.Views.Paywall.Sections.Products.footer)
                .foregroundStyle(.tertiary)
                .padding(.bottom)
        }
    }
}

// MARK: - Previews

#Preview("WithComplete") {
    let features: Set<AppFeature> = [.appleTV, .dns, .sharing]
    PaywallFixedView(
        isPresented: .constant(true),
        iapManager: .forPreviews,
        requiredFeatures: features,
        model: .forPreviews(features, including: [.complete]),
        errorHandler: .default(),
        onComplete: { _, _ in },
        onError: { _ in }
    )
    .withMockEnvironment()
}

#Preview("WithoutComplete") {
    let features: Set<AppFeature> = [.appleTV, .dns, .sharing]
    PaywallFixedView(
        isPresented: .constant(true),
        iapManager: .forPreviews,
        requiredFeatures: features,
        model: .forPreviews(features, including: []),
        errorHandler: .default(),
        onComplete: { _, _ in },
        onError: { _ in }
    )
    .withMockEnvironment()
}

#Preview("Individual") {
    let features: Set<AppFeature> = [.appleTV]
    PaywallFixedView(
        isPresented: .constant(true),
        iapManager: .forPreviews,
        requiredFeatures: features,
        model: .forPreviews(features, including: []),
        errorHandler: .default(),
        onComplete: { _, _ in },
        onError: { _ in }
    )
    .withMockEnvironment()
}
