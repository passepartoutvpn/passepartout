//
//  StoreKitProductView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/7/24.
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

import CommonUtils
import StoreKit
import SwiftUI

struct StoreKitProductView: View {
    let style: PaywallProductViewStyle

    let product: InAppProduct

    @Binding
    var purchasingIdentifier: String?

    let onComplete: (String, InAppPurchaseResult) -> Void

    let onError: (Error) -> Void

    var body: some View {
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            ProductView(id: product.productIdentifier)
                .withPaywallStyle(style)
                .onInAppPurchaseStart { _ in
                    purchasingIdentifier = product.productIdentifier
                }
                .onInAppPurchaseCompletion { skProduct, result in
                    do {
                        let skResult = try result.get()
                        onComplete(skProduct.id, skResult.toResult)
                    } catch {
                        onError(error)
                    }
                    purchasingIdentifier = nil
                }
        } else {
            fatalError("Unsupported ProductView")
        }
    }
}

@available(iOS 17, macOS 14, tvOS 17, *)
private extension ProductView {

    @ViewBuilder
    func withPaywallStyle(_ paywallStyle: PaywallProductViewStyle) -> some View {
#if os(tvOS)
        switch paywallStyle {
        case .donation:
            productViewStyle(.compact)
                .padding()
        case .paywall:
            productViewStyle(.regular)
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
        }
#else
        productViewStyle(.compact)
#endif
    }
}

private extension Product.PurchaseResult {
    var toResult: InAppPurchaseResult {
        switch self {
        case .success:
            return .done
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        default:
            return .cancelled
        }
    }
}
