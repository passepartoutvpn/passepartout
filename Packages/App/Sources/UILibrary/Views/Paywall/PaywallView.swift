//
//  PaywallView.swift
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

import CommonLibrary
import CommonUtils
import StoreKit
import SwiftUI

// FIXME: ###, purchase multiple products in sequence
struct PaywallView: View {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    var isPresented: Bool

    let requiredFeatures: Set<AppFeature>

    @State
    private var isFetchingProducts = true

    @State
    private var products: [InAppProduct] = []

    @State
    private var completeProducts: [InAppProduct] = []

    @State
    private var purchasingIdentifier: String?

    @State
    private var isPurchasePendingConfirmation = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .themeProgress(if: isFetchingProducts)
            .alert(
                Strings.Global.Actions.purchase,
                isPresented: $isPurchasePendingConfirmation,
                actions: pendingActions,
                message: pendingMessage
            )
            .task(id: requiredFeatures) {
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
            completeProductsView
            productsView
            restoreView
#if !os(tvOS)
            linksView
#endif
        }
        .themeForm()
        .disabled(purchasingIdentifier != nil)
    }

    var productsView: some View {
        products
            .nilIfEmpty
            .map { products in
                ForEach(products, id: \.productIdentifier) {
                    PaywallProductView(
                        iapManager: iapManager,
                        style: .paywall,
                        product: $0,
                        highlightedFeatures: requiredFeatures,
                        purchasingIdentifier: $purchasingIdentifier,
                        onComplete: onComplete,
                        onError: onError
                    )
                }
                .themeSection(
                    header: Strings.Views.Paywall.Sections.Products.header,
                    footer: Strings.Views.Paywall.Sections.Products.footer,
                    forcesFooter: true
                )
            }
    }

    var completeProductsView: some View {
        completeProducts
            .nilIfEmpty
            .map { products in
                Group {
                    ForEach(products, id: \.productIdentifier) {
                        PaywallProductView(
                            iapManager: iapManager,
                            style: .paywall,
                            product: $0,
                            withIncludedFeatures: false,
                            highlightedFeatures: requiredFeatures,
                            purchasingIdentifier: $purchasingIdentifier,
                            onComplete: onComplete,
                            onError: onError
                        )
                    }
                    VStack(alignment: .leading) {
                        ForEach(AppFeature.allCases.sorted()) {
                            IncludedFeatureRow(
                                feature: $0,
                                isHighlighted: requiredFeatures.contains($0)
                            )
                            .font(.subheadline)
                        }
                    }
                }
                .themeSection(
                    footer: [
                        Strings.Views.Paywall.Sections.FullProducts.footer,
                        Strings.Views.Paywall.Sections.Products.footer
                    ].joined(separator: " "),
                    forcesFooter: true
                )
            }
    }

    var linksView: some View {
        Section {
            Link(Strings.Unlocalized.eula, destination: Constants.shared.websites.eula)
            Link(Strings.Views.Settings.Links.Rows.privacyPolicy, destination: Constants.shared.websites.privacyPolicy)
        }
    }

    var restoreView: some View {
        RestorePurchasesButton(errorHandler: errorHandler)
            .themeSectionWithSingleRow(
                header: Strings.Views.Paywall.Sections.Restore.header,
                footer: Strings.Views.Paywall.Sections.Restore.footer,
                above: true
            )
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
        do {
            let rawProducts = iapManager.suggestedProducts()
            guard !rawProducts.isEmpty else {
                throw AppError.emptyProducts
            }
            let rawCompleteProducts = rawProducts.filter(\.isComplete)

            let allProducts = try await iapManager.purchasableProducts(for: rawProducts
                .sorted {
                    $0.productRank < $1.productRank
                }
            )
            var products: [InAppProduct] = []
            var completeProducts: [InAppProduct] = []
            allProducts.forEach {
                guard let raw = AppProduct(rawValue: $0.productIdentifier) else {
                    return
                }
                if rawCompleteProducts.contains(raw) {
                    completeProducts.append($0)
                } else {
                    products.append($0)
                }
            }

            pp_log_g(.App.iap, .info, "Suggested products: \(products)")
            guard !products.isEmpty || !completeProducts.isEmpty else {
                throw AppError.emptyProducts
            }

            self.products = products
            self.completeProducts = completeProducts
        } catch {
            pp_log_g(.App.iap, .error, "Unable to load purchasable products: \(error)")
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
    var productRank: Int {
        switch self {
        case .Essentials.iOS_macOS:
            return .min
        case .Essentials.iOS:
            return 1
        case .Essentials.macOS:
            return 2
        case .Complete.Recurring.yearly:
            return 3
        case .Complete.Recurring.monthly:
            return 4
        default:
            return .max
        }
    }
}

// MARK: - Previews

#Preview {
    PaywallView(
        isPresented: .constant(true),
        requiredFeatures: [.appleTV, .dns, .sharing]
    )
    .withMockEnvironment()
}
