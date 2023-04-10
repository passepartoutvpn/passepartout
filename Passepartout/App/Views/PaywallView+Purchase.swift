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

import SwiftUI
import StoreKit
import PassepartoutLibrary

extension PaywallView {
    struct PurchaseView: View {
        private enum AlertType: Identifiable {
            case purchaseFailed(SKProduct, Error)

            case restoreFailed(Error)

            var id: Int {
                switch self {
                case .purchaseFailed: return 1

                case .restoreFailed: return 2
                }
            }
        }

        fileprivate enum PurchaseState {
            case purchasing(SKProduct)

            case restoring
        }

        private typealias RowModel = (product: SKProduct, extra: String?)

        @Environment(\.scenePhase) private var scenePhase

        @ObservedObject private var productManager: ProductManager

        @Binding private var isPresented: Bool

        private let feature: LocalProduct?

        @State private var alertType: AlertType?

        @State private var purchaseState: PurchaseState?

        init(isPresented: Binding<Bool>, feature: LocalProduct? = nil) {
            productManager = .shared
            _isPresented = isPresented
            self.feature = feature
        }

        var body: some View {
            List {
                productsSection
                    .disabled(purchaseState != nil)
            }.navigationTitle(Unlocalized.appName)
            .alert(item: $alertType, content: presentedAlert)

            // reloading
            .onAppear {
                productManager.refreshProducts()
            }.onChange(of: scenePhase) { newValue in
                if newValue == .active {
                    productManager.refreshProducts()
                }
            }.themeAnimation(on: productManager.isRefreshingProducts)
        }

        private func presentedAlert(_ alertType: AlertType) -> Alert {
            switch alertType {
            case .purchaseFailed(let product, let error):
                return Alert(
                    title: Text(product.localizedTitle),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text(L10n.Global.Strings.ok)) {
                        purchaseState = nil
                    }
                )

            case .restoreFailed(let error):
                return Alert(
                    title: Text(L10n.Paywall.Items.Restore.title),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text(L10n.Global.Strings.ok)) {
                        purchaseState = nil
                    }
                )
            }
        }

        private var productsSection: some View {
            Section {
                if !productManager.isRefreshingProducts {
                    ForEach(productRowModels, id: \.product.productIdentifier, content: productRow)
                } else {
                    ProgressView()
                }
                restoreRow
            } header: {
                Text(L10n.Paywall.title)
            } footer: {
                Text(L10n.Paywall.Sections.Products.footer)
            }
        }

        private func productRow(_ model: RowModel) -> some View {
            PurchaseRow(
                product: model.product,
                title: model.product.localizedTitle,
                extra: model.extra,
                action: {
                    purchaseProduct(model.product)
                },
                purchaseState: purchaseState
            )
        }

        private var restoreRow: some View {
            PurchaseRow(
                title: L10n.Paywall.Items.Restore.title,
                extra: L10n.Paywall.Items.Restore.description,
                action: restorePurchases,
                purchaseState: purchaseState
            )
        }
    }
}

extension PaywallView.PurchaseView {
    private func purchaseProduct(_ product: SKProduct) {
        purchaseState = .purchasing(product)

        productManager.purchase(product) {
            switch $0 {
            case .success(let result):
                switch result {
                case .done:
                    isPresented = false

                case .cancelled:
                    break
                }
                purchaseState = nil

            case .failure(let error):
                pp_log.error("Unable to purchase: \(error)")
                alertType = .purchaseFailed(product, error)
            }
        }
    }

    private func restorePurchases() {
        purchaseState = .restoring

        productManager.restorePurchases {
            if let error = $0 {
                pp_log.error("Unable to restore purchases: \(error)")
                alertType = .restoreFailed(error)
                return
            }
            isPresented = false
            purchaseState = nil
        }
    }
}

extension PaywallView.PurchaseView {
    private var skFeature: SKProduct? {
        guard let feature = feature else {
            return nil
        }
        return productManager.product(withIdentifier: feature)
    }

    private var skPlatformVersion: SKProduct? {
        #if targetEnvironment(macCatalyst)
        productManager.product(withIdentifier: .fullVersion_macOS)
        #else
        productManager.product(withIdentifier: .fullVersion_iOS)
        #endif
    }

    // hide full version if already bought the other platform version
    private var skFullVersion: SKProduct? {
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

    private var platformVersionExtra: [String] {
        productManager.featureProducts(excluding: [
            .fullVersion,
            .fullVersion_iOS,
            .fullVersion_macOS
        ]).map {
            $0.localizedTitle
        }.sorted {
            $0.lowercased() < $1.lowercased()
        }
    }

    private var fullVersionExtra: [String] {
        productManager.featureProducts(including: [
            .fullVersion_iOS,
            .fullVersion_macOS
        ]).map {
            $0.localizedTitle
        }.sorted {
            $0.lowercased() < $1.lowercased()
        }
    }

    private var productRowModels: [RowModel] {
        var models: [RowModel] = []
        skPlatformVersion.map {
            let extra = platformVersionExtra.joined(separator: "\n")
            models.append(($0, extra))
        }
        skFullVersion.map {
            let extra = fullVersionExtra.joined(separator: "\n")
            models.append(($0, extra))
        }
        skFeature.map {
            models.append(($0, nil))
        }
        return models
    }
}

private struct PurchaseRow: View {
    var product: SKProduct?

    let title: String

    let extra: String?

    let action: () -> Void

    let purchaseState: PaywallView.PurchaseView.PurchaseState?

    var body: some View {
        VStack(alignment: .leading) {
            actionButton
                .padding(.bottom, 5)

            extra.map {
                Text($0)
                    .frame(maxHeight: .infinity)
            }
        }.padding([.top, .bottom])
    }

    @ViewBuilder
    private var actionButton: some View {
        if let product = product {
            purchaseButton(product)
        } else {
            restoreButton
        }
    }

    private func purchaseButton(_ product: SKProduct) -> some View {
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

    private var restoreButton: some View {
        HStack {
            Button(title, action: action)
            Spacer()
            if case .restoring = purchaseState {
                ProgressView()
            }
        }
    }
}
