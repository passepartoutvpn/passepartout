//
//  PaywallView+Purchase.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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

import PassepartoutLibrary
import SwiftUI

extension PaywallView {
    struct PurchaseView: View {
        fileprivate enum PurchaseState {
            case purchasing(InAppProduct)

            case restoring
        }

        @Environment(\.scenePhase) private var scenePhase

        @ObservedObject private var productManager: ProductManager

        @Binding private var isPresented: Bool

        private let feature: LocalProduct?

        @State private var purchaseState: PurchaseState?

        @State private var didPurchaseAppleTV = false

        init(isPresented: Binding<Bool>, feature: LocalProduct? = nil) {
            productManager = .shared
            _isPresented = isPresented
            self.feature = feature
        }

        var body: some View {
            List {
                if feature != .appleTV {
                    skFullVersion.map {
                        fullFeaturesSection(withHeader: $0.localizedTitle)
                    }
                }
                purchaseSection
                    .disabled(purchaseState != nil)
                restoreSection
                    .disabled(purchaseState != nil)
            }
            .navigationTitle(Unlocalized.appName)
            .alert(Unlocalized.Other.appleTV, isPresented: $didPurchaseAppleTV) {
                Button(L10n.Global.Strings.ok) {
                    isPresented = false
                }
            } message: {
                Text(L10n.Paywall.Alerts.Purchase.Appletv.Success.message)
            }

            // reloading
            .task {
                await productManager.refreshProducts()
            }
            .onChange(of: scenePhase) { newValue in
                if newValue == .active {
                    Task {
                        await productManager.refreshProducts()
                    }
                }
            }
            .themeAnimation(on: productManager.isRefreshingProducts)
        }
    }
}

private struct FeatureModel: Identifiable, Comparable {
    let productIdentifier: String

    let title: String

    let subtitle: String?

    init(localProduct: LocalProduct, title: String) {
        productIdentifier = localProduct.rawValue
        self.title = title
        subtitle = nil
    }

    init(product: InAppProduct) {
        productIdentifier = product.productIdentifier
        title = product.localizedTitle
        let description = product.localizedDescription
        subtitle = description != title ? description : nil
    }

    var id: String {
        productIdentifier
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.title.lowercased() < rhs.title.lowercased()
    }
}

private struct PurchaseRow: View {
    var product: InAppProduct?

    let title: String

    let action: () -> Void

    let purchaseState: PaywallView.PurchaseView.PurchaseState?

    var body: some View {
        actionButton
    }
}

// MARK: -

private extension PaywallView.PurchaseView {
    func fullFeaturesSection(withHeader header: String) -> some View {
        Section {
            ForEach(fullFeatures) { feature in
                VStack(alignment: .leading) {
                    Text(feature.title)
                        .themeCellTitleStyle()
                    feature.subtitle.map {
                        Text($0)
                            .themeCellSubtitleStyle()
                            .themeSecondaryTextStyle()
                    }
                }
            }
        } header: {
            Text(header)
        }
    }

    var purchaseSection: some View {
        Section {
            if !productManager.isRefreshingProducts {
                ForEach(productRowModels, id: \.productIdentifier, content: productRow)
            } else {
                ProgressView()
            }
        } header: {
            Text(L10n.Paywall.title)
        } footer: {
            Text(L10n.Paywall.Sections.Products.footer)
        }
    }

    var restoreSection: some View {
        Section {
            restoreRow
        } footer: {
            Text(L10n.Paywall.Items.Restore.description)
        }
    }

    func productRow(_ product: InAppProduct) -> some View {
        PurchaseRow(
            product: product,
            title: product.localizedTitle,
            action: {
                purchaseProduct(product)
            },
            purchaseState: purchaseState
        )
    }

    var restoreRow: some View {
        PurchaseRow(
            title: L10n.Paywall.Items.Restore.title,
            action: restorePurchases,
            purchaseState: purchaseState
        )
    }
}

private extension PaywallView.PurchaseView {
    var skFullVersion: InAppProduct? {
        productManager.product(withIdentifier: .fullVersion)
    }

    var fullFeatures: [FeatureModel] {
        productManager.featureProducts(excluding: {
            $0 == .fullVersion || $0 == .appleTV || $0.isLegacyPlatformVersion
        })
        .map {
            FeatureModel(product: $0)
        }
        .sorted()
    }

    var productRowModels: [InAppProduct] {
        productManager
            .purchasableProducts(withFeature: feature)
            .compactMap { productManager.product(withIdentifier: $0) }
    }
}

private extension PurchaseRow {

    @ViewBuilder
    var actionButton: some View {
        if let product {
            purchaseButton(product)
        } else {
            restoreButton
        }
    }

    func purchaseButton(_ product: InAppProduct) -> some View {
        HStack {
            Button(title, action: action)
            Spacer()
            if case .purchasing(let pending) = purchaseState, pending.productIdentifier == product.productIdentifier {
                ProgressView()
            } else {
                product.localizedPrice.map {
                    Text($0)
                        .themeSecondaryTextStyle()
                }
            }
        }
    }

    var restoreButton: some View {
        HStack {
            Button(title, action: action)
            Spacer()
            if case .restoring = purchaseState {
                ProgressView()
            }
        }
    }
}

// MARK: -

// IMPORTANT: resync shared profiles after purchasing Apple TV feature (drop time limit)

private extension PaywallView.PurchaseView {
    func purchaseProduct(_ product: InAppProduct) {
        purchaseState = .purchasing(product)

        Task {
            do {
                let wasEligibleForAppleTV = productManager.isEligible(forFeature: .appleTV)
                let result = try await productManager.purchase(product)

                switch result {
                case .done:
                    if !wasEligibleForAppleTV && productManager.isEligible(forFeature: .appleTV) {
                        ProfileManager.shared.refreshSharedProfiles()
                        didPurchaseAppleTV = true
                    } else {
                        isPresented = false
                    }

                case .cancelled:
                    break
                }
                purchaseState = nil
            } catch {
                pp_log.error("Unable to purchase: \(error)")
                ErrorHandler.shared.handle(
                    title: product.localizedTitle,
                    message: AppError(error).localizedDescription
                ) {
                    purchaseState = nil
                }
            }
        }
    }

    func restorePurchases() {
        purchaseState = .restoring

        Task {
            do {
                let wasEligibleForAppleTV = productManager.isEligible(forFeature: .appleTV)
                try await productManager.restorePurchases()

                if !wasEligibleForAppleTV && productManager.isEligible(forFeature: .appleTV) {
                    ProfileManager.shared.refreshSharedProfiles()
                    didPurchaseAppleTV = true
                } else {
                    isPresented = false
                }

                purchaseState = nil
            } catch {
                pp_log.error("Unable to restore purchases: \(error)")
                ErrorHandler.shared.handle(
                    title: L10n.Paywall.Items.Restore.title,
                    message: AppError(error).localizedDescription
                ) {
                    purchaseState = nil
                }
            }
        }
    }
}
