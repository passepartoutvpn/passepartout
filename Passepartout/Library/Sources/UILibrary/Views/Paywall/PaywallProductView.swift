//
//  Empty.swift
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
import SwiftUI

public struct PaywallProductView: View {

    @ObservedObject
    private var iapManager: IAPManager

    private let style: PaywallProductViewStyle

    private let product: InAppProduct

    @Binding
    private var isPurchasing: Bool

    private let onComplete: (String, InAppPurchaseResult) -> Void

    private let onError: (Error) -> Void

    public init(
        iapManager: IAPManager,
        style: PaywallProductViewStyle,
        product: InAppProduct,
        isPurchasing: Binding<Bool>,
        onComplete: @escaping (String, InAppPurchaseResult) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.iapManager = iapManager
        self.style = style
        self.product = product
        _isPurchasing = isPurchasing
        self.onComplete = onComplete
        self.onError = onError
    }

    public var body: some View {
        if #available(iOS 17, macOS 14, *) {
            StoreKitProductView(
                style: style,
                product: product,
                isPurchasing: $isPurchasing,
                onComplete: onComplete,
                onError: onError
            )
        } else {
            CustomProductView(
                style: style,
                iapManager: iapManager,
                product: product,
                isPurchasing: $isPurchasing,
                onComplete: onComplete,
                onError: onError
            )
        }
    }
}
