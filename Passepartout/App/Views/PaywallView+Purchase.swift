//
//  PaywallView+Purchase.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

        init(isPresented: Binding<Bool>, feature: LocalProduct? = nil) {
            productManager = .shared
            _isPresented = isPresented
            self.feature = feature
        }

        var body: some View {
            List {
                featuresSection
                purchaseSection
                    .disabled(purchaseState != nil)
                restoreSection
                    .disabled(purchaseState != nil)
            }.navigationTitle(Unlocalized.appName)

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
    var featuresSection: some View {
        Section {
            ForEach(features, id: \.productIdentifier) { product in
                VStack(alignment: .leading) {
                    Text(product.localizedTitle)
                        .themeCellTitleStyle()
                    if product.localizedDescription != product.localizedTitle {
                        Text(product.localizedDescription)
                            .themeCellSubtitleStyle()
                            .themeSecondaryTextStyle()
                    }
                }
            }
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

    // hide full version if already bought the other platform version
    var skFullVersion: InAppProduct? {
        #if targetEnvironment(macCatalyst)
        guard !productManager.hasPurchased(.fullVersion_iOS) else {
            return nil
        }
        #else
        guard !productManager.hasPurchased(.fullVersion_macOS) else {
            return nil
        }
        #endif
        return productManager.product(withIdentifier: .fullVersion)
    }

    var features: [InAppProduct] {
        productManager.featureProducts(excluding: {
            $0 == .fullVersion || $0.isPlatformVersion
        })
        .sorted {
            $0.localizedTitle.lowercased() < $1.localizedTitle.lowercased()
        }
    }

    var productRowModels: [InAppProduct] {
        [skFullVersion]
            .compactMap { $0 }
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

private extension PaywallView.PurchaseView {
    func purchaseProduct(_ product: InAppProduct) {
        purchaseState = .purchasing(product)

        Task {
            do {
                let result = try await productManager.purchase(product)
                switch result {
                case .done:
                    isPresented = false

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
                try await productManager.restorePurchases()
                isPresented = false
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
