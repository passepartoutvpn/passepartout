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
import PassepartoutKit
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
    private var isFetchingProducts = true

    @State
    private var suggestedIAP: InAppProduct?

    @State
    private var fullIAPs: [InAppProduct] = []

    @State
    private var purchasingIdentifier: String?

    @State
    private var isPurchasePendingConfirmation = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
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

    var contentView: some View {
        Form {
            requiredFeaturesView
            suggestedProductView
            if !fullIAPs.isEmpty {
                fullProductsView
                allFeaturesView
            }
            restoreView
        }
        .themeForm()
        .disabled(purchasingIdentifier != nil)
    }

    var suggestedProductView: some View {
        suggestedIAP.map { iap in
            PaywallProductView(
                iapManager: iapManager,
                style: .oneTime,
                product: iap,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
            .themeSection(header: Strings.Views.Paywall.Sections.SuggestedProduct.header)
        }
    }

    var fullProductsView: some View {
        ForEach(fullIAPs, id: \.productIdentifier) {
            PaywallProductView(
                iapManager: iapManager,
                style: .recurring,
                product: $0,
                purchasingIdentifier: $purchasingIdentifier,
                onComplete: onComplete,
                onError: onError
            )
        }
        .themeSection(header: Strings.Views.Paywall.Sections.FullProducts.header)
    }

    var requiredFeaturesView: some View {
        FeatureListView(
            style: .list,
            header: Strings.Views.Paywall.Sections.RequiredFeatures.header,
            features: Array(features),
            content: {
                featureView(for: $0)
                    .fontWeight(theme.relevantWeight)
            }
        )
    }

    var allFeaturesView: some View {
        FeatureListView(
            style: allFeaturesStyle,
            header: Strings.Views.Paywall.Sections.AllFeatures.header,
            features: allFeatures,
            content: featureView(for:)
        )
    }

    var allFeaturesStyle: FeatureListViewStyle {
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
    var allFeatures: [AppFeature] {
        AppFeature.allCases
    }

    var lifetimeProduct: AppProduct {
        .Full.OneTime.lifetime
    }

    var yearlyProduct: AppProduct {
        .Full.Recurring.yearly
    }

    var monthlyProduct: AppProduct {
        .Full.Recurring.monthly
    }

    func fetchAvailableProducts() async {
        isFetchingProducts = true
        defer {
            isFetchingProducts = false
        }

        var list: [AppProduct] = []
        if let suggestedProduct {
            list.append(suggestedProduct)
        }
        list.append(lifetimeProduct)
        list.append(yearlyProduct)
        list.append(monthlyProduct)

        do {
            let availableProducts = try await iapManager.purchasableProducts(for: list)
            guard !availableProducts.isEmpty else {
                throw AppError.emptyProducts
            }

            var suggestedIAP: InAppProduct?
            var fullIAPs: [InAppProduct] = []
            availableProducts.forEach {
                if let suggestedProduct, $0.productIdentifier.hasSuffix(suggestedProduct.rawValue) {
                    suggestedIAP = $0
                } else {
                    fullIAPs.append($0)
                }
            }

            pp_log(.App.iap, .info, "Available products: \(availableProducts)")
            pp_log(.App.iap, .info, "\tSuggested: \(suggestedIAP.debugDescription)")
            pp_log(.App.iap, .info, "\tFull: \(fullIAPs)")

            guard suggestedIAP != nil || !fullIAPs.isEmpty else {
                throw AppError.emptyProducts
            }

            self.suggestedIAP = suggestedIAP
            self.fullIAPs = fullIAPs
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
