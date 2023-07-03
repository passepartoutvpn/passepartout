//
//  DonateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/8/22.
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
import StoreKit
import SwiftUI

struct DonateView: View {
    enum AlertType: Identifiable {
        case thankYou

        // XXX: alert ids
        var id: Int {
            switch self {
            case .thankYou: return 1
            }
        }
    }

    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject private var productManager: ProductManager

    @State private var isAlertPresented = false

    @State private var alertType: AlertType?

    @State private var pendingDonationIdentifier: String?

    init() {
        productManager = .shared
    }

    var body: some View {
        List {
            productsSection
                .disabled(pendingDonationIdentifier != nil)
        }.themeSecondaryView()
        .navigationTitle(L10n.Donate.title)
        .alert(
            L10n.Donate.title,
            isPresented: $isAlertPresented,
            presenting: alertType,
            actions: alertActions,
            message: alertMessage
        )

        // reloading
        .onAppear {
            productManager.refreshProducts()
        }.onChange(of: scenePhase) { newValue in
            if newValue == .active {
                productManager.refreshProducts()
            }
        }.themeAnimation(on: productManager.isRefreshingProducts)
    }
}

// MARK: -

private extension DonateView {
    func alertActions(_ alertType: AlertType) -> some View {
        switch alertType {
        case .thankYou:
            return Button(role: .cancel) {
            } label: {
                Text(L10n.Global.Strings.ok)
            }
        }
    }

    func alertMessage(_ alertType: AlertType) -> some View {
        switch alertType {
        case .thankYou:
            return Text(L10n.Donate.Alerts.Purchase.Success.message)
        }
    }

    var productsSection: some View {
        Section {
            if !productManager.isRefreshingProducts {
                ForEach(productManager.donations, id: \.productIdentifier, content: productRow)
            } else {
                ProgressView()
            }
        } header: {
            Text(L10n.Donate.Sections.OneTime.header)
        } footer: {
            Text(L10n.Donate.Sections.OneTime.footer)
        }
    }

    @ViewBuilder
    func productRow(_ product: SKProduct) -> some View {
        HStack {
            Button(product.localizedTitle) {
                purchaseProduct(product)
            }
            Spacer()
            if let pending = pendingDonationIdentifier, pending == product.productIdentifier {
                ProgressView()
            } else {
                product.localizedPrice.map {
                    Text($0)
                        .themeSecondaryTextStyle()
                }
            }
        }
    }
}

private extension ProductManager {
    var donations: [SKProduct] {
        products.filter { product in
            LocalProduct.allDonations.contains {
                $0.matchesStoreKitProduct(product)
            }
        }.sorted {
            $0.price.decimalValue < $1.price.decimalValue
        }
    }
}

// MARK: -

private extension DonateView {
    func purchaseProduct(_ product: SKProduct) {
        pendingDonationIdentifier = product.productIdentifier
        productManager.purchase(product, completionHandler: handlePurchaseResult)
    }

    func handlePurchaseResult(_ result: Result<InAppPurchaseResult, Error>) {
        switch result {
        case .success(let value):
            if case .done = value {
                alertType = .thankYou
                isAlertPresented = true
            } else {
                // cancelled
            }

        case .failure(let error):
            ErrorHandler.shared.handle(
                title: L10n.Donate.title,
                message: L10n.Donate.Alerts.Purchase.Failure.message(AppError(error).localizedDescription)
            )
        }
        pendingDonationIdentifier = nil
    }
}
