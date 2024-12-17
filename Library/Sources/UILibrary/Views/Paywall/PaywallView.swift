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

    @State
    private var isFetchingProducts = true

    @State
    private var featureIAPs: [InAppProduct] = []

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
            featureProductsView
            fullProductsView
            if !iapManager.isFullVersionPurchaser {
                fullVersionFeaturesView
            }
            restoreView
        }
        .themeForm()
        .disabled(purchasingIdentifier != nil)
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

    var featureProductsView: some View {
        featureIAPs.nilIfEmpty.map { iaps in
            ForEach(iaps, id: \.productIdentifier) {
                PaywallProductView(
                    iapManager: iapManager,
                    style: .paywall,
                    product: $0,
                    purchasingIdentifier: $purchasingIdentifier,
                    onComplete: onComplete,
                    onError: onError
                )
            }
            .themeSection(header: Strings.Global.Nouns.products)
        }
    }

    var fullProductsView: some View {
        fullIAPs.nilIfEmpty.map {
            ForEach($0, id: \.productIdentifier) {
                PaywallProductView(
                    iapManager: iapManager,
                    style: .paywall,
                    product: $0,
                    purchasingIdentifier: $purchasingIdentifier,
                    onComplete: onComplete,
                    onError: onError
                )
            }
            .themeSection(header: Strings.Views.Paywall.Sections.FullProducts.header)
        }
    }

    var fullVersionFeaturesView: some View {
        FeatureListView(
            style: allFeaturesStyle,
            header: Strings.Views.Paywall.Sections.AllFeatures.header,
            features: fullVersionFeatures,
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
    var fullVersionFeatures: [AppFeature] {
        AppFeature.fullFeatures
    }

    func fetchAvailableProducts() async {
        isFetchingProducts = true
        defer {
            isFetchingProducts = false
        }
        do {
            let suggestedProducts = iapManager.suggestedProducts(for: features)
            guard let suggestedProducts else {
                throw AppError.emptyProducts
            }

            let featureIAPs = try await iapManager.purchasableProducts(for: suggestedProducts
                .filter {
                    !$0.isFullVersion
                }
                .sorted {
                    $0.featureRank < $1.featureRank
                }
            )
            let fullIAPs = try await iapManager.purchasableProducts(for: suggestedProducts
                .filter(\.isFullVersion)
                .sorted {
                    $0.fullVersionRank < $1.fullVersionRank
                }
            )

            pp_log(.App.iap, .info, "Suggested products: \(suggestedProducts)")
            pp_log(.App.iap, .info, "\tFeatures: \(featureIAPs)")
            pp_log(.App.iap, .info, "\tFull version: \(fullIAPs)")
            guard !(featureIAPs + fullIAPs).isEmpty else {
                throw AppError.emptyProducts
            }

            self.featureIAPs = featureIAPs
            self.fullIAPs = fullIAPs
        } catch {
            pp_log(.App.iap, .error, "Unable to load purchasable products: \(error)")
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

private extension AppProduct {
    var featureRank: Int {
        0
    }

    var fullVersionRank: Int {
        switch self {
        case .Full.Recurring.yearly:
            return .min
        case .Full.Recurring.monthly:
            return 1
        case .Full.OneTime.fullTV:
            return 2
        case .Full.OneTime.full:
            return 3
        default:
            return .max
        }
    }
}

// MARK: - Previews

#Preview {
    PaywallView(
        isPresented: .constant(true),
        features: [.appleTV]
    )
    .withMockEnvironment()
}
