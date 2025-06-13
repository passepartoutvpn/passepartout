//
//  CustomProductView.swift
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
        contentView
            .disabled(isPurchasing)
    }
}

private extension CustomProductView {
    var contentView: some View {
#if os(tvOS)
        Button(action: purchase) {
            VStack(alignment: .leading) {
                Text(verbatim: product.localizedTitle)
                    .themeTrailingValue(product.localizedPrice)
                    .font(withDescription ? .headline : .footnote)

                if withDescription {
                    Text(verbatim: product.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
#else
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: product.localizedTitle)
                    .font(isPrimary ? .title2 : withFooter ? .headline : nil)
                    .fontWeight(isPrimary ? .bold : nil)

                if withDescription {
                    Text(verbatim: product.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(action: purchase) {
                Text(product.localizedPrice)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(.quinary)
                    .clipShape(.capsule)
                    .foregroundStyle(Color.accentColor)
                    .opacity(!isPurchasing ? 1.0 : 0.3)
                    .cursor(.hand)
            }
            .buttonStyle(.borderless)
        }
        .padding(withPadding ? 10 : .zero)
#endif
    }
}

private extension CustomProductView {
    var isPurchasing: Bool {
        purchasingIdentifier != nil
    }

    var isPrimary: Bool {
        switch style {
        case .donation:
            false
        case .paywall(let primary):
            primary
        }
    }

    var withDescription: Bool {
        switch style {
        case .donation:
            false
        case .paywall(let primary):
            primary
        }
    }

    var withFooter: Bool {
        switch style {
        case .donation:
            false
        case .paywall(let primary):
#if os(tvOS)
            primary
#else
            true // disclosing features
#endif
        }
    }

    var withPadding: Bool {
        switch style {
        case .donation:
            true
        case .paywall:
            false
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

#Preview {
    List {
        CustomProductView(
            style: .paywall(primary: true),
            iapManager: .forPreviews,
            product: AppProduct.Complete.OneTime.lifetime.asFakeIAP,
            purchasingIdentifier: .constant(nil),
            onComplete: { _, _ in },
            onError: { _ in }
        )
    }
}
