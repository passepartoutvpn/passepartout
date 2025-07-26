// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import StoreKit
import SwiftUI

struct CustomProductView: View {
    let style: PaywallProductViewStyle

    @ObservedObject
    var iapManager: IAPManager

    let product: InAppProduct

    @Binding
    var purchasingIdentifier: String?

    let onComplete: (String, InAppPurchaseResult) -> Void

    let onError: (Error) -> Void

    var body: some View {
        HStack {
            Text(verbatim: product.localizedTitle)
            Spacer()
            Button(action: purchase) {
                Text(verbatim: product.localizedPrice)
            }
        }
    }
}

private extension CustomProductView {
    func purchase() {
        purchasingIdentifier = product.productIdentifier
        Task {
            defer {
                purchasingIdentifier = nil
            }
            do {
                let result = try await iapManager.purchase(product)
                onComplete(product.productIdentifier, result)
            } catch {
                onError(error)
            }
        }
    }
}
