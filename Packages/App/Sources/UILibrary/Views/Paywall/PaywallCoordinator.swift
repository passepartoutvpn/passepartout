//
//  PaywallCoordinator.swift
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

struct PaywallState {
    var isFetchingProducts = true

    private(set) var suggestedProducts: Set<AppProduct> = []

    private(set) var completePurchasable: [InAppProduct] = []

    private(set) var individualPurchasable: [InAppProduct] = []

    var purchasingIdentifier: String?

    var isPurchasePendingConfirmation = false

    mutating func setSuggestedProducts(_ suggestedProducts: Set<AppProduct>, purchasable: [InAppProduct]) throws {
        let completeProducts = suggestedProducts.filter(\.isComplete)

        var completePurchasable: [InAppProduct] = []
        var individualPurchasable: [InAppProduct] = []
        purchasable.forEach {
            guard let raw = AppProduct(rawValue: $0.productIdentifier) else {
                return
            }
            if completeProducts.contains(raw) {
                completePurchasable.append($0)
            } else {
                individualPurchasable.append($0)
            }
        }
        pp_log_g(.App.iap, .info, "Individual products: \(individualPurchasable)")
        guard !completePurchasable.isEmpty || !individualPurchasable.isEmpty else {
            throw AppError.emptyProducts
        }

        self.suggestedProducts = suggestedProducts
        self.completePurchasable = completePurchasable
        self.individualPurchasable = individualPurchasable
    }
}

struct PaywallCoordinator: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    var isPresented: Bool

    let requiredFeatures: Set<AppFeature>

    @State
    private var state = PaywallState()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .themeProgress(if: state.isFetchingProducts)
            .disabled(state.purchasingIdentifier != nil)
            .alert(
                Strings.Global.Actions.purchase,
                isPresented: $state.isPurchasePendingConfirmation,
                actions: pendingActions,
                message: pendingMessage
            )
            .task(id: requiredFeatures) {
                await fetchAvailableProducts()
            }
            .withErrorHandler(errorHandler)
    }
}

// MARK: -

private extension PaywallCoordinator {
    var contentView: some View {
#if os(tvOS)
        PaywallView(
            requiredFeatures: requiredFeatures,
            state: state
        )
        .themeNavigationStack()
#else
        PaywallView(
            isPresented: $isPresented,
            iapManager: iapManager,
            requiredFeatures: requiredFeatures,
            state: $state,
            errorHandler: errorHandler,
            onComplete: onComplete,
            onError: onError
        )
        .themeNavigationStack(closable: true)
#endif
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

private extension PaywallCoordinator {
    func fetchAvailableProducts() async {
        state.isFetchingProducts = true
        defer {
            state.isFetchingProducts = false
        }
        do {
            let rawProducts = iapManager.suggestedProducts(for: requiredFeatures)
            guard !rawProducts.isEmpty else {
                throw AppError.emptyProducts
            }
            let rawSortedProducts = rawProducts.sorted {
                $0.productRank < $1.productRank
            }
            let purchasable = try await iapManager.purchasableProducts(for: rawSortedProducts)
            try state.setSuggestedProducts(rawProducts, purchasable: purchasable)
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
            // FIXME: ###, dismiss if purchased complete or all individuals
            isPresented = false
        case .pending:
            state.isPurchasePendingConfirmation = true
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

extension PaywallState {

    @MainActor
    static func forPreviews(
        _ features: Set<AppFeature>,
        filters: Set<IAPManager.SuggestionFilter>
    ) -> Self {
        var state = PaywallState()
        state.isFetchingProducts = false
        let suggested = IAPManager.forPreviews.suggestedProducts(
            for: features,
            filters: filters
        )
        try? state.setSuggestedProducts(
            suggested,
            purchasable: suggested.map(\.asFakeIAP)
        )
        return state
    }
}

#Preview {
    PaywallCoordinator(
        isPresented: .constant(true),
        requiredFeatures: [.appleTV, .dns, .sharing]
    )
    .withMockEnvironment()
}
