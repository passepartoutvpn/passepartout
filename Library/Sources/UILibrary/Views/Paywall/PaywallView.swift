//
//  PaywallView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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

import CommonLibrary
import CommonUtils
import StoreKit
import SwiftUI

struct PaywallView: View {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    var isPresented: Bool

    let features: Set<AppFeature>

    let suggestedProduct: AppProduct?

    @State
    private var oneTimeProduct: InAppProduct?

    @State
    private var recurringProducts: [InAppProduct] = []

    @State
    private var isFetchingProducts = true

    @State
    private var purchasingIdentifier: String?

    @State
    private var isPurchasePendingConfirmation = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        paywallView
            .themeProgress(if: isFetchingProducts)
#if !os(tvOS)
            .toolbar(content: toolbarContent)
#endif
            .alert(
                Strings.Global.Actions.purchase,
                isPresented: $isPurchasePendingConfirmation,
                actions: pendingActions,
                message: pendingMessage
            )
            .task(id: features) {
                await fetchAvailableProducts()
            }
            .withErrorHandler(errorHandler)
    }
}

private extension PaywallView {
    var title: String {
        Strings.Global.Actions.purchase
    }

    var otherFeatures: [AppFeature] {
        AppFeature.allCases.filter {
            !features.contains($0)
        }
    }

    var paywallView: some View {
        Form {
            requiredFeaturesView
            productsView
            otherFeaturesView
            restoreView
        }
        .themeForm()
        .disabled(purchasingIdentifier != nil)
    }

    @ViewBuilder
    var productsView: some View {
        oneTimeProduct.map {
            PaywallProductView(
                iapManager: iapManager,
                style: .oneTime,
                product: $0,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
            .themeSection(header: Strings.Views.Paywall.Sections.OneTime.header)
        }
        ForEach(recurringProducts, id: \.productIdentifier) {
            PaywallProductView(
                iapManager: iapManager,
                style: .recurring,
                product: $0,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
        }
        .themeSection(header: Strings.Views.Paywall.Sections.Recurring.header)
    }

    var requiredFeaturesView: some View {
        FeatureListView(
            style: .list,
            header: Strings.Views.Paywall.Sections.Features.Required.header,
            features: Array(features),
            content: {
                featureView(for: $0)
                    .fontWeight(theme.relevantWeight)
            }
        )
    }

    var otherFeaturesView: some View {
        FeatureListView(
            style: otherFeaturesStyle,
            header: Strings.Views.Paywall.Sections.Features.Other.header,
            features: otherFeatures,
            content: featureView(for:)
        )
    }

    var otherFeaturesStyle: FeatureListViewStyle {
#if os(iOS) || os(tvOS)
        .list
#else
        .table
#endif
    }

    func featureView(for feature: AppFeature) -> some View {
        Text(feature.localizedDescription)
            .scrollableOnTV()
    }

    var restoreView: some View {
        RestorePurchasesButton(errorHandler: errorHandler)
            .themeSectionWithSingleRow(
                header: Strings.Views.Paywall.Sections.Restore.header,
                footer: Strings.Views.Paywall.Sections.Restore.footer,
                above: true
            )
    }
}

private extension PaywallView {

    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                isPresented = false
            } label: {
                ThemeCloseLabel()
            }
        }
    }

    func pendingActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            isPresented = false
        }
    }

    func pendingMessage() -> some View {
        Text(Strings.Views.Paywall.Alerts.Pending.message)
    }
}

// MARK: -

private extension PaywallView {
    func fetchAvailableProducts() async {
        isFetchingProducts = true
        defer {
            isFetchingProducts = false
        }

        var list: [AppProduct] = []
        if let suggestedProduct {
            list.append(suggestedProduct)
        }
        list.append(.Full.Recurring.yearly)
        list.append(.Full.Recurring.monthly)

        do {
            let availableProducts = try await iapManager.purchasableProducts(for: list)
            guard !availableProducts.isEmpty else {
                throw AppError.emptyProducts
            }
            oneTimeProduct = availableProducts.first {
                guard let suggestedProduct else {
                    return false
                }
                return $0.productIdentifier.hasSuffix(suggestedProduct.rawValue)
            }
            recurringProducts = availableProducts.filter {
                $0.productIdentifier != oneTimeProduct?.productIdentifier
            }
        } catch {
            onError(error, dismissing: true)
        }
    }

    func onComplete(_ productIdentifier: String, result: InAppPurchaseResult) {
        switch result {
        case .done:
            Task {
                await iapManager.reloadReceipt()
            }
            isPresented = false

        case .pending:
            isPurchasePendingConfirmation = true

        case .cancelled:
            break

        case .notFound:
            fatalError("Product not found: \(productIdentifier)")
        }
    }

    func onError(_ error: Error) {
        onError(error, dismissing: false)
    }

    func onError(_ error: Error, dismissing: Bool) {
        errorHandler.handle(error, title: Strings.Global.Actions.purchase) {
            if dismissing {
                isPresented = false
            }
        }
    }
}

// MARK: - Previews

#Preview {
    PaywallView(
        isPresented: .constant(true),
        features: [.appleTV],
        suggestedProduct: .Features.appleTV
    )
    .withMockEnvironment()
}
