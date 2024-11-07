//
//  CustomProductView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/7/24.
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
import StoreKit
import SwiftUI

struct CustomProductView: View {
    let style: ProductViewStyle

    @ObservedObject
    var iapManager: IAPManager

    let product: InAppProduct

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
        Task {
            do {
                let result = try await iapManager.purchase(product)
                onComplete(product.productIdentifier, result)
            } catch {
                onError(error)
            }
        }
    }
}
