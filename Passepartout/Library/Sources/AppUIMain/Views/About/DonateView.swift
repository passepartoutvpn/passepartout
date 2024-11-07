//
//  DonateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/24/24.
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
import SwiftUI

struct DonateView: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var isFetchingProducts = true

    @State
    private var availableProducts: [InAppProduct] = []

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        Form {
            if isFetchingProducts {
                ProgressView()
                    .id(UUID())
            } else {
                donationsView
            }
        }
        .themeForm()
        .navigationTitle(Strings.Views.Donate.title)
//        .alert(
//            Strings.Global.purchase,
//            isPresented: $isPendingPresented,
//            actions: pendingActions,
//            message: pendingMessage
//        )
        .task {
            await fetchAvailableProducts()
        }
        .withErrorHandler(errorHandler)
    }
}

private extension DonateView {
    var donationsView: some View {
        ForEach(availableProducts, id: \.productIdentifier) {
            PaywallProductView(
                iapManager: iapManager,
                style: .donation,
                product: $0,
                onComplete: onComplete,
                onError: onError
            )
        }
        .themeSection()
    }
}

// MARK: -

private extension DonateView {
    func fetchAvailableProducts() async {
        isFetchingProducts = true
        availableProducts = await iapManager.purchasableProducts(for: AppProduct.Donations.all)
        isFetchingProducts = false
    }

    func onComplete(_ productIdentifier: String, result: InAppPurchaseResult) {
        switch result {
        case .done:
            // FIXME: #830, thank you for donation
            dismiss()

        case .pending, .cancelled:
            break

        case .notFound:
            fatalError("Product not found: \(productIdentifier)")
        }
    }

    func onError(_ error: Error) {
        errorHandler.handle(error, title: Strings.Views.Donate.title)
    }
}
