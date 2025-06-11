//
//  PaywallCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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

struct PaywallCoordinator: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    var isPresented: Bool

    let requiredFeatures: Set<AppFeature>

    @StateObject
    private var model = Model()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .themeProgress(if: model.isFetchingProducts)
            .disabled(model.purchasingIdentifier != nil)
            .alert(
                Strings.Global.Actions.purchase,
                isPresented: $model.isPurchasePendingConfirmation,
                actions: pendingActions,
                message: pendingMessage
            )
            .task(id: requiredFeatures) {
                do {
                    try await model.fetchAvailableProducts(
                        for: requiredFeatures,
                        with: iapManager
                    )
                } catch {
                    onError(error, dismissing: true)
                }
            }
            .withErrorHandler(errorHandler)
    }
}

private extension PaywallCoordinator {
    var contentView: some View {
#if os(tvOS)
        PaywallView(
            requiredFeatures: requiredFeatures,
            model: model
            // errorHandler
            // onComplete
            // onError
        )
        .themeNavigationStack()
#else
        PaywallView(
            isPresented: $isPresented,
            iapManager: iapManager,
            requiredFeatures: requiredFeatures,
            model: model,
            errorHandler: errorHandler,
            onComplete: onComplete,
            onError: onError
        )
        .themeNavigationStack(closable: true)
#endif
    }

    func pendingActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            isPresented = false
        }
    }

    func pendingMessage() -> some View {
        Text(Strings.Views.Paywall.Alerts.Pending.message)
    }
}

private extension PaywallCoordinator {
    var didPurchaseRequired: Bool {
        iapManager.didPurchaseComplete || iapManager.didPurchase(model.individualPurchasable)
    }

    func onComplete(_ productIdentifier: String, result: InAppPurchaseResult) {
        switch result {
        case .done:
            Task {
                await iapManager.reloadReceipt()
                if didPurchaseRequired {
                    isPresented = false
                }
            }
        case .pending:
            model.isPurchasePendingConfirmation = true
        case .cancelled:
            break
        case .notFound:
            fatalError("Product not found: \(productIdentifier)")
        }
    }

    func onError(_ error: Error) {
        onError(error, dismissing: false)
    }

    func onError(_ error: Error, dismissing: Bool) {
        errorHandler.handle(error, title: Strings.Global.Actions.purchase) {
            if dismissing {
                isPresented = false
            }
        }
    }
}

// MARK: - Previews

#Preview {
    PaywallCoordinator(
        isPresented: .constant(true),
        requiredFeatures: [.appleTV, .dns, .sharing]
    )
    .withMockEnvironment()
}
