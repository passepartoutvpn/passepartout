//
//  PaywallView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/12/25.
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

import CommonIAP
import CommonLibrary
import CommonUtils
import SwiftUI

struct PaywallView: View, SizeClassProviding {

    @Environment(\.horizontalSizeClass)
    var hsClass

    @Environment(\.verticalSizeClass)
    var vsClass

    @Binding
    var isPresented: Bool

    @ObservedObject
    var iapManager: IAPManager

    let requiredFeatures: Set<AppFeature>

    @ObservedObject
    var model: PaywallCoordinator.Model

    @ObservedObject
    var errorHandler: ErrorHandler

    let onComplete: (String, InAppPurchaseResult) -> Void

    let onError: (Error) -> Void

    var body: some View {
#if os(tvOS)
//        if isBigDevice {
            PaywallFixedView(
                isPresented: $isPresented,
                iapManager: iapManager,
                requiredFeatures: requiredFeatures,
                model: model,
                errorHandler: errorHandler,
                onComplete: onComplete,
                onError: onError
            )
//        } else {
#else
            PaywallScrollableView(
                isPresented: $isPresented,
                iapManager: iapManager,
                requiredFeatures: requiredFeatures,
                model: model,
                errorHandler: errorHandler,
                onComplete: onComplete,
                onError: onError
            )
//        }
#endif
    }
}
